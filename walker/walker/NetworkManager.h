//
//  NetworkManager.h
//  walker
//
//  Created by Jason Liang on 11/16/14.
//  Copyright (c) 2014 Jason Liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkManager : NSObject

- (void)start;
- (void)getRoomWithCompletion:(ResultAndErrorHandler) handler;

@end
