//
//  UserInfo.m
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (id)copy
{
    UserInfo *obj = [[UserInfo alloc] init];
    //    obj._id = self._id;
    obj.adress = [self.adress copy];
    obj.personName = [self.personName copy];
    obj.rank = [self.rank copy];
    
    return obj;
}

@end
