//
//  FCXNewsHomeController.m
//  News
//
//  Created by 冯 传祥 on 16/4/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsHomeController.h"
#import "FCXNewsModel.h"
#import "UIImageView+WebCache.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetWorking.h"
#import "FCXNewsDBManager.h"
#import "UIScrollView+FCXRefresh.h"
#import "FCXRefreshFooterView.h"
#import "FCXNewsDetailController.h"
#import "FCXDefine.h"
#import "MobClick.h"
#import "FCXOnlineConfig.h"

static NSString *const FCXNewsHomeCellIdentifier = @"FCXNewsHomeCellIdentifier";

@interface FCXNewsHomeCell : UITableViewCell
{
    UIImageView *_imageView;
    UILabel *_titleLabel;
    UILabel *_sourceLabel;
    UILabel *_recommendLabel;
    UILabel *_dateLabel;
}

@property (nonatomic, strong)FCXNewsModel *dataModel;

@end

@implementation FCXNewsHomeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 95, 70)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        
        _recommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(120, 19, 30, 15)];
        _recommendLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        _recommendLabel.textColor = UICOLOR_FROMRGB(0xa5a5a5);
        _recommendLabel.backgroundColor = [UIColor clearColor];
        _recommendLabel.layer.cornerRadius = 3;
        _recommendLabel.layer.borderWidth = .5;
        _recommendLabel.layer.borderColor = UICOLOR_FROMRGB(0xa5a5a5).CGColor;
        _recommendLabel.clipsToBounds = YES;
        _recommendLabel.text = @"推广";
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
            
            [_imageView sd_setImageWithURL:[dataModel.adData.properties objectForKey:GDTNativeAdDataKeyImgUrl] placeholderImage:[UIImage imageNamed:@"defaultimage_list"]];
            _titleLabel.text = _dataModel.title;
            _sourceLabel.text = [dataModel.adData.properties objectForKey:GDTNativeAdDataKeyTitle];
            _dateLabel.text = nil;
            [_dataModel.nativeAd attachAd:_dataModel.adData toView:self];
            
            return;
        }
        
        if (dataModel.imagesArray.count > 0) {//有图片
            _imageView.hidden = NO;
            _recommendLabel.hidden = YES;
            [_imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.imagesArray[0]] placeholderImage:[UIImage imageNamed:@"defaultimage_list"]];
            _titleLabel.frame = CGRectMake(120, 12, SCREEN_WIDTH - 125, 50);
            _sourceLabel.frame = CGRectMake(120, 62 - 5, SCREEN_WIDTH - 125, 20);
            
        }else {//无图片
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
        
    }
}

@end





@interface FCXNewsHomeController ()<UITableViewDelegate, UITableViewDataSource, GDTNativeAdDelegate>
{
    NSMutableArray *_dataArray;
    UITableView *_tableView;
    int _offset;
    GDTNativeAd *_nativeAd;
    BOOL _showAd;//是否显示广告
}

@property (nonatomic, strong) NSMutableArray *adDataArray;

@end

@implementation FCXNewsHomeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _dataArray = [[NSMutableArray alloc] init];
    
    NSDictionary *dict = [FCXOnlineConfig fcxGetJSONConfigParams:@"homeH5"];
    if ([dict isKindOfClass:[NSDictionary class]] && [dict[@"showH5"] integerValue] == 1) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 49)];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:dict[@"url"]]]];
        [self.view addSubview:webView];
        return;
    }
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 49) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 90;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = UICOLOR_FROMRGB(0xd8d8d8);
    _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([_tableView respondsToSelector:@selector(layoutMargins)]) {
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    [_tableView registerClass:[FCXNewsHomeCell class] forCellReuseIdentifier:FCXNewsHomeCellIdentifier];
    [self.view addSubview:_tableView];
    
    UIView *footView = [[UIView alloc] init];
    _tableView.tableFooterView = footView;
    [self addRefreshHeaderAndFooter];
    
    _offset = 0;
    
    [self requestData:YES finish:^(BOOL hasMore){
        
    }];
    [self setupAd];
}

- (void)addRefreshHeaderAndFooter {
    __weak typeof(self) weakSelf = self;
    
    FCXRefreshFooterView *footView = [_tableView addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf requestData:NO finish:^(BOOL hasMore){
            
            if (hasMore) {
                [refreshView endRefresh];
            }else {
                [refreshView showNoMoreData];
            }
        }];
    }];
    footView.autoLoadMore = YES;
    
    [_tableView addHeaderWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        [weakSelf requestData:YES finish:^(BOOL hasMore){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [refreshView endRefresh];
            });
            [footView resetNoMoreData];
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

- (void)requestData:(BOOL)isRefresh finish:(void (^)(BOOL hasMore))finish {
    
    if (isRefresh) {
        _offset = 0 ;
        [self.adDataArray removeAllObjects];
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
                    [_dataArray addObjectsFromArray:[[FCXNewsDBManager sharedManager] getFinanceDataArray:_dataArray.count]];
                }else {
                    hasMore = NO;
                }
            }
            NSMutableArray *array = [NSMutableArray array];
            for (NSDictionary *dict in result) {
                FCXNewsModel *model = [[FCXNewsModel alloc] initWithDict:dict];
                [array addObject:model];
            }
            
            [_dataArray addObjectsFromArray:array];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
            });
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[FCXNewsDBManager sharedManager] saveFinanceData:array];
            });
            
        }
        finish(hasMore);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        DBLOG(@"fail %@", error.localizedDescription);
        
        BOOL hasMore = NO;
        NSArray *array = [[FCXNewsDBManager sharedManager] getFinanceDataArray:_dataArray.count];
        
        if (array.count > 0) {
            hasMore = YES;
            [_dataArray addObjectsFromArray:array];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [_tableView reloadData];
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
    FCXNewsHomeCell *cell = [tableView dequeueReusableCellWithIdentifier:FCXNewsHomeCellIdentifier];
    if (_showAd && indexPath.row > 8) {
        
        if ((indexPath.row + 1 - 10) % 8 == 0) {
            NSInteger row = (indexPath.row + 1 - 10)/8;
            if (self.adDataArray.count > row) {
                cell.dataModel = self.adDataArray[row];
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
            if (self.adDataArray.count > row) {
                FCXNewsModel *model = self.adDataArray[row];
                [model.nativeAd clickAd:model.adData];
                [MobClick event:@"列表点击" label:[model.adData.properties objectForKey:GDTNativeAdDataKeyTitle]];
                return;
            }
        }
    }
    
    if (_dataArray.count > indexPath.row) {
        FCXNewsModel *dataModel = _dataArray[indexPath.row];
        FCXNewsDetailController *detailVC = [[FCXNewsDetailController alloc] init];
        detailVC.model = dataModel;
        detailVC.admobID = self.admobID;
        detailVC.appID = self.appID;
        [MobClick event:@"列表点击" label:dataModel.title];
        [self.navigationController pushViewController:detailVC animated:YES];
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
            self.adDataArray = [NSMutableArray array];
            _nativeAd = [[GDTNativeAd alloc] initWithAppkey:appkey placementId:placementId];
            
            //            _nativeAd = [[GDTNativeAd alloc] initWithAppkey:@"appkey" placementId:@"6050404087998717"];
            
            _nativeAd.controller = self;
            _nativeAd.delegate = self;
            [_nativeAd loadAd:2];
        }
    }
}

- (void)loadMoreAD {
    NSInteger count = _dataArray.count + 15;
    
    NSInteger row = (count + 1 - 10)/8 + 1;
    
    if (row > self.adDataArray.count) {
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
        [self.adDataArray addObject:model];
    }
    [self loadMoreAD];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_tableView reloadData];
    });
    
}

-(void)nativeAdFailToLoad:(NSError *)error {
    //    NSLog(@"error %@", error.localizedDescription);
}


@end
