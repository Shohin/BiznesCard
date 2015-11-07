//
//  BCButton.h
//  BiznesCard
//
//  Created by Shohin on 10/8/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BCButton;

@protocol BCButtonDelegate <NSObject>

- (void)didClick:(BCButton *)sender;

@end

@interface BCButton : UIButton

@property (nonatomic, retain) UILabel *titleBCButton;
@property (nonatomic, retain) UIImageView *imageViewBCButton;

@property (nonatomic, assign) id<BCButtonDelegate> delegate;


- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title;
- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withBgImage:(NSString *)imageName;
- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withImage:(NSString *)imageName;


@end
