//
//  EmailInfo.h
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BaseObject.h"

@interface EmailInfo : BaseObject

@property (assign, nonatomic)ID userID;
@property (assign, nonatomic)ID emailNumber;
@property (strong, nonatomic)NSString *email;

@end
