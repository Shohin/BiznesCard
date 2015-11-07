//
//  CompanyInfo.h
//  BiznesCard
//
//  Created by Shohin on 11/27/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BaseObject.h"

@interface CompanyInfo : BaseObject

@property (nonatomic, assign)ID userID;
@property (nonatomic, assign)ID companyNumber;
@property (nonatomic, strong)NSString *companyName;
@property (nonatomic, strong)NSString *companyDescription;

@end
