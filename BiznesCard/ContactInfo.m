//
//  ContactInfo.m
//  BiznesCard
//
//  Created by Shohin on 11/21/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "ContactInfo.h"

@implementation ContactInfo

@synthesize baseTelephone = _baseTelephone;
@synthesize telephone = _telephone;
@synthesize mobile = _mobile;
@synthesize phone = _phone;
@synthesize officeMobile = _officeMobile;
@synthesize fax = _fax;
@synthesize email = _email;
@synthesize webPage = _webPage;
@synthesize companyName = _companyName;
@synthesize adress = _adress;
@synthesize personName = _personName;
@synthesize rank = _rank;
@synthesize telephones = _telephones;

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        _telephones = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (id)copy
{
    ContactInfo *obj = [[ContactInfo alloc] init];
//    obj._id = self._id;
    obj.baseTelephone = [_baseTelephone copy];
    obj.telephone = [_telephone copy];
    obj.mobile = [_mobile copy];
    obj.phone = [_phone copy];
    obj.officeMobile = [_officeMobile copy];
    obj.fax = [_fax copy];
    obj.email = [_email copy];
    obj.webPage = [_webPage copy];
    obj.companyName = [_companyName copy];
    obj.adress = [_adress copy];
    obj.personName = [_personName copy];
    obj.rank = [_rank copy];
    
    return obj;
}

#pragma mark - check data

- (BOOL)checkData
{
    BOOL isData = YES;
    
    isData = [self checkTel] || [self checkEMail] || [self checkWebPage] || [self checkAddress];
    
    return isData;
}

- (BOOL)checkTel
{
    BOOL telInfo = YES;
    
    if (_baseTelephone == nil) {
        telInfo = NO;
    }
    
    return telInfo;
}

- (BOOL)checkEMail
{
    BOOL emailInfo = YES;

    if (_email == nil) {
        emailInfo = NO;
    }
    
    return emailInfo;
}

- (BOOL)checkWebPage
{
    BOOL webInfo = YES;
    
    if (_webPage == nil) {
        webInfo = NO;
    }
    
    return webInfo;
}

- (void)setPhones
{
    if ([self checkTel]) {

        if ((![_baseTelephone isEqualToString:_mobile]) && (![_baseTelephone isEqualToString:_officeMobile]) && (![_baseTelephone isEqualToString:_telephone]) && (![_baseTelephone isEqualToString:_phone]) && (![_baseTelephone isEqualToString:_fax])) {
            [_telephones addObject:_baseTelephone];
        }
        
        if (_mobile != nil) {
            [_telephones addObject:_mobile];
        }
        if (_officeMobile != nil) {
            [_telephones addObject:_officeMobile];
        }
        if (_telephone != nil) {
            [_telephones addObject:_telephone];
        }
        if (_phone != nil) {
            [_telephones addObject:_phone];
        }
        if (_fax != nil) {
            [_telephones addObject:_fax];
        }
        
    }
}

- (BOOL)checkAddress
{
    if (_adress == nil) {
        return NO;
    }
    
    return YES;
}

@end
