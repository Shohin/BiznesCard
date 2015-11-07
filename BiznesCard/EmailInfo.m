//
//  EmailInfo.m
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "EmailInfo.h"

@implementation EmailInfo

- (id)copy
{
    EmailInfo *email = [[EmailInfo alloc] init];
    
    email.userID = self.userID;
    email.emailNumber = self.emailNumber;
    email.email = self.email;
    
    return email;
}

@end
