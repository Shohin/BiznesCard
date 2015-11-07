//
//  BaseView.h
//  BiznesCard
//
//  Created by Shohin on 10/14/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseView : UIView

@property (nonatomic, strong) UIImageView* bgImgView;

- (instancetype)initWithImage:(NSString *)imageName;
- (instancetype)initWithFrame:(CGRect)frame withImage:(NSString *)imageName;

@end
