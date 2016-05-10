//
//  FCXNewsMoreController.h
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCXNewsMoreController : UIViewController

@property (nonatomic, copy) NSString *appID;
@property (nonatomic, copy) NSString *admobID;
@property (nonatomic, strong) NSString *shareTitle;//!<第三方平台显示分享的标题
@property (nonatomic, strong) NSString *shareContent;//!<第三方平台显示分享的内容


@end
