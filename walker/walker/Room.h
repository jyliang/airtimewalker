//
//  Room.h
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Room : NSObject

@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSArray *roomExits;
@property (nonatomic, strong) NSString *writing;
@property (nonatomic) NSInteger order;

- (BOOL)isCompleted;
- (BOOL)isWorking;
@end
