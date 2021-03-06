//
//  FCXNewsHomeListView.h
//  FCXNews
//
//  Created by 冯 传祥 on 16/5/18.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FCXNewsHomeListView : UITableView

@property (nonatomic, copy) NSString *channelID;
@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *admobID;
@property (nonatomic, strong) UIView *detailTitleView;//!<详情页导航条的titleView

@property (nonatomic, strong) NSString *shareTitle;//!<第三方平台显示分享的标题
@property (nonatomic, strong) NSString *shareLeftText;//!<分享底部左边文本
@property (nonatomic, strong) NSString *shareRightText;//!<分享底部右边边文
@property (nonatomic, strong) UIColor *shareLeftColor;//!<分享底部左边文本颜色，默认blackColor
@property (nonatomic, strong) UIColor *shareRightColor;//!<分享底部右边文本颜色，默认0x5b5b5b

@property (nonatomic, strong) UIColor *shareNavColor;//!<分享出去导航条的颜色，默认是navigationBar.barTintColor
@property (nonatomic, strong) UIColor *shareNavTitleColor;//!<分享出去导航条的标题颜色，默认是blackColor
@property (nonatomic, strong) NSString *shareNavTitle;//!<分享出去导航条的标题，默认是CFBundleDisplayName
@property (nonatomic, strong) UIImage *shareIconImage;//!<分享出去中间的icon，默认是Icon

@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, unsafe_unretained) UINavigationController *pushNavController;
@property (nonatomic, unsafe_unretained) BOOL needSaveToTmp;


@end
