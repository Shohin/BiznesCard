//
//  TelephoneInfo.h
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BaseObject.h"

@interface TelephoneInfo : BaseObject

@property (assign, nonatomic)ID userID;
@property (assign, nonatomic)ID telNumber;
@property (strong, nonatomic)NSString *telephoneNumber;

@end
