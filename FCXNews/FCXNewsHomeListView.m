//
//  FCXNewsHomeListView.m
//  FCXNews
//
//  Created by 冯 传祥 on 16/5/18.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsHomeListView.h"
#import "FCXNewsModel.h"
#import "UIImageView+WebCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetWorking.h"
#import "FCXNewsDBManager.h"
#import "UIScrollView+FCXRefresh.h"
#import "FCXRefreshFooterView.h"
#import "FCXRefreshHeaderView.h"
#import "FCXNewsDetailController.h"
#import "FCXDefine.h"
#import "MobClick.h"
#import "FCXOnlineConfig.h"
#import "FCXWebViewController.h"

static NSString *const FCXNewsHomeListCellIdentifier = @"FCXNewsHomeListCellIdentifier";

@interface FCXNewsHomeListCell : UITableViewCell
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_sourceLabel;
    UILabel *_recommendLabel;
    UILabel *_dateLabel;
    UILabel *_defauleImageLable;
}

@property (nonatomic, strong)FCXNewsModel *dataModel;

@end

@implementation FCXNewsHomeListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 95, 70)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _defauleImageLable = [[UILabel alloc] initWithFrame:_imageView.frame];
        _defauleImageLable.textAlignment = NSTextAlignmentCenter;
        _defauleImageLable.textColor = [UIColor whiteColor];
        _defauleImageLable.font =  [UIFont fontWithName:@"Helvetica-Bold" size:18];
        _defauleImageLable.backgroundColor = UICOLOR_FROMRGB(0xeaeaea);
        _defauleImageLable.text = APP_DISPLAYNAME;
        [self.contentView addSubview:_defauleImageLable];
        
        _recommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 19, 30, 15)];
        _recommendLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        _recommendLabel.textColor = UICOLOR_FROMRGB(0xa5a5a5);
        _recommendLabel.backgroundColor = [UIColor clearColor];
        _recommendLabel.layer.cornerRadius = 3;
        _recommendLabel.layer.borderWidth = .5;
        _recommendLabel.layer.borderColor = UICOLOR_FROMRGB(0xa5a5a5).CGColor;
        _recommendLabel.clipsToBounds = YES;
        _recommendLabel.text = [FCXOnlineConfig fcxGetConfigParams:@"advertName" defaultValue:@"推广"];
        _recommendLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_recommendLabel];
        
        _titleLabel = [[UILabel alloc] init];
        //        _titleLabel.textColor = UICOLOR_FROMRGB(0x343233);
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        _titleLabel.numberOfLines = 2;
        [self.contentView addSubview:_titleLabel];
        
        _sourceLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 62 - 5, SCREEN_WIDTH - 125, 20)];
        _sourceLabel.textColor = UICOLOR_FROMRGB(0x959595);
        _sourceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        [self.contentView addSubview:_sourceLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(180, 62 - 5, SCREEN_WIDTH - 193, 20)];
        _dateLabel.textColor = UICOLOR_FROMRGB(0x959595);
        _dateLabel.font = _sourceLabel.font;
        _dateLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_dateLabel];
    }
    return self;
}

- (void)setDataModel:(FCXNewsModel *)dataModel {
    
    if (_dataModel != dataModel) {
        _dataModel = dataModel;
        
        WeakObj(_defauleImageLable);
        _defauleImageLable.hidden = NO;

        if (dataModel.isAd) {//广告
            _recommendLabel.hidden = NO;
            _imageView.hidden = NO;
            _titleLabel.frame = CGRectMake(153, 12, SCREEN_WIDTH - 158, 50);
            if (dataModel.adDesHeight < 30) {
                _titleLabel.frame = CGRectMake(120, 12, SCREEN_WIDTH - 125, 30);
            }else {
                _titleLabel.frame = CGRectMake(120, 12, SCREEN_WIDTH - 125, 50);
            }
            _sourceLabel.frame = CGRectMake(120, 62 - 5, SCREEN_WIDTH - 125, 20);
            
            [_imageView sd_setImageWithURL:[dataModel.adData.properties objectForKey:GDTNativeAdDataKeyImgUrl] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                _defauleImageLableWeak.hidden = YES;
            }];
            _titleLabel.text = _dataModel.title;
            _sourceLabel.text = [dataModel.adData.properties objectForKey:GDTNativeAdDataKeyTitle];
            _dateLabel.text = nil;
            [_dataModel.nativeAd attachAd:_dataModel.adData toView:self];
            
            return;
        }
        
        if (dataModel.imagesArray.count > 0) {//有图片
            _imageView.hidden = NO;
            _recommendLabel.hidden = YES;
            [_imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.imagesArray[0]] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                _defauleImageLableWeak.hidden = YES;
            }];
            _titleLabel.frame = CGRectMake(120, 12, SCREEN_WIDTH - 125, 50);
            _sourceLabel.frame = CGRectMake(120, 62 - 5, SCREEN_WIDTH - 125, 20);
            
        }else {//无图片
            _defauleImageLable.hidden = YES;
            _imageView.hidden = YES;
            _recommendLabel.hidden = YES;
            _sourceLabel.frame = CGRectMake(10, 62 - 5, SCREEN_WIDTH - 20, 20);
            _titleLabel.frame = CGRectMake(10, 12, SCREEN_WIDTH - 20, 50);
        }
        
        _titleLabel.text = dataModel.title;
        _dateLabel.text = _dataModel.showDate;
        
        if ([[FCXOnlineConfig fcxGetConfigParams:@"showSource" defaultValue:@"0"] boolValue]) {
            _sourceLabel.text = dataModel.source;
        }else {
            _sourceLabel.text = APP_DISPLAYNAME;
        }
        
        if (dataModel.read) {
            _titleLabel.textColor = UICOLOR_FROMRGB(0x828282);
        }else {
            _titleLabel.textColor = [UIColor blackColor];
        }
    }
}

@end




@interface FCXNewsHomeListView () <UITableViewDelegate, UITableViewDataSource, GDTNativeAdDelegate>
{
    int _offset;
    GDTNativeAd *_nativeAd;
    BOOL _showAd;//是否显示广告
    NSMutableArray *_adDataArray;
    NSMutableArray *_dataArray;
    FCXRefreshFooterView *_footView;
    FCXRefreshHeaderView *_headerView;
}

@end

@implementation FCXNewsHomeListView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _dataArray = [[NSMutableArray alloc] init];
    self.delegate = self;
    self.dataSource = self;
    self.rowHeight = 90;
    self.backgroundColor = [UIColor clearColor];
    self.separatorColor = UICOLOR_FROMRGB(0xd8d8d8);
    self.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([self respondsToSelector:@selector(layoutMargins)]) {
        self.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    [self registerClass:[FCXNewsHomeListCell class] forCellReuseIdentifier:FCXNewsHomeListCellIdentifier];
    
    UIView *footView = [[UIView alloc] init];
    self.tableFooterView = footView;
    [self addRefreshHeaderAndFooter];
    [self startMonitoring];
}

- (void)startMonitoring {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status > 0 && _dataArray.count < 1) {
            [self requestData:YES
                    channelID:self.channelID
                       finish:^(BOOL hasMore){
                       }];
        } else if (_dataArray.count > 0) {
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        }
    }];
}

- (void)setChannelID:(NSString *)channelID {
    [_footView resetNoMoreData];
    [_headerView endRefresh];
    [_dataArray removeAllObjects];

    if (_channelID) {
        _channelID = channelID;
        
        if ([[FCXNewsDBManager sharedManager] overRefreshTime:channelID]) {
            [_headerView startRefresh];
            [self setupAd];
            return;
        }

        NSArray *array = [[FCXNewsDBManager sharedManager] getNewsModelArrayFromTmpCache:channelID];
        if ([array isKindOfClass:[NSArray class]] && array.count > 0) {
            _offset = (int)array.count;

            [_dataArray addObjectsFromArray:array];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
            [self setupAd];
            return;
        }
    }
    
    
    _offset = 0;
    _channelID = channelID;

    [self requestData:YES
            channelID:self.channelID
               finish:^(BOOL hasMore){

    }];
    [self setupAd];
}

- (void)addRefreshHeaderAndFooter {
    __weak typeof(self) weakSelf = self;
    
    _footView = [self addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf requestData:NO
                    channelID:weakSelf.channelID
                       finish:^(BOOL hasMore){
            
            if (hasMore) {
                [refreshView endRefresh];
            }else {
                [refreshView showNoMoreData];
            }
        }];
    }];
    _footView.autoLoadMore = YES;
    
    __weak FCXRefreshFooterView *weakFootView = _footView;
    
    _headerView = [self addHeaderWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf requestData:YES
                    channelID:weakSelf.channelID
                       finish:^(BOOL hasMore){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [refreshView endRefresh];
            });
            [weakFootView resetNoMoreData];
        }];
    }];
    
}

- (NSString *)md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],result[1],result[2],result[3],
            result[4],result[5],result[6],result[7],
            result[8],result[9],result[10],result[11],
            result[12],result[13],result[14],result[15]];
}

- (NSString *)sha1:(NSString *)str {
    const char *cstr = [str cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:str.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH *2];
    
    for(int i =0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

- (void)requestData:(BOOL)isRefresh
             channelID:(NSString *)channelID
             finish:(void (^)(BOOL hasMore))finish {
    
    if (isRefresh) {
        _offset = 0 ;
        [_adDataArray removeAllObjects];
        [_dataArray removeAllObjects];
    }else {
        _offset += 10;
    }
    
    [self loadMoreAD];
    
    NSString *appid = @"x01Gjdp0kvyAVA6SZn7DGAt9";
    NSString * appKey = @"UzfzdzWncC2bUamYYcF4rzGPMBDThNh2";
    int timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *nonce = [NSString stringWithFormat:@"sfdyuiy%d", timestamp%100];
    
    NSString *secretkey = [self md5:appKey];
    secretkey = [secretkey stringByAppendingFormat:@"%@%d", nonce, timestamp];
    secretkey = [self sha1:secretkey];
    int count = 10;
    
    NSString *urlStr = [NSString stringWithFormat:@"http://o.go2yd.com/open-api/caijing/channel?appid=%@&nonce=%@&timestamp=%d&secretkey=%@&channel_id=%@&offset=%d&count=%d", appid, nonce, timestamp, secretkey, self.channelID, _offset, count];
    DBLOG(@"url %@", urlStr);
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", nil];
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DBLOG(@"respon %@", responseObject);
        NSArray *result = responseObject[@"result"];
        BOOL hasMore = YES;
        if ([result isKindOfClass:[NSArray class]]) {
            if (result.count == 0) {
                if (_dataArray.count == 0) {
                    [_dataArray addObjectsFromArray:[[FCXNewsDBManager sharedManager] getNewsModelArray:_dataArray.count channelID:channelID]];
                }else {
                    hasMore = NO;
                }
            }
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dict in result) {
                FCXNewsModel *model = [[FCXNewsModel alloc] initWithDict:dict];
                model.channelID = channelID;
                [array addObject:model];
            }
            
            if (channelID == self.channelID) {
                [_dataArray addObjectsFromArray:array];
                
                if (self.needSaveToTmp) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[FCXNewsDBManager sharedManager] saveToTmpCache:_dataArray channelID:channelID];
                    });
                }
            }
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[FCXNewsDBManager sharedManager] saveNewsData:array];
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        }
        finish(hasMore);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        DBLOG(@"fail %@", error.localizedDescription);
        
        BOOL hasMore = NO;
        NSArray *array = [[FCXNewsDBManager sharedManager] getNewsModelArray:_dataArray.count channelID:channelID];
        
        if (array.count > 0) {
            hasMore = YES;
            if (channelID == self.channelID) {
                [_dataArray addObjectsFromArray:array];
                
                if (self.needSaveToTmp) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        [[FCXNewsDBManager sharedManager] saveToTmpCache:_dataArray channelID:channelID];
                    });
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
        
        finish(hasMore);
    }];
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FCXNewsHomeListCell *cell = [tableView dequeueReusableCellWithIdentifier:FCXNewsHomeListCellIdentifier];
    if (_showAd && indexPath.row > 8) {
        
        if ((indexPath.row + 1 - 10) % 8 == 0) {
            NSInteger row = (indexPath.row + 1 - 10)/8;
            if (_adDataArray.count > row) {
                cell.dataModel = _adDataArray[row];
                return cell;
            }
        }
    }
    
    if (_dataArray.count > indexPath.row) {
        cell.dataModel = _dataArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_showAd && indexPath.row > 8) {
        
        if ((indexPath.row + 1 - 10) % 8 == 0) {
            NSInteger row = (indexPath.row + 1 - 10)/8;
            if (_adDataArray.count > row) {
                FCXNewsModel *model = _adDataArray[row];
                [model.nativeAd clickAd:model.adData];
                [MobClick event:@"列表点击" label:[model.adData.properties objectForKey:GDTNativeAdDataKeyTitle]];
                return;
            }
        }
    }
    
    if (_dataArray.count > indexPath.row) {
        FCXNewsModel *dataModel = _dataArray[indexPath.row];
        dataModel.read = YES;
        
        [[FCXNewsDBManager sharedManager] updateNewsModel:dataModel];
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if ([dataModel.cType isKindOfClass:[NSString class]] &&
            [dataModel.cType isEqualToString:@"video"] &&
            [[FCXOnlineConfig fcxGetConfigParams:@"showSource" defaultValue:@"0"] boolValue]) {
            
            FCXWebViewController *webView = [[FCXWebViewController alloc] init];
            webView.urlString = dataModel.url;
            webView.admobID = self.admobID;
            webView.navigationItem.titleView = self.detailTitleView;
            [self.pushNavController pushViewController:webView animated:YES];
            return;
        }
        
        [MobClick event:@"列表点击" label:dataModel.title];

        FCXNewsDetailController *detailVC = [[FCXNewsDetailController alloc] init];
        detailVC.model = dataModel;
        detailVC.admobID = self.admobID;
        detailVC.appID = self.appID;
        detailVC.shareTitle = self.shareTitle;
        detailVC.shareLeftText = self.shareLeftText;
        detailVC.shareLeftColor = self.shareLeftColor;
        detailVC.shareRightText = self.shareRightText;
        detailVC.shareRightColor = self.shareRightColor;
        detailVC.shareNavColor = self.shareNavColor;
        detailVC.shareNavTitleColor = self.shareNavTitleColor;
        detailVC.shareNavTitle = self.shareNavTitle;
        detailVC.shareIconImage = self.shareIconImage;
        detailVC.navigationItem.titleView = self.detailTitleView;
        [self.pushNavController pushViewController:detailVC animated:YES];
    }
}

- (void)setupAd {
    _showAd = [[FCXOnlineConfig fcxGetConfigParams:@"showGDT" defaultValue:@"0"] boolValue];
    //    _showAd = NO;
    if (_showAd) {
        
        NSString *paramsString = [FCXOnlineConfig fcxGetConfigParams:@"GDT_Info"];
        NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if([dict isKindOfClass:[NSDictionary class]]){
            NSString *appkey = dict[@"appkey"];;
            NSString *placementId = dict[@"placementId"];
            if (!_nativeAd) {
                _adDataArray = [NSMutableArray array];
                _nativeAd = [[GDTNativeAd alloc] initWithAppkey:appkey placementId:placementId];
                _nativeAd.controller = self.pushNavController;
                _nativeAd.delegate = self;
                [_nativeAd loadAd:2];
            }else {
                [_adDataArray removeAllObjects];
                _nativeAd.controller = self.pushNavController;
                [_nativeAd loadAd:2 + _offset/8];
            }
        }
    }
}

- (void)loadMoreAD {
    NSInteger count = _dataArray.count + 15;
    
    NSInteger row = (count + 1 - 10)/8 + 1;
    
    if (row > _adDataArray.count) {
        [_nativeAd loadAd:2];
    }
}

- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    
    for (GDTNativeAdData *data in nativeAdDataArray) {
        FCXNewsModel *model = [[FCXNewsModel alloc] init];
        model.adData = data;
        model.nativeAd = _nativeAd;
        model.isAd = YES;
        
        model.title = [NSString stringWithFormat:@"        %@", [data.properties objectForKey:GDTNativeAdDataKeyDesc]];
        
        NSDictionary *attribute = @{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:17]};
        
        CGSize size = [model.title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 125, 50) options:NSStringDrawingTruncatesLastVisibleLine |
                       NSStringDrawingUsesLineFragmentOrigin |
                       NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
        model.adDesHeight = size.height;
        [_adDataArray addObject:model];
    }
    [self loadMoreAD];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self reloadData];
    });
    
}

-(void)nativeAdFailToLoad:(NSError *)error {
    //    NSLog(@"error %@", error.localizedDescription);
}

@end
