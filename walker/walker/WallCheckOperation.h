//
//  WallCheckOperation.h
//  walker
//
//  Created by Jason Liang on 11/17/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room.h"

@protocol WallCheckOperationDelegate <NSObject>

- (Room *)getRoomWithId:(NSString *)roomId;

@end

@interface WallCheckOperation : NSOperation

@property (nonatomic, weak) id<WallCheckOperationDelegate> delegate;
@property (nonatomic, strong) NSString *roomId;

@end
