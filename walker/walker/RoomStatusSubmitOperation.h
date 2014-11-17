//
//  RoomStatusSubmitOperation.h
//  walker
//
//  Created by Jason Liang on 11/17/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RoomStatusSubmitOperationDelegate <NSObject>

- (NSArray *)getBrokenRooms;
- (NSString *)getRoomWritingCheck;

@end

@interface RoomStatusSubmitOperation : NSOperation

@property (nonatomic, weak) id<RoomStatusSubmitOperationDelegate>delegate;

@end
