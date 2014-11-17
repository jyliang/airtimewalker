//
//  RoomUtility.h
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RoomUtility : NSOperation

+ (NSURLRequest *)getStartRoom;
+ (NSURLRequest *)getRoomExits:(NSString *)roomId;
+ (NSURLRequest *)getRoomIdForExit:(NSString *)roomId exit:(NSString *)exit;
+ (NSURLRequest *)getRoomWall:(NSString *)roomId;

+ (NSURLRequest *)getReportRequest:(NSArray *)roomIds writing:(NSString *)writing;

@end
