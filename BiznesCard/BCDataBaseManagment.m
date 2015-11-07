//
//  BCDataBaseManagment.m
//  BiznesCard
//
//  Created by Shohin on 11/22/13.
//  Copyright (c) 2013 Shohin. All rights reserved.
//

#import "BCDataBaseManagment.h"

#define FIELD_CARD_CONTAINER               @"card_container"

// used for storing encryption key in NSUserDefaults
#define FIELD_OBJECT_LASTID						@"last_obj_id"

// a constant for GCD dispatch
#define OBJECT_MANAGER_QUEUE					"com.BC.BC.object_manager_queue"

#define FIELD_VARIABLE							@"var"

@interface BCDataBaseManagment ()

- (void)createDataBase;
- (void)dumpSystemData;

// collection of object with the same class name
- (id)objectsByClass:(Class)className;


// commit query to database with parameters
- (void)commit:(NSString *)query_s :(NSMutableArray *)values :(id)obj;

- (int)lastObjectID;

- (NSMutableDictionary *)store:(id)obj table:(NSString *)table _id:(ID)_id shouldReturn:(BOOL)shouldReturn callback:(dispatch_block_t)callback;

// we should use parameters if we are selecting strings
//- (void)select:(NSString *)check_query parameters:(NSArray *)parameters callback:(void (^)(NSArray *))callback;

// simple select
- (ID)select:(NSString *)check_query;

- (void)delete:(NSString *)table _id:(ID)_id;

void toUpper(sqlite3_context *context, int argc, sqlite3_value **argv);

@end

@implementation BCDataBaseManagment

static const BCDataBaseManagment *_instance = nil;

- (id)init {
	self = [super init];
	if (self) {
        
		_OMQueue = dispatch_queue_create(OBJECT_MANAGER_QUEUE, NULL);
        
		_container      = [[NSMutableDictionary alloc] initWithCapacity:0];
        _field_lists    = [[NSMutableDictionary alloc] initWithCapacity:0];
        _tables         = [[NSMutableDictionary alloc] initWithCapacity:0];
        
        // dump main object's ivar lists for RTTI optimization (ran just once)
        [self dumpSystemData];
        [self createDataBase];
        [self createContainer];
        
        _isImporting = NO;
	}
	return self;
}

- (void)createContainer {
    //      reload contactinfo objects
    NSMutableArray *_card_object_container = [[NSMutableArray alloc] initWithCapacity:0];
    [_container setObject:_card_object_container forKey:FIELD_CARD_CONTAINER];
    [self reloadObjectsOfClass:[ContactInfo class] callback:^(id obj) {
        [_card_object_container addObjectsFromArray:obj];
    }];    
}

- (void)resetContainer {
    
    [_container removeAllObjects];
}

+ (const BCDataBaseManagment *)sharedManager {
	static dispatch_once_t pred;
	
    dispatch_once(&pred, ^{
		_instance = [[BCDataBaseManagment alloc] init];
    });
	
	return _instance;
}

- (sqlite3 *)sharedConnection {
    return _object_context_db;
}

- (dispatch_queue_t)sharedQueue {
    return _OMQueue;
}

- (BOOL)isImporting {
    return _isImporting;
}


- (NSString *)keyRegex {
    return @"[0-9]{1,}$";
}

- (NSString *)staticClassNameRegex {
    return @"NS[a-zA-Z]{1,}";
}

- (NSString *)dynamicClassNameRegex {
    return @"[a-zA-Z]{1,}";
}

- (int)lastObjectID {
	NSNumber *last_object_id = [[NSUserDefaults standardUserDefaults] objectForKey:FIELD_OBJECT_LASTID];
    
    ID _last_object_id = 499;
	if (last_object_id) {
		_last_object_id = [last_object_id longLongValue];
		_last_object_id++;
	}
    
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:_last_object_id] forKey:FIELD_OBJECT_LASTID];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    return _last_object_id;
}

- (void)replaceObject:(id)obj {
    
    ID __id = [obj _id];
    NSMutableArray *temp = nil;
    temp = [self objectsByClass:[obj class]];
    
    NSInteger search_idx = NSNotFound;
    for (int i = 0; i < [temp count]; i++) {
        
        id obj2 = [temp objectAtIndex:i];
        ID _id = [obj2 _id];
        if (_id == __id) {
            search_idx = i;
            break;
        }
    }
    
    // if there is no object with such id - object is new
    
    if (search_idx != NSNotFound){
        [temp removeObjectAtIndex:search_idx];
        [temp addObject:obj];
    } else {
        [temp addObject:obj];
    }
}

- (void)updateObject:(id)obj callback:(void (^)(id obj))callback {
	if ([obj respondsToSelector:@selector(_id)]) {
        [self store:obj table:[_tables objectForKey:[[obj class] description]] _id:[obj _id] shouldReturn:NO callback:^{}];
        
        // replacing object in local container
        [self replaceObject:obj];
        
        if (callback) {
            callback(obj);
        }
        
	} else
		NSAssert(false, @"object doesn't recognize selector - (ID)id");
}

- (void)storeObject:(id)obj callback:(void (^)(id obj))callback {
	if ([obj respondsToSelector:@selector(_id)]) {
        
        
        if ([obj _id] == 0) {
            [obj set_id:[self lastObjectID]];
        }
        
        [self store:obj table:[_tables objectForKey:[[obj class] description]] _id:[obj _id] shouldReturn:NO callback:^{}];
        
        // replacing or adding object in local container
        [self replaceObject:obj];
        
        // call callback on current queue
        if (callback)
            callback(obj);
	} else
		NSAssert(false, @"object doesn't recognize selector -(ID)id");
}

// recourse methods for extracting all the inner SC-objects
- (NSMutableDictionary *)store:(id)obj table:(NSString *)table _id:(ID)_id shouldReturn:(BOOL)shouldReturn callback:(dispatch_block_t)callback {
    
	// remove string fields
	// save them into database
	// ...
	
	//	NSDate *timestamp = [NSDate date];
	if ([obj respondsToSelector:@selector(ivar_list)]) {
		// check out all string fields
		NSMutableDictionary *list = [_ivar_lists objectForKey:[[obj class] description]];
		if (!list) {
			list = [obj ivar_list];
		}
        
		NSMutableDictionary *data_to_store = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSMutableString *ivar_name = [[NSMutableString alloc] initWithCapacity:0];
        
		for (id key in [list allKeys]) {
			
            //            NSTextCheckingResult *result = [_keyRegex firstMatchInString:key options:NSLiteralSearch range:NSMakeRange(0, [key length])];
            //            NSRange range = [result range];
            //            result = nil;
            NSString *keyRegexFormat = [self keyRegex];
            
            NSString *__key = [key substringWithRange:[key rangeOfString:keyRegexFormat options:NSRegularExpressionSearch]];
            NSAssert(__key, @"key was parsed incorrectly!");
            
			unsigned int ivar_count = [__key intValue];
            __key = nil;
            
			NSData *ivar_list_v = [list objectForKey:key];
			Ivar *ivar_list_p = (Ivar *)[ivar_list_v bytes];
			for (int i = 0; i < ivar_count; i++) {
                NSString *ivarName = [[NSString alloc] initWithUTF8String:ivar_getName(i[ivar_list_p])];
				[ivar_name setString:ivarName];
				id ivar_val = [obj valueForKey:ivar_name];
				if ([ivar_val isKindOfClass:[NSString class]] || [ivar_val isKindOfClass:[NSNumber class]]) {
					
					[data_to_store setObject:ivar_val forKey:ivar_name];
				}
			}
		}
		
		// data to store is NSMutableDictionary
		if (!shouldReturn)
			if ([[data_to_store allKeys] count])
				[self check:table _id:_id data:data_to_store];
		
        if (callback)
            callback();
        
		return shouldReturn ? data_to_store : nil;
	}
    
	return nil;
}

- (void)deleteObject:(id)obj {
    
    NSMutableArray *container = [self objectsByClass:[obj class]];
    [container removeObject:obj];
    
    NSMutableString *delete_query = [[NSMutableString alloc] initWithCapacity:0];
    [delete_query appendFormat:@"delete from %@ where _id=%lld", [_tables objectForKey:[[obj class] description]], [obj _id]];
    [self commit:delete_query :nil :nil];
}

- (void)markAsDeletedObject:(id)obj {
    [self storeObject:obj callback:nil];
}




#pragma mark - Fetch methods

- (void)reloadObjectsOfClass:(Class)class callback:(void (^)(id obj))callback {
    
    NSArray *container = [self objectsByClass:class];
    if ([container count]) {
        if (callback)
            callback(container);
    } else {
        NSString *query = [NSString stringWithFormat:@"select * from %@", [class description]];
        [self select:query parameters:nil deleted:NO callback:^(NSArray *result) {
            NSMutableArray *resultArr = [[NSMutableArray alloc] initWithCapacity:0];
            for (id _obj in result) {
                id obj = [[class alloc] initWithDictionary:_obj];
                [resultArr addObject:obj];
            }
            if (callback)
                callback(resultArr);
        }];
    }
}





#pragma mark - object methods

- (id)objectsByClass:(Class)className {
    
    NSMutableArray *container = nil;
    
    if ([[className description] isEqualToString:[[ContactInfo class] description]]) {
        container = [_container objectForKey:FIELD_CARD_CONTAINER];
    }
    
    return container;
}

- (BOOL)containsObject:(id)obj {
    
    BOOL contains = NO;
    NSMutableArray *items = [self objectsByClass:[obj class]];
    for (id _obj in items) {
        if ([_obj _id] == [obj _id]) {
            contains = YES;
            break;
        }
    }
    return contains;
}

#pragma mark - deletion objects

- (void)deletedObjects:(Class)classname callback:(void (^)(id obj))callback {
    
    NSString *query = [NSString stringWithFormat:@"select * from %@", [classname description]];
    
    [self select:query parameters:nil deleted:YES callback:^(NSArray *result) {
        NSMutableArray *resultArr = [[NSMutableArray alloc] initWithCapacity:0];
        for (id _obj in result) {
            //            id obj = [[classname alloc] initWithDictionary:_obj];
            //            if ([obj deleted]) {
            //                [resultArr addObject:obj];
            //            }
        }
        if (callback)
            callback(resultArr);
    }];
    
}

#pragma mark - database methods

// this method is for insert and update statements only
// parameter is used for setting row_id of the additional object
- (void)commit:(NSString *)query_s :(NSMutableArray *)values :(id)obj {
    
    NSString *query_s_copy = [query_s copy];
    
	void (^block)(NSString *query_s) = ^(NSString *query_s){
        
        // check if record with such _id exists or not
        sqlite3_stmt *_result = NULL;
        const char *query_c = [query_s UTF8String];
        if (sqlite3_prepare_v2(_object_context_db, query_c, -1, &_result, NULL) == SQLITE_OK) {
            
            if (values)
                for (int i = 1; i <= values.count; i++) {
                    id value = [values objectAtIndex:i - 1];
                    if ([value isKindOfClass:[NSNumber class]]) {
                        value = [value stringValue];
                    }
                    const char *UTF8Param = [value UTF8String];
                    sqlite3_bind_text(_result, i, UTF8Param, -1, SQLITE_STATIC);
                }
            
            if (sqlite3_step(_result) == SQLITE_DONE) {
                //                if (obj) {
                //                    if ([obj respondsToSelector:@selector(setOiD:)]) {
                //                        ID rowID = sqlite3_last_insert_rowid(_object_context_db);
                //                        [obj setOiD:rowID];
                //                    }
                //                }
                sqlite3_finalize(_result);
            } else
                NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_object_context_db));
        } else {
            //		DLog(@"ERROR IN COMMIT COMMAND: %@\n error: %s", query_s ,sqlite3_errmsg(_object_context_db));
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_object_context_db));
        }
    };
    
    if (dispatch_get_current_queue() == _OMQueue)
        block(query_s_copy);
    else
        dispatch_async(_OMQueue, ^{ block(query_s_copy); });
}


#pragma mark - private methods

- (void)delete:(NSString *)table _id:(ID)_id {
	NSString *delete_query_s = [[NSString alloc] initWithFormat:@"delete from %@ where _id = %lld;", table, _id];
	[self commit:delete_query_s :nil :nil];
}

- (void)insert:(NSString *)table _id:(ID)_id data:(id)data_to_store {
    
	NSMutableString *insert_query_s = [[NSMutableString alloc] initWithCapacity:0];
	NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
	
	int size_of_array = 0;
	
	if ([data_to_store isKindOfClass:[NSMutableArray class]])
		size_of_array = [data_to_store count];
	
	int counter = size_of_array > 0 ? size_of_array : 1;
	
	for (int i = 0; i < counter; i++) {
		
		NSMutableDictionary *working_dictionary = size_of_array > 0 ? [data_to_store objectAtIndex:i] : data_to_store;
		
		[values removeAllObjects];
		[insert_query_s setString:@""];
		[insert_query_s appendFormat:@"insert into %@ (", table];
        
		id obj = [working_dictionary objectForKey:FIELD_VARIABLE];
		[working_dictionary removeObjectForKey:FIELD_VARIABLE];
		NSArray *_keys = [working_dictionary allKeys];
        
		for (id key in _keys) {
            if ([key isEqual:[_keys lastObject]]) {
                [insert_query_s appendFormat:@"%@)", key];
            } else {
                [insert_query_s appendFormat:@"%@, ", key];
            }
		}
		[insert_query_s appendString:@" values ("];
		for (id key in _keys) {
			id ivar_val = [working_dictionary objectForKey:key];
            if ([key isEqual:[_keys lastObject]]) {
                [insert_query_s appendFormat:@"?);"];
            } else {
                [insert_query_s appendFormat:@"?, "];
            }
			[values addObject:ivar_val];
		}
        
		[self commit:insert_query_s :values :obj];
	}
}

- (void)update:(NSString *)table _id:(ID)_id data:(id)data_to_store {
	
	NSMutableString *update_query_s = [[NSMutableString alloc] initWithCapacity:0];
	[update_query_s appendFormat:@"update %@ set ", table];
	
	NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:0];
	NSArray *temp = [data_to_store allKeys];
	// preparing
	for (id key in temp) {
		id ivar_val = [data_to_store objectForKey:key];
		if (![key isEqual:[temp lastObject]])
			[update_query_s appendFormat:@"%@=?, ", key];
		else
			[update_query_s appendFormat:@"%@=?", key];
		[values addObject:ivar_val];
	}
    
	[update_query_s appendFormat:@" where _id = %lld;", _id];
	[self commit:update_query_s :values :nil];
}


- (void)select:(NSString *)check_query parameters:(NSArray *)parameters deleted:(BOOL)deleted callback:(void (^)(NSArray *))callback {
    dispatch_block_t block = ^{
        
        NSMutableArray *ret_val = [[NSMutableArray alloc] initWithCapacity:0];
        
        // undeleted object only
        NSMutableString *query = [[NSMutableString alloc] initWithString:check_query];
        //        if (deleted) {
        //            [query appendString:@" where deleted = 1"];
        //        } else {
        //            [query appendString:@" where deleted = 0"];
        //        }
        
        [query appendString:@" order by _id"];
        
        // simple select
        const char *check_query_c = [query UTF8String];
        sqlite3_stmt *statement = NULL;
        
        if (sqlite3_prepare_v2(_object_context_db, check_query_c, -1, &statement, NULL) == SQLITE_OK) {
            
            for (int i = 1; i <= parameters.count; i++) {
                sqlite3_bind_text(statement, i, [[parameters objectAtIndex:i - 1] UTF8String], -1, SQLITE_STATIC);
            }
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                int columns = sqlite3_column_count(statement);
                NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:columns];
                
                for (int i = 0; i<columns; i++) {
                    const char *name = sqlite3_column_name(statement, i);
                    
                    NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
                    int type = sqlite3_column_type(statement, i);
                    
                    switch (type) {
                        case SQLITE_INTEGER:
                        {
                        int value = sqlite3_column_int(statement, i);
                        [result setObject:[NSNumber numberWithInt:value] forKey:columnName];
                        break;
                        }
                        case SQLITE_FLOAT:
                        {
                        float value = sqlite3_column_int(statement, i);
                        [result setObject:[NSNumber numberWithFloat:value] forKey:columnName];
                        break;
                        }
                        case SQLITE_TEXT:
                        {
                        const char *value = (const char*)sqlite3_column_text(statement, i);
                        [result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
                        break;
                        }
                            
                        case SQLITE_BLOB:
                            break;
                        case SQLITE_NULL:
                            [result setObject:[NSNull null] forKey:columnName];
                            break;
                            
                        default:
                        {
                        const char *value = (const char *)sqlite3_column_text(statement, i);
                        [result setObject:[NSString stringWithCString:value encoding:NSUTF8StringEncoding] forKey:columnName];
                        break;
                        }
                    }
                }
                
                [ret_val addObject:result];
            }
            
            sqlite3_finalize(statement);
            
        } else {
            NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_object_context_db));
        }
        
        callback([ret_val count] ? ret_val : nil);
    };
    
    if (dispatch_get_current_queue() == _OMQueue)
        block();
    else
        dispatch_async(_OMQueue, block);
}

- (ID)select:(NSString *)check_query {
    ID ret_val = 0;
    //    check_query = @"select counterID from Cook where _id=499;";
    // simple select
    const char *check_query_c = [check_query UTF8String];
    sqlite3_stmt *result = NULL;
    
    if (sqlite3_prepare_v2(_object_context_db, check_query_c, -1, &result, NULL) == SQLITE_OK) {
        
        if (sqlite3_step(result) == SQLITE_ROW) {
            // the row is already exist
            ret_val = sqlite3_column_int64(result, 0);
        } else{
            
        }
        
        sqlite3_finalize(result);
        
    } else {
        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_object_context_db));
    }
    
    return ret_val;
}


- (void)check:(NSString *)table _id:(ID)_id data:(id)data_to_store {
	
    id localCopyOfTheDataToStore = [data_to_store isKindOfClass:[NSMutableArray class]] ? [[NSMutableArray alloc] initWithArray:data_to_store] : [[NSMutableDictionary alloc] initWithDictionary:data_to_store];
    
    void (^block)(id localCopyOfTheDataToStore) = ^(id localCopyOfTheDataToStore){
        
        if ([table isEqualToString:[[ContactInfo class] description]]){
            
            NSString *check_query_s = [[NSString alloc] initWithFormat:@"select _id from %@ where _id = %lld;", table, _id];
            
            if ([self select:check_query_s]) {
                [self update:table _id:_id data:localCopyOfTheDataToStore];
            } else {
                [self insert:table _id:_id data:localCopyOfTheDataToStore];
            }
        }
    };
    
    if (dispatch_get_current_queue() == _OMQueue)
        block(localCopyOfTheDataToStore);
    else
        dispatch_async(_OMQueue, ^{ block(localCopyOfTheDataToStore); });
}


#pragma mark - main methods

- (void)dumpSystemData {
    ContactInfo *conInfo = [[ContactInfo alloc] init];
    
    NSArray *arr = [[NSArray alloc] initWithObjects:conInfo,nil];
    
    _ivar_lists = [[NSMutableDictionary alloc] initWithCapacity:0];
    NSMutableDictionary *_fields = [[NSMutableDictionary alloc] initWithCapacity:0];
    _class_names = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (id obj in arr) {
        NSString *class_name = [[obj class] description];
        [_class_names addObject:class_name];
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:[obj ivar_list] copyItems:NO];
        [_ivar_lists setObject:temp forKey:class_name];
        
        [_fields removeAllObjects];
        [self databaseFieldsForList:temp data:_fields];
        [_field_lists setObject:[_fields mutableCopy] forKey:class_name];
    }
    
    [_tables setObject:[[ContactInfo class] description] forKey:[[ContactInfo class] description]];    
}


- (void)configureCreateQueryForFields:(NSDictionary *)fields query:(NSMutableString *)query {
    
    NSArray *keys = [fields allKeys];
    
    for (NSString *field in keys) {
        if (![field isEqualToString:@"_id"]) {
            if ([field isEqualToString:[keys lastObject]])
                [query appendFormat:@"%@ %@);", field, [fields objectForKey:field]];
            else
                [query appendFormat:@"%@ %@, ", field, [fields objectForKey:field]];
        }
    }
}

- (void)removeDBFile {
    
    NSString *db_file = [[NSUserDefaults standardUserDefaults] objectForKey:FIELD_DB];
    NSString *db_filepath = [NSString stringWithFormat:@"%@/%@", STORE_DIRECTORY, db_file];
    
    NSError *error = nil;
    NSFileManager *file_man = [NSFileManager defaultManager];
    if ([file_man fileExistsAtPath:db_filepath]) {
        [file_man removeItemAtPath:db_filepath error:&error];
        
        if (error) {
            DLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)createDBFile {
    
    [self dumpSystemData];
    [self createDataBase];
}

- (void)createDataBase {
	const char *dbpath = NULL;
	
	NSError *error = nil;
	NSFileManager *file_man = [NSFileManager defaultManager];
	
	if ([file_man createDirectoryAtPath:STORE_DIRECTORY withIntermediateDirectories:YES attributes:nil error:&error]) {
		
        if ([file_man createDirectoryAtPath:STORE_DIRECTORY withIntermediateDirectories:YES attributes:nil error:&error]) {
            dbpath = [[[NSString alloc] initWithFormat:@"%@/%@", STORE_DIRECTORY, [[NSUserDefaults standardUserDefaults] objectForKey:FIELD_DB]] UTF8String];
            
 			if (sqlite3_open_v2(dbpath, &_object_context_db, SQLITE_OPEN_READWRITE, NULL) == SQLITE_OK) {
				// database opened successfully
				// need to create table if it does not exist
                // sqlite3_trace(_object_context_db, &traceQuery, NULL);
                sqlite3_create_function(_object_context_db, "toUpper", 1, SQLITE_ANY, NULL, &toUpper, NULL, NULL);
                
                NSString *create_query_format = @"PRAGMA encoding = 'UTF-8'; create table if not exists %@ (_id integer primary key autoincrement, ";
                NSMutableString *create_statement = [[NSMutableString alloc] initWithCapacity:0];
                
                for (id class_name in _class_names) {
                    NSString *table = [_tables objectForKey:class_name];
                    [create_statement setString:@""];
                    [create_statement appendFormat:create_query_format, table];
                    [self configureCreateQueryForFields:[_field_lists objectForKey:class_name] query:create_statement];
                    if (sqlite3_exec(_object_context_db, [create_statement UTF8String], NULL, NULL, nil) == SQLITE_OK)
                        continue;
                    else
                        // error
                        NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(_object_context_db));
                }
                
                } else
                    // failed to open database
                    NSAssert(false, @"error in opening database");
        } else
            DLog(@"%@", [error localizedDescription]);
    } else
        DLog(@"%@", [error localizedDescription]);
}


- (void)databaseFieldsForList:(NSDictionary *)_ivar_list data:(NSMutableDictionary *)data {
    
    for (id key in [_ivar_list allKeys]) {
        
        NSString *keyRegexFormat = [self keyRegex];
        
        NSString *__key = [key substringWithRange:[key rangeOfString:keyRegexFormat options:NSRegularExpressionSearch]];
        NSAssert(__key, @"key was parsed incorrectly!");
        
        unsigned int ivar_count = [__key intValue];
        __key = nil;
        
        NSData *ivar_list_v = [_ivar_list objectForKey:key];
        
        Ivar *ivar_list_p = (Ivar *)[ivar_list_v bytes];
        
        for (int _i = 0; _i < ivar_count; _i++) {
            const char *ivar_type = ivar_getTypeEncoding(_i[ivar_list_p]);
            
            NSString *staticClassName1 = [[NSString alloc] initWithUTF8String:@encode(NSString)];
            NSString *staticClassNameRegex = [self staticClassNameRegex];
            NSRange rangeOfFirstMatch = [staticClassName1 rangeOfString:staticClassNameRegex options:NSRegularExpressionSearch];
            
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                staticClassName1 = [staticClassName1 substringWithRange:rangeOfFirstMatch];
            }
            
            NSString *staticClassName2 = [[NSString alloc] initWithUTF8String:@encode(NSTimeInterval)];
            NSString *staticClassName3 = [[NSString alloc] initWithUTF8String:@encode(ID)];
            NSString *staticClassName4 = [[NSString alloc] initWithUTF8String:@encode(int)];
            NSString *staticClassName5 = [[NSString alloc] initWithUTF8String:@encode(BOOL)];
            NSArray *staticClassNames = [[NSArray alloc] initWithObjects:staticClassName1, staticClassName2, staticClassName3, staticClassName4, staticClassName5, nil];
            
            NSString *dynamicClassName = [[NSString alloc] initWithUTF8String:ivar_type];
            NSString *dynamicClassNameRegex = [self dynamicClassNameRegex];
            rangeOfFirstMatch = [dynamicClassName rangeOfString:dynamicClassNameRegex options:NSRegularExpressionSearch];
            
            if (!NSEqualRanges(rangeOfFirstMatch, NSMakeRange(NSNotFound, 0))) {
                dynamicClassName = [dynamicClassName substringWithRange:rangeOfFirstMatch];
            }
            
            if ([staticClassNames containsObject:dynamicClassName]) {
                __block NSString *ivar_name = [[NSString alloc] initWithUTF8String:ivar_getName(_i[ivar_list_p])];
                
                //                NSInteger search_idx = [data indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                //
                //                    if ([ivar_name isEqualToString:obj])
                //                        *stop = YES;
                //
                //                    return *stop;
                //                }];
                //
                //                if (search_idx == NSNotFound)
                //                    [data addObject:ivar_name];
                
                if ([staticClassName1 isEqualToString:dynamicClassName]) {
                    [data setObject:@"varchar(2048)" forKey:ivar_name];
                } else if ([staticClassName2 isEqualToString:dynamicClassName]) {
                    [data setObject:@"integer" forKey:ivar_name];
                } else if ([staticClassName3 isEqualToString:dynamicClassName]) {
                    [data setObject:@"integer" forKey:ivar_name];
                } else if ([staticClassName4 isEqualToString:dynamicClassName]) {
                    [data setObject:@"integer" forKey:ivar_name];
                } else if ([staticClassName5 isEqualToString:dynamicClassName]) {
                    [data setObject:@"bool" forKey:ivar_name];
                }
                
            }
        }
    }
}

void toUpper(sqlite3_context *context, int argc, sqlite3_value **argv) {
    
    if (argc != 1)
        return;
    switch(sqlite3_value_type(argv[0]))
    {
        case SQLITE_NULL:
        {
        sqlite3_result_text(context, "NULL", 4, SQLITE_STATIC);
        break;
        }
        case SQLITE_TEXT:
        {
        NSString *_str = [[NSString alloc] initWithUTF8String:(char *)sqlite3_value_text(argv[0])];
        NSLog(@"Upper:%@",_str);
        _str = [_str uppercaseString];
        NSLog(@"Upper:%@",_str);
        sqlite3_result_text(context, [_str UTF8String], [_str lengthOfBytesUsingEncoding:NSUTF8StringEncoding], SQLITE_TRANSIENT);
        break;
        }
        default:
        sqlite3_result_text(context, "NULL", 4, SQLITE_STATIC);
        break;
    }
}




#pragma mark - Object Methods
-(NSArray *)conatactCards {
    NSArray *arr = [_container objectForKey:FIELD_CARD_CONTAINER];
    
    return arr;
}

- (void)saveImage:(UIImage*)image name:(NSString*)name callback:(void (^)(id obj))callback{
    
    void (^block)(UIImage*image, NSString*name) = ^(UIImage*image, NSString*name){
        NSFileManager *filemgr = [NSFileManager defaultManager];
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docsDir = [dirPaths objectAtIndex:0];
        NSString *newDir = [docsDir stringByAppendingPathComponent:ATTACHMENT_FOLDER];
        NSError *err = nil;
        BOOL isDir;
        
        if (![filemgr fileExistsAtPath:newDir isDirectory:&isDir])
            [filemgr createDirectoryAtPath:newDir withIntermediateDirectories:YES attributes:nil error:&err];
        newDir = [NSString stringWithFormat:@"%@/%@", newDir, name];
        if (!err) {
            NSData * data = UIImagePNGRepresentation(image);
            if (data) {
                BOOL a = [filemgr createFileAtPath: newDir contents: data attributes: nil];
                NSLog(@"write: %d", a);
            }
        } else {
            DLog(@"Faild create folder!! %@", [err description]);
            //        return nil;
        }
        if (callback)
            callback(nil);
        
    };
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(image,name);
        });
        
    });
}

- (void)removeImageFromPath:(NSString *)imgPath
{
    NSError *error = nil;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if ([fileMgr removeItemAtPath:imgPath error:&error] != YES) {
        NSLog(@"Unable to delete file: %@", [error localizedDescription]);
    } else {
        NSLog(@"The image deleted!");
    }
}


@end
