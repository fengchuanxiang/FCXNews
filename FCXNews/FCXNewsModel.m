//
//  FCXNewsModel.m
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsModel.h"

@implementation FCXNewsModel
{
    NSDate *_transDate;
}

- (FCXNewsModel *)initWithDict:(NSDictionary *)dict {
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    if (self = [super init]) {
        self.title = dict[@"title"];
        self.docid = dict[@"docid"];
        self.url = dict[@"url"];
        self.date = dict[@"date"];
        self.source = dict[@"source"];
        self.cType = dict[@"ctype"];
        self.imagesArray = dict[@"images"];
        if ([self.imagesArray isKindOfClass:[NSArray class]]) {
            self.images = [self.imagesArray componentsJoinedByString:@","];
        }
        
        self.content = @"";
    }
    return self;
}

- (NSString *)showDate {
    if (!_transDate) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        _transDate = [formatter dateFromString:self.date];
    }
    
    NSString *showDate;
    
    NSInteger interval = -[_transDate timeIntervalSinceNow];
    
    if (interval < 60) {
        showDate = @"一分钟内";
    }else if (interval >= 60 && interval < 60 * 60) {
        showDate = [NSString stringWithFormat:@"%ld钟前", interval/60];
    }else if (interval >= 60 * 60 && interval < 60 *60 * 24) {
        showDate = [NSString stringWithFormat:@"%ld小时前", interval/(60 * 60)];
    }else if (interval >= 60 *60 * 24 && interval < 60 *60 * 24 * 30) {
        showDate = [NSString stringWithFormat:@"%ld天前", interval/(60 * 60 * 24)];
    }else if (interval >= 60 *60 * 24 * 30 && interval < 60 *60 * 24 * 30 * 12) {
        showDate = [NSString stringWithFormat:@"%ld月前", interval/(60 * 60 * 24 * 30)];
    }else {
        showDate = self.date;
        if (showDate.length > 10) {
            showDate = [showDate substringToIndex:10];
        }
    }
    return showDate;
}

+ (NSString *)getShowDateString:(NSString *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *transDate = [formatter dateFromString:date];
    
    NSString *showDate;
    
    NSInteger interval = -[transDate timeIntervalSinceNow];
    
    if (interval < 60) {
        showDate = @"一分钟内";
    }else if (interval >= 60 && interval < 60 * 60) {
        showDate = [NSString stringWithFormat:@"%ld钟前", interval/60];
    }else if (interval >= 60 * 60 && interval < 60 *60 * 24) {
        showDate = [NSString stringWithFormat:@"%ld小时前", interval/(60 * 60)];
    }else if (interval >= 60 *60 * 24 && interval < 60 *60 * 24 * 30) {
        showDate = [NSString stringWithFormat:@"%ld天前", interval/(60 * 60 * 24)];
    }else if (interval >= 60 *60 * 24 * 30 && interval < 60 *60 * 24 * 30 * 12) {
        showDate = [NSString stringWithFormat:@"%ld月前", interval/(60 * 60 * 24 * 30)];
    }else {
        showDate = date;
        if (showDate.length > 10) {
            showDate = [showDate substringToIndex:10];
        }
    }
    return showDate;
}

@end
