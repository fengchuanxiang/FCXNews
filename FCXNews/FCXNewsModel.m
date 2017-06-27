//
//  FCXNewsModel.m
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsModel.h"
#import "FCXNewsDBManager.h"

@implementation FCXNewsModel
{
    NSDate *_transDate;
}

+ (BOOL)supportsSecureCoding {
    return YES;
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
        }else {
            NSString *image = dict[@"image"];
            if ([image isKindOfClass:[NSString class]]) {
                self.imagesArray = @[image];
                self.images = [self.imagesArray componentsJoinedByString:@","];
            }else {
                self.imagesArray = @[];
                self.images = @"";
            }
        }
        
        self.content = @"";
        [[FCXNewsDBManager sharedManager] queryNewsModel:self];
        
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

- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [aCoder encodeObject:self.images forKey:@"images"];
    [aCoder encodeObject:self.imagesArray forKey:@"imagesArray"];

    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.docid forKey:@"docid"];
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.source forKey:@"source"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.relatedDocs forKey:@"relatedDocs"];
    [aCoder encodeObject:self.cType forKey:@"cType"];
    [aCoder encodeObject:self.channelID forKey:@"channelID"];
    [aCoder encodeBool:self.read forKey:@"read"];
    [aCoder encodeBool:self.collect forKey:@"collect"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
//        self.images = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"images"];
        
        self.imagesArray = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"imagesArray"];

        self.title = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"title"];
        self.docid = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"docid"];
        self.url = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"url"];
        self.date = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"date"];
        self.source = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"source"];
        self.content = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"content"];
        self.relatedDocs = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"relatedDocs"];
        self.cType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"cType"];
        self.channelID = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"channelID"];
        self.read = [aDecoder decodeBoolForKey:@"read"];
        self.collect =  [aDecoder decodeBoolForKey:@"collect"];
    }
    return self;
}

@end
