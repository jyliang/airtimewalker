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
        __block BOOL isChecking = NO;
        dispatch_sync(dispatch_get_main_queue(), ^{
            isChecked = [self.delegate isRoomChecked:self.roomId];
            if (isChecked) {
                [self.delegate tryCompleteRoomWalk];
            }
        });

        if (isChecked) {
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate scheduleWallCheck:self.roomId];
        });

        __block NSArray *exits;

        NSURLRequest *request = [RoomUtility getStartRoom];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            exits = responseObject;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        }];
        [self.queue addOperations:@[operation] waitUntilFinished:YES];

        dispatch_async(dispatch_get_main_queue(), ^{
            if (exits) {

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
