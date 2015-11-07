//
//  BCImagePickerController.h
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCImagePickerController;

@protocol BCImagePickerDelegate <NSObject>

- (void)didPickImage:(UIImage *)img imagePicker:(BCImagePickerController *)pickCon;

@end

@interface BCImagePickerController : UIImagePickerController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (assign, nonatomic)id<BCImagePickerDelegate>pickDelegate;

@end
