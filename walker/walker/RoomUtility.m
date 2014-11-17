//
//  RoomUtility.m
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import "RoomUtility.h"

static NSString * const kHost = @"http://challenge2.airtime.com:7182";
static NSString * const kPathRoomStart = @"/start";
static NSString * const kPathRoomExits = @"/exits?roomId=%@";
static NSString * const kPathRoomIdForExit = @"/move?roomId=%@&exit=%@";
static NSString * const kPathRoomWall = @"/wall?roomId=%@";

static NSString * const kReport = @"/report";

static NSString * const kEmail = @"liangjyjason@gmail.com";
static NSString * const kEmailHeaderKey = @"X-Labyrinth-Email";

@implementation RoomUtility

+ (NSMutableURLRequest *)getRequestWithPath:(NSString *)path {
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kHost, path];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setValue:kEmail forHTTPHeaderField:kEmailHeaderKey];
    return request;
}

+ (NSURLRequest *)getStartRoom {
    NSString *urlString = kPathRoomStart;
    return [self getRequestWithPath:urlString];
}

+ (NSURLRequest *)getRoomExits:(NSString *)roomId {
    NSString *urlString = [NSString stringWithFormat:kPathRoomExits, roomId];
    return [self getRequestWithPath:urlString];
}

+ (NSURLRequest *)getRoomIdForExit:(NSString *)roomId exit:(NSString *)exit {
    NSString *urlString = [NSString stringWithFormat:kPathRoomIdForExit, roomId, exit];
    return [self getRequestWithPath:urlString];
}

+ (NSURLRequest *)getRoomWall:(NSString *)roomId {
    NSString *urlString = [NSString stringWithFormat:kPathRoomWall, roomId];
    return [self getRequestWithPath:urlString];
}

+ (NSURLRequest *)getReportRequest:(NSArray *)roomIds writing:(NSString *)writing {
    NSMutableURLRequest *request = [self getRequestWithPath:kReport];
    NSMutableDictionary *bodyDict = [NSMutableDictionary dictionary];
    bodyDict[@"roomIds"] = roomIds;
    bodyDict[@"challenge"] = writing;
    NSError *jsonError;
    NSData *data = [NSJSONSerialization dataWithJSONObject:bodyDict options:0 error:&jsonError];
    [request setHTTPBody:data];
    [request setHTTPMethod:@"POST"];
    NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"sending off report with body : %@", newStr);
    return request;
}

@end


