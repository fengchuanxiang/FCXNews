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


@end
