//
//  RoomExitOperation.m
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "RoomExitOperation.h"

@interface RoomExitOperation ()

//@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation RoomExitOperation

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        NSLog(@"checking room %@ exit %@", self.roomId, self.exit);

        NSURLRequest *request = [RoomUtility getRoomIdForExit:self.roomId exit:self.exit];

        NSURLResponse * response = nil;
        NSError * error = nil;

        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if (!error) {
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if (jsonError) {

            } else {
                NSString *roomId = json[@"roomId"];
                if (roomId) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate completeExitCheck:self.roomId exit:self.exit];
                        [self.delegate scheduleRoomCheck:roomId];
                    });
                }
            }
        } else {
            NSLog(@"Error : %@", [error localizedDescription]);
        }

    }
}

@end
