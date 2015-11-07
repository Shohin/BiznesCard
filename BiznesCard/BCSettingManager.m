//
//  BCSettingManager.m
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BCSettingManager.h"

@implementation BCSettingManager

static const BCSettingManager *_instance = nil;

+ (const BCSettingManager *)sharedManager {
	static dispatch_once_t pred;
	
    dispatch_once(&pred, ^{
		_instance = [[BCSettingManager alloc] init];
    });
	
	return _instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _rotatableViewIdentifier = [[NSMutableString alloc] init];
    }
    return self;
}

- (NSString *)setAccessForRotation:(BOOL)access {
	_viewRotationAccess = access;
	NSDate *date = [NSDate date];
	[_rotatableViewIdentifier setString:[NSString stringWithFormat:@"%f", [date timeIntervalSince1970]]];
	return _rotatableViewIdentifier;
}

-(void)copyDBFile{
    NSString *copy = [[NSUserDefaults standardUserDefaults] objectForKey:@"copyDatabase"];
    if (copy) {
        return;
    }
    NSError *error = nil;
    NSFileManager *file_man = [NSFileManager defaultManager];
    if ([file_man createDirectoryAtPath:STORE_DIRECTORY withIntermediateDirectories:YES attributes:nil error:&error]) {
        
        if ([file_man createDirectoryAtPath:STORE_DIRECTORY withIntermediateDirectories:YES attributes:nil error:&error]) {
            
            NSString *db_file = @"baza.sqlite";// [NSString stringWithFormat:@"%f.db", [[NSDate date] timeIntervalSince1970]];
            
            NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"bcDataBase"];
            NSString *temp = [[NSString alloc] initWithFormat:@"%@/%@", STORE_DIRECTORY, db_file];
            
            BOOL success = [file_man copyItemAtPath:defaultDBPath toPath:temp error:&error];
            
            if (success) {
                [[NSUserDefaults standardUserDefaults] setObject:db_file forKey:FIELD_DB];
                [[NSUserDefaults standardUserDefaults] setObject:@"Baza copy" forKey:@"copyDatabase"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
            }
        }
    }
}

- (NSString *) getDBPath{
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    return [documentsDir stringByAppendingPathComponent:@"dataBase.sqlite"];
}

@end
