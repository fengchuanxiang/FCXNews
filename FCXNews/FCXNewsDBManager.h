//
//  FCXNewsDBManager.h
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FCXNewsModel;

@interface FCXNewsDBManager : NSObject

+(FCXNewsDBManager*)sharedManager;

- (void)saveNewsData:(NSArray *)array;
- (void)saveNewsModel:(FCXNewsModel *)model;
- (void)updateNewsModel:(FCXNewsModel *)model;
- (void)queryNewsModel:(FCXNewsModel *)model;

- (NSMutableArray *)getNewsModelArray:(NSInteger)offset channelID:(NSString *)channelID;

- (void)saveToTmpCache:(NSArray *)array channelID:(NSString *)channelID;
- (NSArray *)getNewsModelArrayFromTmpCache:(NSString *)channelID;

- (BOOL)overRefreshTime:(NSString *)channelID;

- (void)clearCache;
- (void)clearTmpCache;

@end
