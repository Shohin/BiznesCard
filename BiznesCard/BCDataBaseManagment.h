//
//  BCDataBaseManagment.h
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import <dispatch/dispatch.h>
#define STORE_DIRECTORY     [NSString stringWithFormat:@"%@/Library/Private Documents", NSHomeDirectory()]
#define  FIELD_DB @"fileName"

@interface BCDataBaseManagment : NSObject
{
    NSMutableDictionary							*_container;
	
	// dispatch queue is used for manipulating with method calls
	// to perform them on background thread (by dispatch_async)
	dispatch_queue_t							_OMQueue;
	
	// db for string fields of the SCObjects
	sqlite3										*_object_context_db;
	
    // system containers
	NSMutableDictionary							*_ivar_lists;
    NSMutableDictionary                         *_field_lists;
    NSMutableDictionary                         *_tables;                   // contains table names with [[.. class] description] key
    NSMutableArray                              *_class_names;
    
    BOOL                                        _isImporting;
}

// singletone
+ (const BCDataBaseManagment *)sharedManager;
- (BOOL)isImporting;
- (sqlite3 *)sharedConnection;
- (dispatch_queue_t)sharedQueue;

- (void)markAsDeletedObject:(id)obj;
- (void)deleteObject:(id)obj;
//- (void)deleteObjectByhashID:(NSString*)hashID class:(Class)objClass;
//- (void)deleteMemberWithEmail:(NSString*)email;

- (void)removeDBFile;
- (void)createDBFile;

- (void)createContainer;
- (void)resetContainer;

/* **** Object setters **** */

/* one way road for any object created in application */
- (void)updateObject:(id)obj callback:(void (^)(id obj))callback;
- (void)storeObject:(id)obj callback:(void (^)(id obj))callback;

// reload object list methods
- (void)reloadObjectsOfClass:(Class)clasName callback:(void (^)(id obj))callback;

-(NSArray *)conatactCards;

- (void)saveImage:(UIImage*)image name:(NSString*)name callback:(void (^)(id obj))callback;
- (void)removeImageFromPath:(NSString *)imgPath;


// check for existing in local database
- (BOOL)containsObject:(id)obj;
- (void)deletedObjects:(Class)classname callback:(void (^)(id obj))callback;

@end
