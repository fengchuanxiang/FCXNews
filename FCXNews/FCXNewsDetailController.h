//
//  FCXNewsDetailController.h
//  News
//
//  Created by 冯 传祥 on 16/4/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FCXNewsModel.h"

@interface FCXNewsDetailController : UIViewController

@property (nonatomic, strong) FCXNewsModel *model;
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *admobID;
@property (nonatomic, strong) NSString *shareTitle;//!<第三方平台显示分享的标题
@property (nonatomic, strong) NSString *shareLeftText;//!<分享底部左边文本
@property (nonatomic, strong) NSString *shareRightText;//!<分享底部右边边文
@property (nonatomic, strong) UIColor *shareLeftColor;//!<分享底部左边文本颜色
@property (nonatomic, strong) UIColor *shareRightColor;//!<分享底部右边文本颜色

@end
