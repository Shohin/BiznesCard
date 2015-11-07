//
//  WebInfo.h
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BaseObject.h"

@interface WebInfo : BaseObject

@property (assign, nonatomic)ID userID;
@property (assign, nonatomic)ID webPageNumber;
@property (retain, nonatomic)NSString *webPageName;

@end
