//
//  WallCheckOperation.m
//  walker
//
//  Created by Jason Liang on 11/17/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "WallCheckOperation.h"

@implementation WallCheckOperation

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        NSLog(@"checking room %@ wall status", self.roomId);

        NSURLRequest *request = [RoomUtility getRoomWall:self.roomId];

        NSURLResponse * response = nil;
        NSError * error = nil;

        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if (error) {
            NSLog(@"Error : %@", [error localizedDescription]);
            return;
        }

        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (jsonError) {
            NSLog(@"Error : %@", [jsonError localizedDescription]);
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                Room *room = [self.delegate getRoomWithId:self.roomId];
                room.order = [json[@"order"] integerValue];
                room.writing = json[@"writing"];
            });
        }
    }
}

@end
