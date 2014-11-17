//
//  RoomExitOperation.m
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "RoomExitOperation.h"

@interface RoomExitOperation ()

@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation RoomExitOperation

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
        
        NSURLRequest *request = [RoomUtility getStartRoom];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *roomId = responseObject[@"roomId"];
            if (roomId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate scheduleRoomCheckOperation:roomId];
                });
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        }];
        [self.queue addOperations:@[operation] waitUntilFinished:YES];


        
    }
}

@end
