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

- (void)saveFinanceData:(NSArray *)array;
- (void)saveFinanceModel:(FCXNewsModel *)model;
- (void)updateFinanceModel:(FCXNewsModel *)model;
- (void)queryFinanceModel:(FCXNewsModel *)model;

- (NSMutableArray *)getFinanceDataArray:(NSInteger)offset;

- (void)clearCache;

@end
