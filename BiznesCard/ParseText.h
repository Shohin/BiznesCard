//
//  ParseText.h
//  BiznesCard
//
//  Created by Shohin on 10/14/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseText : NSObject
{
    NSString* _dataPath;
    NSString* _language;
    NSMutableDictionary* _variables;
}

- (id)initWithDataPath:(NSString *)dataPath language:(NSString *)language;
- (void)setVariableValue:(NSString *)value forKey:(NSString *)key;
- (void)setImage:(UIImage *)image;
- (BOOL)setLanguage:(NSString *)language;
- (BOOL)recognize;
- (NSString *)recognizedText;

@end
