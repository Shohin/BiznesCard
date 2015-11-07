//
//  config.h
//  BiznesCard
//
//  Created by Shohin on 10/8/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAXWIDTH [[UIScreen mainScreen] bounds].size.width
#define MAXHEIGHT [[UIScreen mainScreen] bounds].size.height

typedef long long int ID;

#define DLog(...) NSLog(__VA_ARGS__)

#define TRIMSTR(string) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]

#define ATTACHMENT_FOLDER               @"cardImages"