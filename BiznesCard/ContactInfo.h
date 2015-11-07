//
//  ContactInfo.h
//  BiznesCard
//
//  Created by Shohin on 11/21/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseObject.h"

@interface ContactInfo : BaseObject

@property (retain, nonatomic)NSString *baseTelephone;
@property (retain, nonatomic)NSString *telephone;
@property (retain, nonatomic)NSString *mobile;
@property (retain, nonatomic)NSString *phone;
@property (retain, nonatomic)NSString *officeMobile;
@property (retain, nonatomic)NSString *fax;
@property (retain, nonatomic)NSString *email;
@property (retain, nonatomic)NSString *webPage;
@property (retain, nonatomic)NSString *companyName;
@property (retain, nonatomic)NSString *adress;
@property (retain, nonatomic)NSString *personName;
@property (retain, nonatomic)NSString *rank;

@property (retain, nonatomic)NSMutableArray *telephones;

- (void)setPhones;

- (BOOL)checkData;
- (BOOL)checkEMail;
- (BOOL)checkWebPage;
- (BOOL)checkAddress;
- (BOOL)checkTel;


@end
