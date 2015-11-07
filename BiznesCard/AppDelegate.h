//
//  AppDelegate.h
//  BiznesCard
//
//  Created by Shohin on 10/8/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCNavigationController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) BCNavigationController *navCon;

@end
