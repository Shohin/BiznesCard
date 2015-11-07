//
//  NSString+SeperateString.m
//  BiznesCard
//
//  Created by Shohin on 10/18/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "NSString+SeperateString.h"

#define TELLENGTH 7

#define MOBILTYPE @[@"mobile", @"mobil", @"mob", @"m"]
#define TELTYPE @[@"telephone", @"tel", @"t"]
#define PHONETYPE @[@"phone", @"phon", @"ph", @"p"]
#define OFFICEPHONETYPE @[@"office!", @"officei", @"office", @"offic", @"o"]
#define FAXTYPE @[@"fax", @"f"]
#define GENERALTYPE @[@"mobile", @"mobil", @"mob", @"m", @"telephone", @"tel", @"t", @"phone", @"phon", @"ph", @"p", @"office!", @"officei", @"office", @"offic", @"o"]

@implementation NSString (SeperateString)

#pragma mark - trim String
- (NSString *)stringByReplaceCharacterSet:(NSCharacterSet *)characterset withString:(NSString *)string {
    NSString *result = self;
    NSRange range = [result rangeOfCharacterFromSet:characterset];
    
    while (range.location != NSNotFound) {
        result = [result stringByReplacingCharactersInRange:range withString:string];
        range = [result rangeOfCharacterFromSet:characterset];
    }
    return result;
}

#pragma mark - phonesInformations

- (NSString *)getGeneralTel
{
    NSString *telNumber = nil;
    
    telNumber = [self getBaseTel:GENERALTYPE];
    
    if ([self isDecimal:telNumber]) {
        if (telNumber.length < TELLENGTH) {
            
            NSMutableString *helpNum = [NSMutableString string];
            NSRange range;
            
            NSCharacterSet* isDigits = [NSCharacterSet characterSetWithCharactersInString:@"[0-9]()+ \n"];
            
            range = [self rangeOfCharacterFromSet:isDigits];
            
            [helpNum setString:[self appendStringToStringFromArray:[self componentsSeparatedByString:@"\n"]]];
            if (helpNum.length == 0 || ![self isDecimal:helpNum]) {
                [helpNum setString:self];
            }
            
            while (range.location != NSNotFound && range.length != 0) {
                
//                _telNumber = [self substringFromIndex:range.location];
                
                telNumber = [helpNum getTelFormatString:telNumber];
                
                if (telNumber.length > TELLENGTH) {
                    break;
                } else {
                    [helpNum deleteCharactersInRange:range];
                    range = [helpNum rangeOfCharacterFromSet:isDigits];
                    if (range.location != NSNotFound) {
                        telNumber = [helpNum substringFromIndex:range.location];
                    }
                }
                
            }
        }
    }
    
    telNumber = [self getTelFormatString:telNumber];
    telNumber = TRIMSTR(telNumber);
    if (telNumber.length < TELLENGTH) {
        return nil;
    }
    
    return telNumber;
}

- (NSString *)getMobile
{
    NSString *mobilNumber = nil;
    
    mobilNumber = [self getBaseTel:MOBILTYPE];
    
    return mobilNumber;
}

- (NSString *)getTel
{
    NSString *telNumber = nil;
    
    telNumber = [self getBaseTel:TELTYPE];
    
    return telNumber;
    
    /* self = @"" || self = @"aaa" _telNum = null self = @"aaat:" _telNum = @"" self = @"aaat:123" _telNum = 123 */
    
}

- (NSString *)getPhone
{
    NSString *phoneNumber = nil;
    
    phoneNumber = [self getBaseTel:PHONETYPE];
    
    return phoneNumber;
}

- (NSString *)getOfficeMob
{
    NSString *officeMob = nil;
    
    officeMob = [self getBaseTel:OFFICEPHONETYPE];
    
    return officeMob;
}

- (NSString *)getFax
{
    NSString *faxNum = nil;
    
    faxNum = [self getBaseTel:FAXTYPE];
    
    return faxNum;
}

#pragma mark - getgeneralphonenumbers

- (NSString *)getBaseTel:(NSArray *)telTypes
{
    NSString *lowerStr = [self lowercaseString];
    NSRange range;
    
    NSString *telNumber = nil;
    NSMutableString *helpNum = [NSMutableString stringWithCapacity:0];
    
    if ([self isDecimal:lowerStr]) {
        
//        _telNumber = [self substringFromIndex:range.location + range.length];
        [helpNum setString:self];
//        
//        if ([_telNumber length] > 0) {
//            if ([self isDecimal:_telNumber]) {
//                _telNumber = [self getTelFormatString:_telNumber];
//                _telNumber = [[_telNumber componentsSeparatedByString:@"\n"] objectAtIndex:0];
//            }
//        }
        
        for (NSString *type in telTypes) {
            range = [lowerStr rangeOfString:[type lowercaseString]];
            if (range.location != NSNotFound) {
                break;
            }
        }
        
        while (range.location != NSNotFound && range.length != 0) {
            
            if (helpNum.length > range.location + range.length) {
                telNumber = [helpNum substringFromIndex:range.location + range.length];
            }
            
            if ([helpNum length] > 0) {
                if ([self isDecimal:telNumber]) {
                    telNumber = [self getTelFormatString:telNumber];
                    telNumber = [[telNumber componentsSeparatedByString:@"\n"] objectAtIndex:0];
                }
            }
            
            if (![telNumber isEqualToString:@""]) {
                break;
            } else {
                if (helpNum.length >= range.location) {
                    [helpNum deleteCharactersInRange:range];
                }
            }
            
        }//while
        
    }
    
    telNumber = [self getTelFormatString:telNumber];
    
    telNumber = TRIMSTR(telNumber);
    
    if (telNumber.length < TELLENGTH) {
        return nil;
    }
    
    return telNumber;
    
    /* self = @"" || self = @"aaa" _telNum = null self = @"aaat:" _telNum = @"" self = @"aaat:123" _telNum = 123 */
}

- (NSString *)getTelFormatString:(NSString *)string
{
    //NSCharacterSet *numericSet = [NSCharacterSet decimalDigitCharacterSet];
    NSMutableString *digitStr = [NSMutableString stringWithCapacity:0];
    if ([self isDecimal:string]) {
        for (int i = 0; i < string.length; i++)
        {
            unichar ch = [string characterAtIndex:i];
            if (isdigit(ch) || ch == ' ' || ch == '+' || ch == '(' || ch == ')' || ch == '-' || ch == '.' || ch == ':') {
                [digitStr appendFormat:@"%c", ch];
            } else {
                break;
            }
        }
    }
    
    
    return digitStr;
}

- (BOOL)isDecimal:(NSString *)digitStr
{
    NSCharacterSet* isDigits = [NSCharacterSet decimalDigitCharacterSet];
    if ([digitStr rangeOfCharacterFromSet:isDigits].location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (NSMutableString *)appendStringToStringFromArray:(NSArray *)arr
{
    NSMutableString *str = [NSMutableString string];
    if (arr.count > 0) {
        for (NSString *s in arr) {
            [str appendString:s];
        }
    }
    return str;
}

#pragma mark - networkInformations

- (NSString *)getEMail
{    
    NSRange range = [self rangeOfString:@"@"];
    NSString *userName = nil;
    NSString *web = nil;
    NSString *emailStr = nil;
    
    NSMutableString *helpStr = [NSMutableString string];
    [helpStr setString:self];
    
//    _userName = [self substringToIndex:range.location];
//    _userName = [[_userName componentsSeparatedByString:@" "] lastObject];
//    _userName = [[_userName componentsSeparatedByString:@"\n"] lastObject];
//    
//    _web = [self substringFromIndex:range.location];
//    _web = [[_web componentsSeparatedByString:@" "] objectAtIndex:0];
//    _web = [[_web componentsSeparatedByString:@"\n"] objectAtIndex:0];
//    
//    _emailStr = [NSString stringWithFormat:@"%@%@", _userName, _web];
    
    while (range.location != NSNotFound && range.location != 0)
    {
        userName = [helpStr substringToIndex:range.location];
        userName = [[userName componentsSeparatedByString:@" "] lastObject];
        userName = [[userName componentsSeparatedByString:@"\n"] lastObject];
    
        web = [helpStr substringFromIndex:range.location];
        web = [[web componentsSeparatedByString:@" "] objectAtIndex:0];
        web = [[web componentsSeparatedByString:@"\n"] objectAtIndex:0];
    
        emailStr = [NSString stringWithFormat:@"%@%@", userName, web];
    
        if ([self isEMailString:emailStr]) {
            break;
        } else {
            if (helpStr.length >= range.location) {
                [helpStr deleteCharactersInRange:range];
            }
        }
        range = [helpStr rangeOfString:@"@"];
    
    }
    
    if ([self isEMailString:emailStr]) {
        return emailStr;
    }
    
    return nil;
    /* self = @"" || self = @"aaa" || self = @"@" || self = @"aaa@" || self = @"@aaa" _email = null self = @"aa@aaa" _email = @"aa@aaa" */
}

- (BOOL)isEMailString:(NSString *)str
{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z0-9]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    BOOL isEmail = [emailTest evaluateWithObject:str];
    
//    NSLog(@"%d", isEmail);
    
    return isEmail;
}

- (NSString *)getWebPageName
{
    NSString *webPageName = nil;
    NSString *emailStr = [self getEMail];
    if (emailStr != nil) {
        webPageName = [[self appendStringToStringFromArray:[self componentsSeparatedByString:[self getEMail]]] lowercaseString];
    } else {
        webPageName = [self lowercaseString];
    }
    webPageName = [self appendStringToStringFromArray:[webPageName componentsSeparatedByString:@"\n"]];
    
    NSRange range;
    NSArray *webPageNameBeginStrs = @[@"www", @"http", @"htt", @"web page", @"webpage", @"web site", @"website", @"web"];
    
    for (NSString *wPNBS in webPageNameBeginStrs) {
        range = [webPageName rangeOfString:wPNBS];
        if (range.location != NSNotFound) {
            break;
        }
    }
    
    NSMutableString *helpStr = [NSMutableString string];
    
    [helpStr setString:webPageName];
    
    while (range.location != NSNotFound && range.location != 0) {
        
        webPageName = [helpStr substringFromIndex:range.location + range.length];
        webPageName = [[webPageName componentsSeparatedByString:@" "] objectAtIndex:0];
        
        if ([self isUrlString:webPageName]) {
            break;
        } else {
            
            [helpStr deleteCharactersInRange:range];
            for (NSString *wPNBS in webPageNameBeginStrs) {
                range = [helpStr rangeOfString:wPNBS];
                if (range.location != NSNotFound) {
                    break;
                }
            }
        }
    
    }//while
    if ([self isUrlString:webPageName]) {
        return webPageName;
    } else {
        webPageName = [self getUrlFormatFromString:webPageName];
    }
    
//    NSLog(@"WebPage: %@", _webPageName);
    
    return webPageName;
}

- (NSString *)getUrlFormatFromString:(NSString *)str
{
    NSString *helpStr = nil;
    helpStr = str;
    NSRange range = [str rangeOfString:@"."];
    while (range.location != NSNotFound && range.location != 0) {
        NSString *pageName = nil;
        NSString *domenName = nil;
        NSString *webPageName = nil;
        
        pageName = [helpStr substringToIndex:range.location];
        domenName = [helpStr substringFromIndex:range.location + 1];
        
        pageName = [[pageName componentsSeparatedByString:@" "] lastObject];
        domenName = [[domenName componentsSeparatedByString:@" "] objectAtIndex:0];
        
        webPageName = [NSString stringWithFormat:@"%@.%@", pageName, domenName];
        
        if ([self isUrlString:webPageName]) {
            return webPageName;
        } else {
            
            int index = range.location + 1;
            
            //if (index < _helpStr.length) {
            helpStr = [helpStr substringFromIndex:index];
            //}
        }
        
        range = [helpStr rangeOfString:@"."];
        
//        do {
//            
//        } while (range.location != NSNotFound && range.location != 0);
        
        if ([self isUrlString:webPageName]) {
            return webPageName;
        }
        
    }
    
    return nil;
}

- (BOOL) isUrlString:(NSString *)string
{    
    NSString *urlRegEx = @"[A-Z0-9a-z._%+-]+\\.[A-Za-z]{2,4}";
    NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
        
    BOOL isUrl = [urlTest evaluateWithObject:string];
    
    return isUrl;
}

#pragma mark - companyInformations

- (NSString *)getNameCompany
{
    NSString *companyName = nil;
    
    companyName = [self getStringWithoutSomeSeperatedStr];

    if (companyName != nil) {
        companyName = [[companyName componentsSeparatedByString:@"\n"] objectAtIndex:0];
    }
    
    return companyName;
}

#pragma mark - adressInformations

- (NSString *)getAddress
{
    NSString *adress = nil;
    NSArray *addressBeginStrArr = @[@"address:", @"address", @"addres:", @"addres", @"addre:", @"addre"];
    NSRange range;
    
    for (NSString *str in addressBeginStrArr) {
        range = [[self lowercaseString] rangeOfString:str];
        if (range.location != NSNotFound) {
            adress = [self substringFromIndex:range.location + range.length];
            adress = [[adress componentsSeparatedByString:@"\n"] objectAtIndex:0];
            break;
        }
    }

    return adress;
}

#pragma mark - personInfo

- (NSString *)getPersonName
{
    NSString *personName = nil;
    
    personName = [self getStringWithoutSomeSeperatedStr];
    
    NSMutableCharacterSet *charactersToRemove = [NSMutableCharacterSet letterCharacterSet];
    [charactersToRemove addCharactersInString:@" \n"];
    [charactersToRemove invert];
    
    personName = [personName stringByReplaceCharacterSet:charactersToRemove withString:@""];
    
    if (personName != nil) {
        
        NSArray *separatedArr = [personName componentsSeparatedByString:@"\n"];

        for (NSString *str in separatedArr) {
        
            personName = str;
            
            if (TRIMSTR(personName).length > 0) {
                break;
            }
        }
    }
    
    return personName;
}

- (NSString *)getLastName
{
    NSString *lastName = nil;
    NSRange range;
    
    lastName = [self getStringWithoutSomeSeperatedStr];
    
    NSMutableCharacterSet *charactersToRemove = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToRemove addCharactersInString:@" \n"];
    [charactersToRemove invert];
    
    lastName = [lastName stringByReplaceCharacterSet:charactersToRemove withString:@""];
    
    if (lastName != nil) {
        
        NSArray *separatedArr = [lastName componentsSeparatedByString:@"\n"];
        
        for (NSString *str in separatedArr) {
            lastName = str;
            int i = 0;
            
            while (TRIMSTR(lastName).length < 1) {
                
                i++;
                lastName = [self getStringWithoutSomeSeperatedStr];
                
                NSArray *arr = [lastName componentsSeparatedByString:@"\n"];
                if (arr.count > i) {
                    lastName = [arr objectAtIndex:i];
                } else {
                    break;
                }
                
                range = [lastName rangeOfString:@" "];
                
                if (range.location != NSNotFound) {
                    lastName = [[lastName componentsSeparatedByString:@" "] lastObject];
                }
            }
            
            if (i == 0) {
                range = [lastName rangeOfString:@" "];
                
                if (range.location != NSNotFound) {
                    lastName = [[lastName componentsSeparatedByString:@" "] lastObject];
                }
            }
        }
    }
    
    return lastName;
}

- (NSString *)getRank
{
    NSString *rank = nil;
    rank = [self getStringWithoutSomeSeperatedStr];
    rank = [self appendStringToStringFromArray:[self componentsSeparatedByString:[self getPersonName]]];
    NSString *help = rank;
    
    if (rank != nil) {
        NSArray *arr = [help componentsSeparatedByString:@"\n"];
        int i = 0;
        rank = [arr objectAtIndex:i];
        while (TRIMSTR(rank).length < 1) {
            i++;
            if (arr.count > i) {
                rank = [arr objectAtIndex:i];
            } else {
                break;
            }
        }
        
    }
    
    return rank;
}

#pragma mark - general methods

- (NSString *)getStringWithoutSomeSeperatedStr
{
    NSString *withoutStr = nil;
    
    NSString *generalTel = [self getGeneralTel];
    if (generalTel != nil) {
        withoutStr = [self appendStringToStringFromArray:[self componentsSeparatedByString:generalTel]];
    }
    NSString *mobile = [self getMobile];
    if (mobile != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:mobile]];
    }
    NSString *tel = [self getTel];
    if (tel != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:tel]];
    }
    NSString *phone = [self getPhone];
    if (phone != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:phone]];
    }
    NSString *officeMob = [self getOfficeMob];
    if (officeMob != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:officeMob]];
    }
    NSString *fax = [self getFax];
    if (fax != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:fax]];
    }
    NSString *email = [self getEMail];
    if (email != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:email]];
    }
    NSString *webPage = [self getWebPageName];
    if (webPage != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:webPage]];
    }
    NSString *address = [self getAddress];
    if (address != nil) {
        withoutStr = [withoutStr appendStringToStringFromArray:[withoutStr componentsSeparatedByString:address]];
    }
    
    if (!(TRIMSTR(withoutStr).length > 0)) {
        withoutStr = self;
    }
    return withoutStr;
}

@end
