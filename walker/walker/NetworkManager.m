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
#import "RoomStatusSubmitOperation.h"
#import "WallCheckOperation.h"
#import "Room.h"

@interface NetworkManager () <RoomCheckOperationDelegate, RoomExitOperationDelegate, RoomStatusSubmitOperationDelegate, WallCheckOperationDelegate>

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
        } else {
            NSLog(@"Error : %@", [error localizedDescription]);
        }
    }];
}

- (void)getRoomWithCompletion:(ResultAndErrorHandler)handler {
    NSURLRequest *request = [RoomUtility getStartRoom];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            handler(nil, connectionError);
        } else {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {
                handler(nil, jsonError);
            } else {
                NSString *roomId = json[@"roomId"];
                if (roomId) {
                    handler(roomId, nil);
                    return;
                }
            }
        }
    }];
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
    WallCheckOperation *operation = [[WallCheckOperation alloc] init];
    operation.roomId = roomId;
    operation.delegate = self;
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

    NSLog(@"WALK IS COMPLETE!!! %li rooms", self.rooms.count);
    RoomStatusSubmitOperation *operation = [[RoomStatusSubmitOperation alloc] init];
    operation.delegate = self;
        NSArray *operations = self.roomCheckQueue.operations;
    for (NSOperation *exitingOperations in operations) {
        [operation addDependency:exitingOperations];
    }
    [self.roomCheckQueue addOperation:operation];

}

#pragma mark - RoomStatusSubmitOperationDelegate

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
            if (room.writing) {
                [string appendString:room.writing];
            } else {
                NSLog(@"room not ready %@", room);
            }
        }
    }
    return string;
}

#pragma mark - WallCheckOperationDelegate

- (Room *)getRoomWithId:(NSString *)roomId {
    return self.rooms[roomId];
}

@end
