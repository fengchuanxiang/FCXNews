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

@implementation FCXNewsDBManager
{
    FMDatabaseQueue* _dbQueue;
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
        dbPath = [dbPath stringByAppendingPathComponent:@"Library/finance.db"];
//        DBLOG(@"======== %@", dbPath);
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
        
        [_dbQueue inDatabase:^(FMDatabase *db) {
            //解梦详情
            NSString *creatTableSql = @"CREATE TABLE IF NOT EXISTS finance (serial integer  Primary Key Autoincrement, title TEXT(1024) DEFAULT NULL, docid TEXT(1024) DEFAULT NULL, url TEXT(1024) DEFAULT NULL, date TEXT(1024) DEFAULT NULL, images TEXT(1024) DEFAULT NULL, source TEXT(1024) DEFAULT NULL, content TEXT(8192) DEFAULT NULL, relatedDocs TEXT(8192) DEFAULT NULL)";
            
            //    执行语句，创建user
            [db executeUpdate:creatTableSql];
//            BOOL createUserTable = [db executeUpdate:creatTableSql];
//            DBLOG(@"createUserTable success = %d", createUserTable);
            
        }];
    }
    
    return self;
}

- (void)saveFinanceData:(NSArray *)array {
    for (FCXNewsModel *model in array) {
        [self saveFinanceModel:model];
    }
}

- (void)saveFinanceModel:(FCXNewsModel *)model {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *sq = [NSString stringWithFormat:@"SELECT title FROM finance WHERE docid = '%@'", model.docid];
        FMResultSet * rs = [db executeQuery:sq];
        
        if ([rs next]) {
//            DBLOG(@"exist");
        }else {
            
            NSString *sql=[NSString stringWithFormat:@"INSERT INTO finance(title, docid, url, date, images, source, content) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@')", model.title, model.docid, model.url, model.date, model.images, model.source, model.content];
            
            [db executeUpdate:sql];
        }
        [rs close];
        
    }];
    
}

- (void)updateFinanceModel:(FCXNewsModel *)model {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql=[NSString stringWithFormat:@"UPDATE finance set content = '%@', url = '%@', relatedDocs = '%@' WHERE docid = '%@'", model.content, model.url, model.relatedDocs, model.docid];
        BOOL update = [db executeUpdate:sql];
        DBLOG(@"update %d", update);
    }];
}

- (NSMutableArray *)getFinanceDataArray:(NSInteger)offset {
    NSMutableArray *array = [NSMutableArray array];
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT title, docid, url, date, images, source, content, relatedDocs from finance ORDER BY date DESC LIMIT 10 OFFSET %ld", (long)offset];
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
            [array addObject:model];
        }
        [rs close];
    }];
    return array;
}

- (void)queryFinanceModel:(FCXNewsModel *)model {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"SELECT title, docid, url, date, images, source, content, relatedDocs from finance WHERE docid = '%@'", model.docid];
        FMResultSet * rs = [db executeQuery:sql];
        if ([rs next]) {
            model.content = [rs stringForColumn:@"content"];
            model.relatedDocs = [rs stringForColumn:@"relatedDocs"];
        }
        [rs close];
    }];
}

- (void)clearCache {
    [_dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql=[NSString stringWithFormat:@"delete from finance"];
        if ([db executeUpdate:sql]) {
//            DBLOG(@"delete success");
        }
    }];
}

-(void)close{
    [_dbQueue close];
};


@end
