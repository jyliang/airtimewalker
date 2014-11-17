//
//  RoomExitOperation.h
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RoomExitOperationDelegate <NSObject>

- (void)scheduleRoomCheckOperation:(NSString *)roomId;
- (void)completeExitCheck:(NSString *)roomdId exit:(NSString *)exit;

@end

@interface RoomExitOperation : NSOperation

@property (nonatomic, weak) id<RoomExitOperationDelegate> delegate;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *exit;

@end
