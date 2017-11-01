//
//  FCXNewsDetailController.m
//  News
//
//  Created by 冯 传祥 on 16/4/23.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNewsDetailController.h"
#import "AFNetWorking.h"
#import "FCXNewsDBManager.h"
#import "GDTNativeAd.h"
#import "SKRating.h"
#import "UIImageView+WebCache.h"
#import "FCXPictureBrowingView.h"
#import "UIVIew+Frame.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "FCXShareManager.h"
#import "UIButton+Block.h"
#import "FCXWebViewController.h"
#import "FCXDefine.h"
#import "SKOnlineConfig.h"
#import "UMMobClick/MobClick.h"

static NSString *const FCXDetailCellIdentifier = @"FCXDetailCellIdentifier";
#define BGCOLOR UICOLOR_FROMRGB(0xf7f7f7)

@interface FCXNewsDetailCell : UITableViewCell
{
    UILabel *_titleLabel;
}

@property (nonatomic, strong)FCXNewsModel *dataModel;

@end

@implementation FCXNewsDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, SCREEN_WIDTH - 20 - 30 - 25, 60)];
        //        _titleLabel.textColor = UICOLOR_FROMRGB(0x343233);
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)setDataModel:(FCXNewsModel *)dataModel {
    
    if (_dataModel != dataModel) {
        _dataModel = dataModel;
        _titleLabel.text = dataModel.title;
    }
}

@end





@interface FCXNewsDetailController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource, GDTNativeAdDelegate>
{
    UIWebView *_webView;
    UITableView *_tableView;
    NSMutableArray *_dataArray;
    UIView *_bottomView;
    GDTNativeAd *_nativeAd;
    UIButton *_adBtn;
    UIWebView *_shareWebView;
}

@property (nonatomic, strong)GDTNativeAdData *adData;
@property (nonatomic, strong)NSArray *imageArray;

@end

@implementation FCXNewsDetailController

- (void)dealloc {
    [_webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"nav_more"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"nav_more_h"] forState:UIControlStateHighlighted];
    rightBtn.frame = CGRectMake(0, 0, 60, 44);
    rightBtn.tag = 666;
    rightBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 25, 0, 0);
    [rightBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - Nav_StatusBar_Height)];
    _webView.backgroundColor = UICOLOR_FROMRGB(0xf7f7f7);
    _webView.delegate = self;
    _webView.userInteractionEnabled = YES;
    _webView.scrollView.userInteractionEnabled = YES;
    _webView.scrollView.backgroundColor = _webView.backgroundColor;
    [_webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    _webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:_webView];
    
    _shareWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - Nav_StatusBar_Height)];
    _shareWebView.backgroundColor = _webView.backgroundColor;
    _shareWebView.delegate = self;
    _shareWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    if ([[SKOnlineConfig getConfigParams:@"detail_showH5" defaultValue:@"0"] isEqualToString:@"1"]) {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.model.url]];
        [_webView loadRequest:request];
        [_shareWebView loadRequest:request];
        
        [self setupAd];
        [SKRating startRating:self.appID apppKey:_ratingKey controller:self finish:nil];
        return;
    }
    
    _dataArray = [[NSMutableArray alloc] init];
    if (self.model.content.length < 1) {
        [[FCXNewsDBManager sharedManager] queryNewsModel:self.model];
    }
    
    if (self.model.content.length > 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString *content = self.model.content;
            NSString *source;
            if ([[SKOnlineConfig getConfigParams:@"showSource" defaultValue:@"0"] boolValue]) {
                source = self.model.source;
            }else {
                source = APP_DISPLAYNAME;
            }
            
            content = [content stringByReplacingOccurrencesOfString:@"</h3>" withString:[NSString stringWithFormat:@"</h3><p style='font-size:15px;color:#9b9b9b;padding:5px 0;margin:0;'>%@   %@</p>", source, self.model.showDate]];
            
            NSArray *array;
            if ([self.model.relatedDocs isKindOfClass:[NSString class]] && self.model.relatedDocs.length > 0) {
                array = [NSJSONSerialization JSONObjectWithData:[self.model.relatedDocs dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            }
            if ([array isKindOfClass:[NSArray class]]) {
                for (NSDictionary *subDict in array) {
                    FCXNewsModel *model = [[FCXNewsModel alloc] initWithDict:subDict];
                    [_dataArray addObject:model];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_webView loadHTMLString:content baseURL:nil];
                [_shareWebView loadHTMLString:content baseURL:nil];
                [self setupTableView];
            });
        });
    }else {
        [self requestDetailData];
    }
    
    [self setupAd];
    [SKRating startRating:self.appID apppKey:_ratingKey controller:self finish:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentSize"]) {
        //       NSLog(@"observeValueForKeyPath height %f", _webView.scrollView.contentSize.height);
        [self adjustFrame];
    }
}

- (void)setupTableView {
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, SCREEN_HEIGHT, SCREEN_WIDTH - 30, _dataArray.count * 60 + 40) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = _webView.backgroundColor;
    _tableView.separatorColor = UICOLOR_FROMRGB(0xd8d8d8);
    _tableView.layer.borderColor = _tableView.separatorColor.CGColor;
    _tableView.layer.borderWidth = .5;
    _tableView.separatorInset = UIEdgeInsetsMake(0, 10, 0, 0);
    if ([_tableView respondsToSelector:@selector(layoutMargins)]) {
        _tableView.layoutMargins = UIEdgeInsetsMake(0, 10, 0, 0);
    }
    [_tableView registerClass:[FCXNewsDetailCell class] forCellReuseIdentifier:FCXDetailCellIdentifier];
    [_webView.scrollView addSubview:_tableView];
    
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
    _bottomView.backgroundColor = _webView.backgroundColor;
    [self addLine:_bottomView];
    [self addShareButtons:_bottomView];
    [self addBottom:_bottomView];
    
    [_webView.scrollView addSubview:_bottomView];
    
    if (_dataArray.count > 0) {
        UILabel *headLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 40)];
        headLabel.text = @"  热门推荐";
        headLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        headLabel.backgroundColor = [UIColor whiteColor];
        _tableView.tableHeaderView = headLabel;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(10, 39.5, SCREEN_WIDTH - 40, .5)];
        line.backgroundColor = _tableView.separatorColor;
        [headLabel addSubview:line];
        
        [_tableView addSubview:line];
    }else {
        _tableView.height = 0;
    }
}

- (void)addLine:(UIView *)superView {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:self.view.bounds];
    [shapeLayer setPosition:self.view.center];
    [shapeLayer setFillColor:[[UIColor clearColor] CGColor]];
    
    // 设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:[UICOLOR_FROMRGB(0xc8c8c8) CGColor]];
    
    // 3.0f设置虚线的宽度
    [shapeLayer setLineWidth:1.0f];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    // 3=线的宽度 1=每条线的间距
    [shapeLayer setLineDashPattern:
     [NSArray arrayWithObjects:[NSNumber numberWithInt:3],
      [NSNumber numberWithInt:2],nil]];
    
    // Setup the path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 10, 10);
    CGPathAddLineToPoint(path, NULL, SCREEN_WIDTH - 20, 10);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    [[superView layer] addSublayer:shapeLayer];
    
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake((superView.width - 50)/2.0, 10 - 7.5, 50, 15)];
    shareLabel.textAlignment = NSTextAlignmentCenter;
    shareLabel.backgroundColor = _webView.backgroundColor;
    shareLabel.text = @"分享";
    shareLabel.textColor = UICOLOR_FROMRGB(0x6f6f6f);
    shareLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    [superView addSubview:shareLabel];
}

-(void)addShareButtons:(UIView *)superView {
    CGFloat topHeight = 35;
    int i = 0;
    NSInteger coloumn = 4;
    CGFloat buttonWidth = 54;
    CGFloat buttonHeighh = 85;
    CGFloat space = (SCREEN_WIDTH - buttonWidth * coloumn)/5.0;
    
    for (int j = 0; j < coloumn; j++) {
        CGRect buttonFrame = CGRectMake(space + (i%coloumn) * (buttonWidth + space), topHeight + (i/coloumn) * (buttonHeighh + 5), buttonWidth, buttonHeighh);
        
        UIButton *shareButton;
        switch (j) {
            case 0:
            {//微信
                if ([WXApi isWXAppInstalled]) {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame
                                                               tag:FCXSharePlatformWXSession
                                                             title:@"微信"
                                                       normalImage:@"detail_wx"
                                                  highlightedImage:@"detail_wx_h"];
                }
            }
                break;
            case 1:
            {//微信朋友圈
                if ([WXApi isWXAppInstalled]) {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame
                                                               tag:FCXSharePlatformWXTimeline
                                                             title:@"朋友圈"
                                                       normalImage:@"detail_wxfc"
                                                  highlightedImage:@"detail_wxfc_h"];
                }
            }
                break;
            case 2:
            {//QQ
                if ([QQApiInterface isQQInstalled]) {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame
                                                               tag:FCXSharePlatformQQ
                                                             title:@"QQ"
                                                       normalImage:@"detail_qq"
                                                  highlightedImage:@"detail_qq_h"];
                }
            }
                break;
            case 3:
            {//更多
                if (i > 0) {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame
                                                               tag:666
                                                             title:@"更多"
                                                       normalImage:@"detail_more"
                                                  highlightedImage:@"detail_more_h"];
                }else {
                    i++;
                    shareButton = [self createShareButtonWithFrame:buttonFrame
                                                               tag:FCXSharePlatformSina
                                                             title:@"新浪微博"
                                                       normalImage:@"detail_sina"
                                                  highlightedImage:@"detail_sina_h"];
                }
            }
                break;
        }
        [superView addSubview:shareButton];
    }
}

- (void)addBottom:(UIView *)superView {
    
    if (![[SKOnlineConfig getConfigParams:@"showSource" defaultValue:@"0"] boolValue]) {
        return;
    }
    
    CGFloat top = 120 + 30;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(10, top, 130-2, 44);
    [superView addSubview:btn];
    
    __weak typeof(self) weakSelf = self;
    
    [btn defaultControlEventsWithHandler:^(UIButton *button) {
        FCXWebViewController *webView = [[FCXWebViewController alloc] init];
        webView.urlString = weakSelf.model.url;
        webView.admobID = [SKOnlineConfig getConfigParams:@"AdmobID" defaultValue:self.admobID];
        webView.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav_logo"]];
        [weakSelf.navigationController pushViewController:webView animated:YES];
    }];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@"[点击查看原文]"];
    [attributedStr addAttribute:NSFontAttributeName
                          value:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]
                          range:NSMakeRange(0, 8)];
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:UICOLOR_FROMRGB(0x343233)
                          range:NSMakeRange(0, 1)];
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:UICOLOR_FROMRGB(0xdf3030)
                          range:NSMakeRange(1, 6)];
    [attributedStr addAttribute:NSForegroundColorAttributeName
                          value:UICOLOR_FROMRGB(0x343233)
                          range:NSMakeRange(7, 1)];
    [btn setAttributedTitle:attributedStr forState:UIControlStateNormal];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, top + 40, SCREEN_WIDTH - 30, 30)];
    label.textColor = UICOLOR_FROMRGB(0x838383);
    label.text = @"本文是搜索转码后的内容，不代表本软件观点";
    label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    label.adjustsFontSizeToFitWidth = YES;
    [superView addSubview:label];
}

-(UIButton *)createShareButtonWithFrame:(CGRect)frame
                                    tag:(int)tag
                                  title:(NSString *)title
                            normalImage:(NSString *)normalImage
                       highlightedImage:(NSString *)highlightedImage {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.tag = tag;
    [button setTitle:title forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:normalImage] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    button.titleEdgeInsets = UIEdgeInsetsMake(80, -54, 0, 0);
    [button setTitleColor:UICOLOR_FROMRGB(0x343233) forState:UIControlStateNormal];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    button.exclusiveTouch = YES;
    return button;
}

#pragma mark - 分享

-(void)shareAction:(UIButton *)button {
    FCXShareManager *shareManager = [FCXShareManager sharedManager];
    shareManager.shareType = FCXShareTypeImage;
    shareManager.shareImage = [self getShareImage];
    shareManager.shareTitle = self.shareTitle;
    shareManager.presentedController = self;
    
    if (button.tag == FCXSharePlatformWXSession) {
        [shareManager shareToWXSession];
        [MobClick event:@"详情页分享" label:[NSString stringWithFormat:@"微信-%@", self.model.title]];
    }else if (button.tag == FCXSharePlatformQQ) {
        [shareManager shareToQQ];
        [MobClick event:@"详情页分享" label:[NSString stringWithFormat:@"QQ-%@", self.model.title]];
    }else if (button.tag == FCXSharePlatformWXTimeline) {
        [shareManager shareToWXTimeline];
        [MobClick event:@"详情页分享" label:[NSString stringWithFormat:@"朋友圈-%@", self.model.title]];
    }else if(button.tag == FCXSharePlatformSina) {
        [shareManager shareToSina];
        [MobClick event:@"详情页分享" label:[NSString stringWithFormat:@"新浪-%@", self.model.title]];
    }else {
        [shareManager showImageShare];
        [MobClick event:@"详情页分享" label:@"更多"];
    }
}

- (UIImage *)getShareImage {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    CGFloat totalHeight = MAX(SCREEN_HEIGHT, 64 + _webView.scrollView.contentSize.height + 260);
    _shareWebView.height = totalHeight - 64;
    
    //内容
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, _shareWebView.height), NO, scale);
    [_shareWebView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *contentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //导航条
    CGRect rect = CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, 64);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self.shareNavColor CGColor]);
    CGContextFillRect(context, rect);
    UIImage *barImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage *QRImg = [self createQRCodeWithText:[NSString stringWithFormat: @"https://itunes.apple.com/app/id%@", [SKOnlineConfig getConfigParams:@"share_AppID" defaultValue:self.appID]] size:150.f];
    UIImage *iconImage = self.shareIconImage;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(SCREEN_WIDTH, totalHeight), NO, scale);
    //导航条
    [barImage drawInRect:CGRectMake(0, 0, SCREEN_WIDTH, 64)];

    //内容
    [contentImage drawInRect:CGRectMake(0, 64, SCREEN_WIDTH, _shareWebView.height)];
    //底部上方一行文字
    NSString *text = [NSString stringWithFormat:@"%@ %@", self.shareLeftText, self.shareRightText];
    
    //设置字体
    NSMutableParagraphStyle* style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    [style setAlignment:NSTextAlignmentCenter];
    
    NSDictionary* dict=@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:22], NSForegroundColorAttributeName : self.shareNavTitleColor,  NSParagraphStyleAttributeName : style};
    //标题
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.shareNavTitle attributes:dict];

    //获得size
    CGSize strSize = [text sizeWithAttributes:dict];
    CGFloat marginTop = (44 - strSize.height)/2.0;
    [attributedString drawInRect:CGRectMake(0, 20 + marginTop, SCREEN_WIDTH, strSize.height)];

    //分享文字
    attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.shareLeftColor range:NSMakeRange(0, self.shareLeftText.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Helvetica-Bold" size:20] range:NSMakeRange(0, self.shareLeftText.length)];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:self.shareRightColor range:NSMakeRange(self.shareLeftText.length, text.length - self.shareLeftText.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(self.shareLeftText.length, text.length - self.shareLeftText.length)];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    
    [attributedString drawInRect:CGRectMake(0, totalHeight - 230, SCREEN_WIDTH, 24)];
    
    [QRImg drawInRect:CGRectMake((SCREEN_WIDTH - 150)/2.0, totalHeight - 230 + 40, 150, 150)];
    [iconImage drawInRect:CGRectMake((SCREEN_WIDTH - 34)/2.0, totalHeight - 230 + 40 + (150 - 34)/2.0, 34, 34)];
    
    dict=@{NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Light" size:15], NSForegroundColorAttributeName : UICOLOR_FROMRGB(0xababab),  NSParagraphStyleAttributeName : style};
    
    attributedString = [[NSMutableAttributedString alloc] initWithString:@"长按或扫描下载" attributes:dict];
    [attributedString drawInRect:CGRectMake(0, totalHeight - 30, SCREEN_WIDTH, 20)];
    
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

- (UIImage *)createQRCodeWithText:(NSString *)text size:(CGFloat) size{
    // 1.创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.设置相关的信息
    [filter setDefaults];
    
    // 3.设置二维码的数据
    NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    // KVO 方式
    [filter setValue:data forKeyPath:@"inputMessage"];
    
    // 4.获取输出的图片
    CIImage *image = [filter outputImage];
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    UIImage *newimage = [UIImage imageWithCGImage:scaledImage];
    
    return [self imageBlackToTransparent:newimage withRed:0 andGreen:0 andBlue:0];
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

- (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
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
    FCXNewsDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FCXDetailCellIdentifier];
    if (_dataArray.count > indexPath.row) {
        cell.dataModel = _dataArray[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_dataArray.count > indexPath.row) {
        FCXNewsModel *dataModel = _dataArray[indexPath.row];

        FCXNewsDetailController *detailVC = [[FCXNewsDetailController alloc] init];
        detailVC.model = dataModel;
        detailVC.admobID = [SKOnlineConfig getConfigParams:@"AdmobID" defaultValue:self.admobID];
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
        
        UIView *titleView = self.navigationItem.titleView;
        if ([titleView isKindOfClass:[UIImageView class]]) {
            UIImage *image = [(UIImageView *)self.navigationItem.titleView image];
            detailVC.navigationItem.titleView =[[UIImageView alloc] initWithImage:image];
        } else {
            UILabel *titleLabel = (UILabel *)titleView;
            UILabel *label = [[UILabel alloc] initWithFrame:titleLabel.frame];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = titleLabel.font;
            label.textColor = titleLabel.textColor;
            label.text = titleLabel.text;
            detailVC.navigationItem.titleView = label;
        }
        [self.navigationController pushViewController:detailVC animated:YES];
        [MobClick event:@"详情页热门推荐点击" label:dataModel.title];
    }
}

- (void)requestDetailData {
    
    NSString *urlStr = [NSString stringWithFormat:@"http://a1.go2yd.com/Website/contents/content?version=020100&distribution=com.apple.appstore&appid=yidian&cv=4.1.0.8&platform=0&net=wifi&version=020100&distribution=com.apple.appstore&appid=yidian&cv=4.1.0.8&platform=0&net=wifi&appid=yidian&bottom_channels=true&bottom_comments=true&cv=4.1.0.8&distribution=com.apple.appstore&docid=%@&highlight=true&net=wifi&platform=0&related_docs=true&version=020100", self.model.docid];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json", nil];
    
    [manager GET:urlStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DBLOG(@"respon %@", responseObject);
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *documents = responseObject[@"documents"];
            NSDictionary *dict = documents[0];
            __block NSString *content = dict[@"content"];
            NSString *title = dict[@"title"];
            NSString *date = dict[@"date"];
            date = [FCXNewsModel getShowDateString:date];
            NSString *source;
            if ([[SKOnlineConfig getConfigParams:@"showSource" defaultValue:@"0"] boolValue]) {
                source = dict[@"source"];
            }else {
                source =  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            }
            
            NSRange range = [content rangeOfString:@"type=thumbnai"];
            while (range.location != NSNotFound) {
                NSRange range1 = [content rangeOfString:@"&amp;url"];
                if (range1.location == NSNotFound) {
                    break;
                }
                NSString *subString = [content substringWithRange:NSMakeRange(range.location, range1.location - range.location + 5)];
                //            NSLog(@"subStr %@", subString);
                content = [content stringByReplacingOccurrencesOfString:subString withString:[NSString stringWithFormat:@"%d", arc4random()%3+1]];
                range = [content rangeOfString:@"type=thumbnai"];
                
            }
            
            content = [content stringByReplacingOccurrencesOfString:@"image1.hipu.com/image.php?1" withString:@"i1.go2yd.com/image.php?"];
            content = [content stringByReplacingOccurrencesOfString:@"image1.hipu.com/image.php?2" withString:@"i2.go2yd.com/image.php?"];
            content = [content stringByReplacingOccurrencesOfString:@"image1.hipu.com/image.php?3" withString:@"i3.go2yd.com/image.php?"];
            content = [content stringByReplacingOccurrencesOfString:@"href=\"http://www." withString:@""];
            
            
            if ([content hasPrefix:@"<body>"]) {
                content = [content stringByReplacingOccurrencesOfString:@"<body>" withString:[NSString stringWithFormat:@"<script>function A(url){jumpUrl(url)};function jumpUrl(url){return url;}</script><style>h3,p{padding:0;margin:0;}body{font-weight:100;font-family:Hiragino Sans GB;background-color:#f7f7f7;color:#222222;line-height:1.6em;margin:15px;text-align:left;font-size:18px;}p{letter-spacing:1px;margin:0 0 20px}h3{font-size:22px;color:#0c0c0c;line-height:1.2em;}</style><body><h3>%@</h3>", title]];
            }else {
                content = [NSString stringWithFormat:@"<script>function A(url){jumpUrl(url)};function jumpUrl(url){return url;}</script><style>h3,p{padding:0;margin:0;}body{font-weight:100;font-family:Hiragino Sans GB;background-color:#f7f7f7;color:#222222;line-height:1.6em;margin:15px;text-align:left;font-size:18px;}p{letter-spacing:1px;margin:0 0 20px}h3{font-size:22px;color:#0c0c0c;line-height:1.2em;}</style><h3>%@</h3>%@", title, content];
            }
            
            self.model.url = dict[@"url"];
            self.model.content = content;
            NSArray *array = dict[@"related_docs"];
            if ([array isKindOfClass:[NSArray class]]) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
                self.model.relatedDocs = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            [[FCXNewsDBManager sharedManager] updateNewsModel:self.model];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                content = [content stringByReplacingOccurrencesOfString:@"</h3>" withString:[NSString stringWithFormat:@"</h3><p style='font-size:15px;color:#9b9b9b;padding:5px 0;margin:0;'>%@   %@</p>", source, date]];
                
                [_webView loadHTMLString:content baseURL:nil];
                [_shareWebView loadHTMLString:content baseURL:nil];
                
                if ([array isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *subDict in array) {
                        FCXNewsModel *model = [[FCXNewsModel alloc] initWithDict:subDict];
                        [_dataArray addObject:model];
                    }
                }
                [self setupTableView];
                
            });
            
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //        NSLog(@"fail %@", error.localizedDescription);
        
    }];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //    [_webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];                //禁用长按选中文字
    [webView stringByEvaluatingJavaScriptFromString:@"var As=document.getElementsByTagName(\"a\");for(var i = 0,length = As.length;i<length;i++){As[i].removeAttribute(\"href\");}"];
    
    [webView stringByEvaluatingJavaScriptFromString:@"var Imags=document.getElementsByTagName(\"img\");for(var i= 0,length=Imags.length;i<length;i++){Imags[i].style.width=\"100%\";Imags[i].style.height=\"\";Imags[i].removeAttribute(\"height\");}"];
    
    //    NSString * clientheight_str = ;
    [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    [self adjustFrame];
    //
    //    NSLog(@"%@", clientheight_str);
    
    
    //    NSLog(@"content %f ===%f", _webView.scrollView.contentSize.height, _webView.scrollView.contentSize.height - clientheight_str.floatValue);
    
    static  NSString * const jsGetImages =
    @"function getImages(){\
    var objs = document.getElementsByTagName(\"img\");\
    var imgScr = '';\
    for(var i=0;i<objs.length;i++){\
    objs[i].onclick=function(){\
    document.location=\"myweb:imageClick:\"+this.src;\
    };\
    imgScr = imgScr + objs[i].src + ',';\
    };\
    return imgScr;\
    };";
    
    
    
    [webView stringByEvaluatingJavaScriptFromString:jsGetImages];//注入js方法
    //注入自定义的js方法后别忘了调用 否则不会生效
    NSString *resurlt = [webView stringByEvaluatingJavaScriptFromString:@"getImages()"];//调用js方法
    //     NSLog(@"%@  %s  jsMehtods_result = %@",self.class,__func__,resurlt);
    if (resurlt.length > 0) {
        resurlt = [resurlt substringToIndex:resurlt.length - 1];
        self.imageArray = [resurlt componentsSeparatedByString:@","];
    }
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitUserSelect='none';"];
    
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //    NSLog(@"url %@", request.URL);
    NSString *requestString = [[request URL] absoluteString];
    
    if ([requestString hasPrefix:@"myweb:imageClick:"]) {
        NSString *imageUrl = [requestString substringFromIndex:@"myweb:imageClick:".length];
        //        NSLog(@"image url=%@ index %d", imageUrl, [self.imageArray indexOfObject:imageUrl]);
        
        FCXPictureBrowingView *browingView = [[FCXPictureBrowingView alloc] init];
        browingView.dataArray = self.imageArray;
        browingView.currentIndex = [self.imageArray indexOfObject:imageUrl];
        [browingView show];
        return NO;
    }
    return YES;
}

- (void)adjustFrame {
    _bottomView.top = _webView.scrollView.contentSize.height + 15;
    _adBtn.top = _webView.scrollView.contentSize.height + 15 + _bottomView.height;
    _tableView.top = MAX(_adBtn.bottom + 15, _bottomView.bottom);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _webView.scrollView.contentInset = UIEdgeInsetsMake(0, 0, 15 + _bottomView.height + _adBtn.height + _dataArray.count * 60 + 40 + 60, 0);
    });
}

- (void)setupAd {
    BOOL showAd = [[SKOnlineConfig getConfigParams:@"showGDT" defaultValue:@"0"] boolValue];
    if (showAd) {
        
        NSString *paramsString = [SKOnlineConfig getConfigParams:@"GDT_Info"];
        if (!paramsString) {
            paramsString = @"";
        }
        NSDictionary *dict  = [NSJSONSerialization JSONObjectWithData:[paramsString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if([dict isKindOfClass:[NSDictionary class]]){
            NSString *appkey = dict[@"appkey"];;
            NSString *placementId = dict[@"placementId"];
            
            _nativeAd = [[GDTNativeAd alloc] initWithAppkey:appkey placementId:placementId];
            //            _nativeAd = [[GDTNativeAd alloc] initWithAppkey:@"appkey" placementId:@"6050404087998717"];
            
            _nativeAd.controller = self;
            _nativeAd.delegate = self;
            [_nativeAd loadAd:1];
        }
    }
}


- (void)nativeAdSuccessToLoad:(NSArray *)nativeAdDataArray {
    
    self.adData = nativeAdDataArray[0];
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat space = 13;
        
        _adBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _adBtn.backgroundColor = [UIColor whiteColor];
        _adBtn.layer.borderWidth = .5;
        _adBtn.layer.borderColor = UICOLOR_FROMRGB(0xd8d8d8).CGColor;
        _adBtn.layer.cornerRadius = 3;
        _adBtn.top = SCREEN_HEIGHT;
        [_webView.scrollView addSubview:_adBtn];
        
        [_adBtn defaultControlEventsWithHandler:^(UIButton *button) {
            [MobClick event:@"详情页" label:@"点击广告"];
            [_nativeAd clickAd:weakSelf.adData];
        }];
        
        [_webView.scrollView addSubview:_adBtn];
        
        //推广
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(space, space, 30, 16)];
        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.layer.cornerRadius = 3;
        label.clipsToBounds = YES;
        label.layer.borderColor = UICOLOR_FROMRGB(0x888888).CGColor;
        label.layer.borderWidth = .5;
        label.text = [SKOnlineConfig getConfigParams:@"advertName" defaultValue:@"推广"];
        label.textAlignment = NSTextAlignmentCenter;
        [_adBtn addSubview:label];
        
        //标题
        UILabel *_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.right + 5, label.top, SCREEN_WIDTH - label.right - space * 4 - 12 - 30, 16)];
        _titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        //    _titleLabel.textColor = BERGBColor(38.0, 38.0, 38.0);
        _titleLabel.text = [NSString stringWithFormat:@"%@", [weakSelf.adData.properties objectForKey:GDTNativeAdDataKeyTitle]];
        [_adBtn addSubview:_titleLabel];
        //        _titleLabel.backgroundColor = [UIColor redColor];
        
        UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30 - 12 - space - 1, _titleLabel.top, 12, 16)];
        arrowImageView.image = [UIImage imageNamed:@"arrow"];
        [_adBtn addSubview:arrowImageView];
        
        UIImageView *_imageView = [[UIImageView alloc] init];
        _imageView.layer.shouldRasterize = YES;
        //    _imageView.layer.cornerRadius = 27;
        _imageView.clipsToBounds = YES;
        _imageView.backgroundColor = [UIColor redColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [_adBtn addSubview:_imageView];
        
        
        [_imageView sd_setImageWithURL:[NSURL URLWithString:[weakSelf.adData.properties objectForKey:GDTNativeAdDataKeyImgUrl]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            CGFloat width = SCREEN_WIDTH - 30 - space * 2;
            CGFloat height = image.size.height * (width/image.size.width);
            
            _imageView.frame = CGRectMake(space, _titleLabel.bottom + 5, width, height);
            
            _adBtn.frame = CGRectMake(space, _adBtn.top, SCREEN_WIDTH - 30, 16 + 5 + height + space * 2);
            [self adjustFrame];
        }];
        
        
        /*
         * 广告数据渲染完毕，即将展示时需调用AttachAd方法。
         */
        [_nativeAd attachAd:weakSelf.adData toView:_adBtn];
        
    });
}


-(void)nativeAdFailToLoad:(NSError *)error {
    DBLOG(@"error %@", error.localizedDescription);
}

- (NSString *)shareLeftText {
    return _shareLeftText ? _shareLeftText : APP_DISPLAYNAME;
}

- (NSString *)shareRightText {
    return _shareRightText ? _shareRightText : [@"掌握第1手"  stringByAppendingString:APP_DISPLAYNAME];
}

- (UIColor *)shareLeftColor {
    return  _shareLeftColor ? _shareLeftColor : [UIColor blackColor];
}

- (UIColor *)shareRightColor {
    return _shareRightColor ? _shareRightColor : UICOLOR_FROMRGB(0x5b5b5b);
}

- (UIColor *)shareNavColor {
    return _shareNavColor ? _shareNavColor : self.navigationController.navigationBar.barTintColor;
}

- (UIColor *)shareNavTitleColor {
    return _shareNavTitleColor ? _shareNavTitleColor : [UIColor blackColor];
}

- (NSString *)shareNavTitle {
    return _shareNavTitle ? _shareNavTitle : APP_DISPLAYNAME;
}

- (UIImage *)shareIconImage {
    if (_shareIconImage) {
        return _shareIconImage;
    }
    
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
    UIImage *image = [UIImage imageNamed:icon];
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, image.size.width, image.size.height) cornerRadius:10].CGPath);
    CGContextClip(context);
    
    CGFloat space = 3;
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(space, space, image.size.width - space * 2, image.size.height - space * 2) cornerRadius:5];
    
    [[UIColor whiteColor] set];
    UIRectFill(CGRectMake(0, 0, image.size.width, image.size.height));
    [cornerPath addClip];
    
    [image drawInRect:CGRectMake(space, space, image.size.width - 2 * space, image.size.height - 2 * space)];
    UIImage *resultImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImage;
}

@end
