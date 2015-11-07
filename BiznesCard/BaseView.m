//
//  BaseView.m
//  BiznesCard
//
//  Created by Shohin on 10/14/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

@synthesize bgImgView = _bgImgView;

- (instancetype)initWithImage:(NSString *)imageName
{
    self = [super init];
    if (self != nil) {
        [self setImageBCView:imageName];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame withImage:(NSString *)imageName
{
    self = [super initWithFrame:frame];
    
    if (self != nil) {
        [self setImageBCView:imageName];
    }
    
    return self;
}

- (void)setImageBCView:(NSString *)imageName
{
    self.backgroundColor = [UIColor greenColor];
    _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    NSAssert(imageName, @"Not found bgImage");
    _bgImgView.frame = self.bounds;
    [self addSubview:_bgImgView];
}

@end
