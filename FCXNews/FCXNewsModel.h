//
//  FCXNewsModel.h
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GDTNativeAd.h"

@interface FCXNewsModel : NSObject

@property (nonatomic, unsafe_unretained) BOOL isAd;//是否是广告
@property (nonatomic, copy) NSString *images;
@property (nonatomic, strong) NSArray *imagesArray;
@property (nonatomic, copy) NSString *title;//标题
@property (nonatomic, copy) NSString *docid;//文章id
@property (nonatomic, copy) NSString *url;//链接
@property (nonatomic, copy) NSString *date;//发布时间
@property (nonatomic, copy) NSString *source;//来源
@property (nonatomic, copy) NSString *content;//html
@property (nonatomic, copy) NSString *relatedDocs;//热门推荐
@property (nonatomic, copy) NSString *cType;//卡片类型


@property (nonatomic, copy) NSString *showDate;//发布时间

@property (nonatomic, strong) GDTNativeAd *nativeAd;;
@property (nonatomic, strong) GDTNativeAdData *adData;
@property (nonatomic, unsafe_unretained) CGFloat adDesHeight;


+ (NSString *)getShowDateString:(NSString *)date;

- (FCXNewsModel *)initWithDict:(NSDictionary *)dict;

@end
