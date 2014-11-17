//
//  Room.m
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "Room.h"

@implementation Room

- (BOOL)isCompleted {
    BOOL isCompleted = YES;
    isCompleted &= self.roomExits != nil;
    isCompleted &= self.writing != nil;
    return isCompleted;
}

- (BOOL)isWorking {
    return YES;
}
@end
