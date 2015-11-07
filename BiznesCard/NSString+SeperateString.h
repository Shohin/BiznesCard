//
//  NSString+SeperateString.h
//  BiznesCard
//
//  Created by Shohin on 10/18/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SeperateString)

- (NSString *)stringByReplaceCharacterSet:(NSCharacterSet *)characterset withString:(NSString *)string;
- (NSString *)getGeneralTel;
- (NSString *)getMobile;
- (NSString *)getTel;
- (NSString *)getPhone;
- (NSString *)getOfficeMob;
- (NSString *)getFax;
- (NSString *)getEMail;
- (NSString *)getWebPageName;
- (NSString *)getNameCompany;
- (NSString *)getAddress;
- (NSString *)getPersonName;
- (NSString *)getRank;


@end
