//
//  BCImagePickerController.m
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BCImagePickerController.h"
#import "ParseText.h"
#import "EditViewController.h"

@interface BCImagePickerController ()
{
    ParseText *_pasText;
}
@end

@implementation BCImagePickerController

@synthesize pickDelegate = _pickDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.delegate = self;
//    self.allowsEditing = YES;
    _pasText = [[ParseText alloc] initWithDataPath:@"tessdata" language:@"eng"];
}

#pragma mark - imagepickerdelegates

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
//    if ([_pickDelegate respondsToSelector:@selector(didPickImage:imagePicker:)]) {
//        [_pickDelegate didPickImage:image imagePicker:self];
//    }
    [_pasText setImage:image];
    
    NSString *recogStr = [_pasText recognizedText];
    
    NSLog(@"\nparseTextfirst\n%@\n", recogStr);
    
    NSMutableCharacterSet *charactersToRemove = [NSMutableCharacterSet alphanumericCharacterSet];
    [charactersToRemove addCharactersInString:@".,-+()@ :/\n"];
    [charactersToRemove invert];
    
    NSString *trimmedReplacement = [recogStr stringByReplaceCharacterSet:charactersToRemove withString:@""];
    
    NSLog(@"\nparseTextsecond\n%@\n", trimmedReplacement);
    
    NSLog(@"WebPage: %@", [trimmedReplacement getWebPageName]);
    NSLog(@"General tel: %@", [trimmedReplacement getGeneralTel]);
    NSLog(@"tel : %@", [trimmedReplacement getTel]);
    NSLog(@"Mobile: %@", [trimmedReplacement getMobile]);
    NSLog(@"Phone: %@", [trimmedReplacement getPhone]);
    NSLog(@"OfficeMobile: %@", [trimmedReplacement getOfficeMob]);
    NSLog(@"Fax: %@", [trimmedReplacement getFax]);
    NSLog(@"Email: %@", [trimmedReplacement getEMail]);
    NSLog(@"person name: %@", [trimmedReplacement getPersonName]);
    NSLog(@"Rank: %@", [trimmedReplacement getRank]);
    NSLog(@"Address: %@", [trimmedReplacement getAddress]);
    
    ContactInfo *conInfo = [[ContactInfo alloc] init];
    conInfo.baseTelephone = [trimmedReplacement getGeneralTel];
    conInfo.mobile = [trimmedReplacement getMobile];
    conInfo.telephone = [trimmedReplacement getTel];
    conInfo.officeMobile = [trimmedReplacement getOfficeMob];
    conInfo.phone = [trimmedReplacement getPhone];
    conInfo.fax = [trimmedReplacement getFax];
    conInfo.email = [trimmedReplacement getEMail];
    conInfo.webPage = [trimmedReplacement getEMail];
    conInfo.personName = [trimmedReplacement getPersonName];
    conInfo.adress = [trimmedReplacement getAddress];
    conInfo.rank = [trimmedReplacement getRank];
    [conInfo setPhones];
    
//    EditViewController *editCon = [[[EditViewController alloc] initWithStyle:UITableViewStyleGrouped withContact:conInfo] autorelease];
//    [self dismissModalViewControllerAnimated:YES];
//    [self.navigationController pushViewController:editCon animated:YES];
}

-(NSString*)formatNumber:(NSString*)mobileNumber
{
    
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
    
    NSLog(@"%@", mobileNumber);
    
    int length = [mobileNumber length];
    if(length > 10) {
        mobileNumber = [mobileNumber substringFromIndex: length-10];
        NSLog(@"%@", mobileNumber);
    }
    return mobileNumber;
}

@end
