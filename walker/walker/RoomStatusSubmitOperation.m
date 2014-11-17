//
//  RoomStatusSubmitOperation.m
//  walker
//
//  Created by Jason Liang on 11/17/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "RoomStatusSubmitOperation.h"

@implementation RoomStatusSubmitOperation

- (void)main {
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }

        NSURLRequest *request = [RoomUtility getReportRequest:[self.delegate getBrokenRooms] writing:[self.delegate getRoomWritingCheck]];

        NSURLResponse * response = nil;
        NSError * error = nil;

        NSData * data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];

        if (!error) {
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Task completed : %@", newStr);
        } else {
            NSLog(@"Error : %@", [error localizedDescription]);
        }
    }
}

@end
