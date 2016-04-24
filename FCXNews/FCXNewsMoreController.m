//
//  FCXNewsMoreController.m
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsMoreController.h"
#import "UMFeedback.h"
#import "SDImageCache.h"
#import "FCXShareManager.h"
#import "FCXRating.h"
#import "MBProgressHUD.h"
#import "FCXNewsDBManager.h"
#import "FCXDefine.h"
#import "FCXOnlineConfig.h"
#import "MobClick.h"

@interface FCXNewsMoreController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_tableView;
}
@end

@implementation FCXNewsMoreController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"更多";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = UICOLOR_FROMRGB(0xf5f5f5);
    
    CGFloat adHeight = 0;
    if ([[FCXOnlineConfig fcxGetConfigParams:@"showAdmob" defaultValue:@"1"] boolValue]) {
        adHeight = 50;
        [self showAdmobBanner:CGRectMake(0, SCREEN_HEIGHT - 64 - 50 - 49, SCREEN_WIDTH, 50) adUnitID:[FCXOnlineConfig fcxGetConfigParams:@"AdmobID" defaultValue:self.admobID]];
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - adHeight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = UICOLOR_FROMRGB(0xd9d9d9);
    [self.view addSubview:_tableView];
    
    UIView *footView = [[UIView alloc] init];
    _tableView.tableFooterView = footView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 3;
            break;
        case 2:
            return 1;
            break;
    }
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *setReuseIdentifier = @"setReuserIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:setReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:setReuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = UICOLOR_FROMRGB(0x343233);
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 145, 4, 100, 40)];
        rightLabel.textAlignment = NSTextAlignmentRight;
        rightLabel.textColor = UICOLOR_FROMRGB(0xd3d3d3);
        rightLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        rightLabel.tag = 100;
        [cell.contentView addSubview:rightLabel];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *rightLabel = [cell.contentView viewWithTag:100];
    rightLabel.text = nil;
    
    switch (indexPath.section) {
        case 0:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"推荐%@给好友", APP_DISPLAYNAME];
        }
            break;
        case 1:
        {
            if (indexPath.row == 0){
                cell.textLabel.text = [NSString stringWithFormat:@"去App Store给%@评分", APP_DISPLAYNAME];
                
            }else if (indexPath.row == 1){
                cell.textLabel.text = @"意见反馈";
                
            }else if (indexPath.row == 2){
                cell.textLabel.text = @"清除缓存";
                rightLabel.text = [NSString stringWithFormat:@"%.2fM", [[SDImageCache sharedImageCache] getSize]/(1024.0 * 1024.0)];
            }
            
        }
            break;
        case 2:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.text = APP_DISPLAYNAME;
            rightLabel.text = [NSString stringWithFormat:@"V %@", APP_VERSION];
        }
            break;
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {//推荐财经头条给好友
            [MobClick event:@"设置" label:@"邀请好友"];
            FCXShareManager *shareManager = [FCXShareManager sharedManager];
            shareManager.presentedController = self;
            shareManager.shareTitle = @"知科技大事，他们都用互联网头条！";
            shareManager.shareContent = @"第一时间推送互联网热点资讯，从此变身互联网达人。";
            shareManager.shareURL = [NSString stringWithFormat:@"http://itunes.apple.com/cn/app/id%@?mt=8", APPID];
            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
            NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
            shareManager.shareImage = [UIImage imageNamed:icon];
            
            [shareManager showInviteFriendsShareView];
        }
            break;
        case 1:
        {
            if(indexPath.row == 0){//去App Store给鲨鱼相机评分
                [MobClick event:@"设置" label:@"评分"];
                [FCXRating goRating:APPID];
            }else if (indexPath.row == 1){//意见反馈
                [MobClick event:@"设置" label:@"意见反馈"];
                //                [self.navigationController pushViewController:[UMFeedback feedbackViewController]
                //                                                     animated:YES];
                [self presentViewController:[UMFeedback feedbackModalViewController] animated:YES completion:nil];
            }else if (indexPath.row == 2){//清除缓存
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.labelText = @"清除中...";
                hud.labelColor = [UIColor whiteColor];
                hud.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
                // Will look best, if we set a minimum size.
                hud.minSize = CGSizeMake(150.f, 100.f);
                
                [[FCXNewsDBManager sharedManager] clearCache];
                
                [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                    //                    NSLog(@"===%@", [NSString stringWithFormat:@"%.2fM", [[SDImageCache sharedImageCache] getSize]/(1024.0 * 1024.0)]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        UIImage *image = [UIImage imageNamed:@"checkmark"];
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                        hud.customView = imageView;
                        hud.mode = MBProgressHUDModeCustomView;
                        hud.labelText = @"清理完毕";
                        hud.labelColor = [UIColor whiteColor];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [hud hide:YES];
                            [tableView reloadData];
                        });
                        
                    });
                }];
            }
            
        }
            break;
        case 2:
        {
        }
            break;
    }
}

@end
