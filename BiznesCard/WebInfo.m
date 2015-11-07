//
//  WebInfo.m
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "WebInfo.h"

@implementation WebInfo

- (id)copy
{
    WebInfo *web = [[WebInfo alloc] init];
    
    web.userID = self.userID;
    web.webPageNumber = self.webPageNumber;
    web.webPageName = [self.webPageName copy];
    
    return web;
}

@end
