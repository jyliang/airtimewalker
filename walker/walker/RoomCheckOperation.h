//
//  RoomCheckOperation.h
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RoomCheckOperationDelegate <NSObject>

- (BOOL)isRoomChecked:(NSString *)roomId;
- (BOOL)isRoomChecking:(NSString *)roomId;

- (void)searchRoomExit:(NSString *)roomId exit:(NSString *)exit;
- (void)scheduleRoomCheck:(NSString *)roomId;
- (void)scheduleWallCheck:(NSString *)roomId;
- (void)completeRoomCheck:(NSString *)roomId;

- (void)tryCompleteRoomWalk;

@end

@interface RoomCheckOperation : NSOperation

@property (nonatomic, weak) id<RoomCheckOperationDelegate> delegate;

@property (nonatomic, strong) NSString *roomId;

@end
