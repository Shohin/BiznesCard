//
//  BCButton.m
//  BiznesCard
//
//  Created by Shohin on 10/8/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BCButton.h"

@implementation BCButton

@synthesize titleBCButton = _titleBCButton;
@synthesize delegate = _delegate;

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        self.backgroundColor = [UIColor whiteColor];
        [self addTarget:self action:@selector(clickBCButton:) forControlEvents:UIControlEventTouchUpInside];
        _titleBCButton = [[UILabel alloc] initWithFrame:self.bounds];
        _titleBCButton.textAlignment = NSTextAlignmentCenter;
        _titleBCButton.tag = 1;
        _titleBCButton.text = title;
        //_titleBCButton.textColor = [UIColor redColor];
        _titleBCButton.backgroundColor = [UIColor blueColor];
        [self addSubview:_titleBCButton];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withBgImage:(NSString *)imageName
{
    self = [self initWithFrame:frame withTitle:title];
    if (self != nil) {
        UIImage *bgImg = [UIImage imageNamed:imageName];
        
        NSAssert(bgImg, @"Not found bgImage");
        
        [self setBackgroundImage:bgImg forState:UIControlStateNormal];
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withTitle:(NSString *)title withImage:(NSString *)imageName
{
    self = [self initWithFrame:frame withTitle:title];

    if (self != nil) {
        
        CGSize subViewSize = self.bounds.size;
        float widthImage = subViewSize.width / 3;
        float widthTitle = 2 * widthImage;
        
        float height = subViewSize.height;
        
        NSLog(@"widIm: %g", widthImage);
        NSLog(@"widthT: %g", widthTitle);
        
        
        UIImage *img = [UIImage imageNamed:imageName];
        NSAssert(img, @"Not found img");
        _imageViewBCButton = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2, widthImage - 6, height - 4)];
        _imageViewBCButton.tag = 2;
        _imageViewBCButton.image = img;
        [self addSubview:_imageViewBCButton];
        
        _titleBCButton.frame = CGRectMake(widthImage, 0, widthTitle, height);
    }
    
    return self;
}

- (void)clickBCButton:(BCButton *)sender
{
    if ([_delegate respondsToSelector:@selector(didClick:)]) {
        [_delegate didClick:sender];
    } else {
        NSLog(@"Error in delegate");
    }
}



@end
