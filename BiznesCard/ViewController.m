//
//  ViewController.m
//  BiznesCard
//
//  Created by Shohin on 10/8/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "ViewController.h"
#import "config.h"
#import "ParseText.h"
#import "BaseView.h"
#import "ContactListsViewController.h"
#import "EditViewController.h"
#import "MBProgressHUD.h"
#import "UIImage+Decod_Resize.h"

@interface ViewController ()
{
    BaseView *bsview;
}
@end

@implementation ViewController

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    DLog(@"home directory: %@", NSHomeDirectory());
    
    bsview = [[BaseView alloc] initWithFrame:self.view.bounds withImage:@""];
    self.view = bsview;
    
    BCButton *takePhoto = [[BCButton alloc] initWithFrame:CGRectMake(90, 50, 140, 50) withTitle:@"Take photo"];
    takePhoto.delegate = self;
    takePhoto.tag = 1;
    [self.view addSubview:takePhoto];
    
    BCButton *select = [[BCButton alloc] initWithFrame:CGRectMake(90, 120, 140, 50) withTitle:@"Select photo"];
    select.delegate = self;
    select.tag = 2;
    [self.view addSubview:select];
    
    BCButton *cards = [[BCButton alloc] initWithFrame:CGRectMake(90, 190, 140, 50) withTitle:@"Cards"];
    cards.delegate = self;
    cards.tag = 3;
    [self.view addSubview:cards];
}

#pragma mark - delegatemethods

- (void)didClick:(BCButton *)sender
{
    switch (sender.tag) {
        case 1:
        case 2: {
            UIImagePickerController *ipcon = [[UIImagePickerController alloc] init];
            ipcon.delegate = self;
            ipcon.allowsEditing = YES;
            switch (sender.tag) {
                case 1: {
                    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                        ipcon.sourceType = UIImagePickerControllerSourceTypeCamera;
                        ipcon.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
                    } else {
                        NSLog(@"Error in open camera");
                    }
                }
                    break;
                case 2: {
                    ipcon.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                }
                    break;
                default:
                    break;
            }
            [self presentViewController:ipcon animated:YES completion:nil];
        }
            break;
        case 3: {
            ContactListsViewController *conList = [[ContactListsViewController alloc] initWithStyle:UITableViewStylePlain];
            [self.navigationController pushViewController:conList animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - image picker delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIImage *originalImage = (UIImage *)info[UIImagePickerControllerOriginalImage];
        
        ParseText *pasText = [[ParseText alloc] initWithDataPath:@"tessdata" language:@"eng"];
        [pasText setImage:originalImage];
        
        NSString *recogStr = [pasText recognizedText];
        
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
        
        NSData *data = UIImagePNGRepresentation(originalImage);
        NSLog(@"length1: %d",[data length]);
        
        CGFloat height = 500.0f;  // or whatever you need
        CGFloat width = (height / originalImage.size.height) * originalImage.size.width;
        
        // Resize the image
        UIImage * image = [originalImage resizedImage:CGSizeMake(width, height) interpolationQuality:kCGInterpolationDefault];
        data = UIImagePNGRepresentation(image);
        NSLog(@"length2: %d",[data length]);
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:picker.view animated:YES];
            [picker dismissModalViewControllerAnimated:YES];
            EditViewController *editCon = [[EditViewController alloc] initWithStyle:UITableViewStyleGrouped withContact:conInfo];
            [self.navigationController pushViewController:editCon animated:YES];
        });
    });
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

@end
