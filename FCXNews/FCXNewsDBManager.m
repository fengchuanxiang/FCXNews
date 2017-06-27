//
//  FCXNewsDBManager.m
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsDBManager.h"
#import "FMDatabaseQueue.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "FCXNewsModel.h"

#define TABLENAME  @"FCXNews"

@implementation FCXNewsDBManager
{
    FMDatabaseQueue *_dbQueue;
}

+(FCXNewsDBManager*)sharedManager {
    
    static FCXNewsDBManager* sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[FCXNewsDBManager alloc] init];
    });
    return sharedManager;
}

-(id)init
{
    if (self = [super init]) {
        //沙盒路径
        NSString * dbPath = NSHomeDirectory();
        dbPath = [dbPath stringByAppendingPathComponent:@"Library/FCXNews.db"];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //解梦详情
            NSString *creatTableSql = [NSString stringWithFormat: @"CREATE TABLE IF NOT EXISTS %@ (serial integer  Primary Key Autoincrement, title TEXT(1024) DEFAULT NULL, docid TEXT(1024) DEFAULT NULL, url TEXT(1024) DEFAULT NULL, date TEXT(1024) DEFAULT NULL, images TEXT(1024) DEFAULT NULL, source TEXT(1024) DEFAULT NULL, content TEXT(8192) DEFAULT NULL, relatedDocs TEXT(8192) DEFAULT NULL, ctype TEXT(128) DEFAULT NULL, channelID TEXT(256) DEFAULT NULL, read INTEGER DEFAULT 0, collect INTEGER DEFAULT 0)", TABLENAME];
            
            //    执行语句，创建user
            [db executeUpdate:creatTableSql];
        }];
    }
    
    return self;
}

- (void)saveNewsData:(NSArray *)array {
    for (FCXNewsModel *model in array) {
        [self saveNewsModel:model];
    }
}

- (void)saveNewsModel:(FCXNewsModel *)model {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sq = [NSString stringWithFormat:@"SELECT title FROM %@ WHERE docid = '%@' AND channelID = '%@'", TABLENAME, model.docid, model.channelID];
        FMResultSet * rs = [db executeQuery:sq];
        
        if ([rs next]) {
//            DBLOG(@"exist");
        }else {
            
            NSString *sql=[NSString stringWithFormat:@"INSERT INTO %@(title, docid, url, date, images, source, content, ctype, channelID) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')", TABLENAME, model.title, model.docid, model.url, model.date, model.images, model.source, model.content, model.cType, model.channelID];
            
            [db executeUpdate:sql];
        }
        [rs close];
        
    }];
    
}

- (void)updateNewsModel:(FCXNewsModel *)model {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql=[NSString stringWithFormat:@"UPDATE %@ set content = '%@', url = '%@', relatedDocs = '%@', read = %d, collect = %d  WHERE docid = '%@'", TABLENAME, model.content, model.url, model.relatedDocs, model.read, model.collect, model.docid];
        [db executeUpdate:sql];
    }];
}

- (NSMutableArray *)getNewsModelArray:(NSInteger)offset channelID:(NSString *)channelID {
    NSMutableArray *array = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT title, docid, url, date, images, source, content, relatedDocs, ctype, read, collect from %@  WHERE channelID = '%@' ORDER BY date DESC LIMIT 10 OFFSET %ld", TABLENAME, channelID, (long)offset];
        FMResultSet * rs = [db executeQuery:sql];
        while ([rs next]) {
            FCXNewsModel *model = [[FCXNewsModel alloc] init];
            model.title = [rs stringForColumn:@"title"];
            model.docid = [rs stringForColumn:@"docid"];
            model.url = [rs stringForColumn:@"url"];
            model.content = [rs stringForColumn:@"content"];
            model.date = [rs stringForColumn:@"date"];
            model.images = [rs stringForColumn:@"images"];
            model.source = [rs stringForColumn:@"source"];
            model.relatedDocs = [rs stringForColumn:@"relatedDocs"];
            if (model.images && model.images.length > 0) {
                model.imagesArray = [model.images componentsSeparatedByString:@","];
            }
            model.cType = [rs stringForColumn:@"ctype"];
            model.read = [rs boolForColumn:@"read"];
            model.collect = [rs boolForColumn:@"collect"];
            [array addObject:model];
        }
        [rs close];
    }];
    return array;
}

- (void)queryNewsModel:(FCXNewsModel *)model {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT content, relatedDocs, read, collect from %@ WHERE docid = '%@'", TABLENAME, model.docid];
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            model.content = [rs stringForColumn:@"content"];
            model.relatedDocs = [rs stringForColumn:@"relatedDocs"];
            model.read = [rs boolForColumn:@"read"];
            model.collect = [rs boolForColumn:@"collect"];
        }
        [rs close];
    }];
}

- (void)saveToTmpCache:(NSArray *)array channelID:(NSString *)channelID {
    if (![array isKindOfClass:[NSArray class]] || array.count < 1) {
        return;
    }
    [NSKeyedArchiver archiveRootObject:array toFile:[NSTemporaryDirectory() stringByAppendingPathComponent:channelID]];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:channelID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)getNewsModelArrayFromTmpCache:(NSString *)channelID {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:[NSTemporaryDirectory() stringByAppendingPathComponent:channelID]];
    if (![array isKindOfClass:[NSArray class]]) {
        return nil;
    }
    for(FCXNewsModel *model in array) {
        [self queryNewsModel:model];
    }
    return array;
}

- (BOOL)overRefreshTime:(NSString *)channelID {
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:channelID];
    if (lastDate && [[NSDate date] timeIntervalSinceDate:lastDate] > 60 * 30) {
        return YES;
    }
    return NO;
}

- (void)clearCache {
    [self clearTmpCache];
    
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql=[NSString stringWithFormat:@"delete from %@", TABLENAME];
        if ([db executeUpdate:sql]) {
//            DBLOG(@"delete success");
        }
    }];
}

- (void)clearTmpCache {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *str in contents) {
        NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:str];
        [fileManager removeItemAtPath:path error:NULL];
    }
}

-(void)close{
    [_dbQueue close];
};


@end
