//
//  BaseObject.h
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface BaseObject : NSObject

@property (nonatomic, assign) ID _id;

- (NSData *)getIvars:(unsigned int *)count from:(id)class_name NS_RETURNS_RETAINED;
- (NSData *)copyIvarList:(unsigned int *)count from:(id)class_name NS_RETURNS_RETAINED;
- (NSMutableDictionary *)ivar_list NS_RETURNS_RETAINED;


@end
