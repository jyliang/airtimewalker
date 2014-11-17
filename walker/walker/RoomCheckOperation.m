//
//  RoomCheckOperation.m
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "RoomCheckOperation.h"


@interface RoomCheckOperation ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation RoomCheckOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        if (self.delegate == nil) {
            return;
        }

        __block BOOL isChecked = NO;
        dispatch_sync(dispatch_get_main_queue(), ^{
            isChecked = [self.delegate isRoomChecked:self.roomId];
            if (isChecked) {
                [self.delegate tryCompleteRoomWalk];
            }
        });

        if (isChecked) {
            return;
        }

        NSLog(@"checking room %@", self.roomId);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate scheduleWallCheck:self.roomId];
        });



        NSURLRequest *request = [RoomUtility getRoomExits:self.roomId];

        NSURLResponse * response = nil;
        NSError * error = nil;

        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];


//        [self.queue addOperations:@[operation] waitUntilFinished:YES];
//        [self.queue waitUntilAllOperationsAreFinished];
        __block NSArray *exits;
        if (data) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (json) {
                exits = json[@"exits"];
            }
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (exits && [exits isKindOfClass:[NSArray class]]) {

                for (NSString *exit in exits) {

                    [self.delegate searchRoomExit:self.roomId exit:exit];
                }
            }
            [self.delegate completeRoomCheck:self.roomId];
            [self.delegate tryCompleteRoomWalk];
        });
    }
}

@end
