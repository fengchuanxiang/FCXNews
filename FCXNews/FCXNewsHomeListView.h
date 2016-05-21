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
@property (nonatomic, strong) NSString *shareTitle;//!<第三方平台显示分享的标题

@property (nonatomic, assign) NSInteger currentPageIndex;
@property (nonatomic, unsafe_unretained) UINavigationController *pushNavController;
@property (nonatomic, unsafe_unretained) BOOL needSaveToTmp;


@end
