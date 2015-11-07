//
//  BaseObject.m
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BaseObject.h"

@implementation BaseObject

@synthesize _id;

- (NSData *)getIvars:(unsigned int *)count from:(id)class_name NS_RETURNS_RETAINED {
    @synchronized(self) {
        SEL selector = @selector(copyIvarList:from:);
        Method grannyMethod = class_getInstanceMethod([class_name class], selector);
        IMP grannyImp = method_getImplementation(grannyMethod);
        return grannyImp([class_name class], selector, count, [class_name class]);
    }
}

- (NSData *)copyIvarList:(unsigned int *)count from:(id)class_name NS_RETURNS_RETAINED {
    @synchronized(self) {
        Ivar *ret_val_c = class_copyIvarList([class_name class], count);
        NSData *ret_val = [[NSData alloc] initWithBytes:ret_val_c length:sizeof(Ivar) * *count];
        free(ret_val_c);
        return ret_val;
    }
}

- (NSMutableDictionary *)ivar_list {
    @synchronized(self) {
        NSMutableDictionary *ret_val = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableString *key = [[NSMutableString alloc] initWithCapacity:0];
        [key setString:@""];
        
        Class class_to_anylize = [self superclass];
        
        Ivar *ivar_list = NULL;
        unsigned int ivar_count = 0;
        int counter = 0;
        
        NSData *self_var_list = [self copyIvarList:&ivar_count from:[self class]];
        [key appendFormat:@"%i_%i", counter++, ivar_count];
        [ret_val setObject:self_var_list forKey:key];
        
        while (![[[class_to_anylize class] description] isEqualToString:[[NSObject class] description]]) {
            [key setString:@""];
            ivar_list = NULL;
            ivar_count = 0;
            NSData *new_var_list = [self getIvars:&ivar_count from:class_to_anylize];
            [key appendFormat:@"%i_%i", counter++, ivar_count];
            [ret_val setObject:new_var_list	forKey:key];
            class_to_anylize = [class_to_anylize superclass];
        }
        
        return ret_val;
    }
}

@end
