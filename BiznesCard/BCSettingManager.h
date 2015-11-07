//
//  BCSettingManager.h
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCSettingManager : NSObject{
    NSDictionary *    _languageDict;
    
    BOOL  _viewRotationAccess;
    NSMutableString *_rotatableViewIdentifier;
    
}


+ (const BCSettingManager *)sharedManager;

- (NSString *)setAccessForRotation:(BOOL)access;

-(void)copyDBFile;

@end
