//
//  TelephoneInfo.m
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "TelephoneInfo.h"

@implementation TelephoneInfo

- (id)copy
{
    TelephoneInfo *obj = [[TelephoneInfo alloc] init];
    //    obj._id = self._id;
    obj.telephoneNumber = [self.telephoneNumber copy];
    
    return obj;
}

@end
