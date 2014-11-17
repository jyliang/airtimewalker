//
//  NetworkManager.m
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "NetworkManager.h"
#import "RoomCheckOperation.h"
#import "RoomExitOperation.h"
#import "Room.h"

@interface NetworkManager () <RoomCheckOperationDelegate, RoomExitOperationDelegate>

@property (nonatomic, strong) NSOperationQueue *roomWalkQueue; //queue for walking the rooms
@property (nonatomic, strong) NSOperationQueue *roomCheckQueue; //queue for room wall check

@property (nonatomic, strong) NSMutableDictionary *rooms;
@property (nonatomic, strong) NSMutableDictionary *requests;

@end

@implementation NetworkManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.roomCheckQueue = [[NSOperationQueue alloc] init];
        self.roomWalkQueue = [[NSOperationQueue alloc] init];

        self.rooms = [NSMutableDictionary dictionary];
        self.requests = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)start{
    [self getRoomWithCompletion:^(id result, NSError *error) {
        if (result) {
            [self scheduleRoomCheck:result];
        }
    }];
}

- (void)getRoomWithCompletion:(ResultAndErrorHandler)handler {
    NSURLRequest *request = [RoomUtility getStartRoom];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            NSString *roomId = responseObject[@"roomId"];
            if (roomId) {
                handler(roomId, nil);
                return;
            }
        }
        NSError *error = [[NSError alloc] initWithDomain:@"walker" code:1 userInfo:@{NSLocalizedDescriptionKey:@"Can't find roomId"}];
        handler(nil, error);

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        handler(nil, error);
    }];
    /*
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:rq];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.downloadProgressBlock = nil;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Resource download error %@", error);
        self.downloadProgressBlock = nil;
    }];
     */
    [[NSOperationQueue mainQueue] addOperation:operation];
}

#pragma mark - RoomCheckOperationDelegate

- (BOOL)isRoomChecked:(NSString *)roomId {
    return [[self.requests objectForKey:roomId] boolValue];
}

- (BOOL)isRoomChecking:(NSString *)roomId {
    if ([self isRoomChecked:roomId]) {
        return NO;
    } else if ([self.requests objectForKey:roomId]) {
        return YES;
    }
    return NO;
}

- (void)searchRoomExit:(NSString *)roomId exit:(NSString *)exit {
    [self.requests setObject:[NSNumber numberWithBool:NO] forKey:@[roomId,exit]];
    RoomExitOperation *op = [[RoomExitOperation alloc] init];
    op.roomId = roomId;
    op.exit = exit;
    op.delegate = self;
    [self.roomWalkQueue addOperation:op];
}

- (void)scheduleRoomCheck:(NSString *)roomId{
    if ([self isRoomChecking:roomId]) {
        return;
    }
    if (self.rooms[roomId]) {
        //room is created for checking
    } else {
        Room *room = [[Room alloc] init];
        room.roomId = roomId;
        self.rooms[roomId] = room;
        RoomCheckOperation *op = [[RoomCheckOperation alloc] init];
        op.roomId = roomId;
        op.delegate = self;
        [self.requests setObject:[NSNumber numberWithBool:NO] forKey:roomId];
        [self.roomWalkQueue addOperation:op];
    }
}

- (void)scheduleWallCheck:(NSString *)roomId {
    NSURLRequest *request = [RoomUtility getRoomWall:roomId];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Room *room = self.rooms[roomId];
        room.order = [responseObject[@"order"] integerValue];
        room.writing = responseObject[@"writting"];
        NSLog(@"update room status %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
    [self.roomCheckQueue addOperation:operation];
}

- (void)completeRoomCheck:(NSString *)roomId{
    [self.requests setObject:[NSNumber numberWithBool:YES] forKey:roomId];
}

- (void)completeExitCheck:(NSString *)roomdId exit:(NSString *)exit {
    [self.requests setObject:[NSNumber numberWithBool:YES] forKey:@[roomdId, exit]];
}

- (void)tryCompleteRoomWalk{
    for (NSNumber *value in self.requests.allValues) {
        if ([value boolValue] == NO) {
            return;
        }
    }

    NSLog(@"WALK IS COMPLETE!!! %@", self.rooms);
    NSURLRequest *request = [RoomUtility getReportRequest:[self getBrokenRooms] writing:[self getRoomWritingCheck]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"WOOT!");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
    NSArray *operations = self.roomCheckQueue.operations;
    for (NSOperation *exitingOperations in operations) {
        [operation addDependency:exitingOperations];
    }
    [self.roomCheckQueue addOperation:operation];

}

- (NSArray *)getBrokenRooms {
    NSArray *rooms = self.rooms.allValues;
    NSMutableArray *roomIds = [NSMutableArray array];
    for (Room *room in rooms) {
        if (!room.isWorking) {
            [roomIds addObject:room.roomId];
        }
    }
    return roomIds;
}

- (NSString *)getRoomWritingCheck {
    NSMutableString *string = [NSMutableString string];
    NSArray *rooms = self.rooms.allValues;
    NSArray *sortedRooms = [rooms sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSInteger order1 = ((Room *)obj1).order;
        NSInteger order2 = ((Room *)obj2).order;
        return [[NSNumber numberWithInteger:order1] compare:[NSNumber numberWithInteger:order2]];
    }];

    for (Room *room in sortedRooms) {
        if ([room isWorking]) {
            [string appendString:room.writing];
        }
    }
    return string;
}

@end
