//
//  JZAlbumViewController.m
//  aoyouHH
//
//  Created by jinzelu on 15/4/27.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import "JZAlbumViewController.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "PhotoView.h"
#import "JZAlbumViewController.h"
#import "UIButton+Block.h"
#import "AlbumManager.h"
#import "FCXDefine.h"

@interface JZAlbumViewController ()<UIScrollViewDelegate,PhotoViewDelegate>
{
    CGFloat lastScale;
    MBProgressHUD *HUD;
    NSMutableArray *_subViewList;
    UILabel *_bottomLabel;
    NSInteger _lastIndex;
}

@end

@implementation JZAlbumViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //
        _subViewList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    lastScale = 1.0;
    self.view.backgroundColor = [UIColor blackColor];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnTapView)];
//    [self.view addGestureRecognizer:tap];

    [self initScrollView];
    [self setPicCurrentIndex:self.currentIndex];
    
    _lastIndex = self.currentIndex;
    
    _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 44, SCREEN_WIDTH, 44)];
    _bottomLabel.backgroundColor = [UICOLOR_FROMRGB(0x25272a) colorWithAlphaComponent:.3];
    _bottomLabel.textColor = [UIColor whiteColor];
    _bottomLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    _bottomLabel.userInteractionEnabled = YES;
    [self.view addSubview:_bottomLabel];
    
    UIButton *downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downLoadBtn setImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
    downLoadBtn.frame = CGRectMake(SCREEN_WIDTH - 60, 0, 60, 40);
    [_bottomLabel addSubview:downLoadBtn];
    [downLoadBtn defaultControlEventsWithHandler:^(UIButton *button) {
        PhotoView *currentPhotoView = [_subViewList objectAtIndex:_lastIndex];
        [[AlbumManager sharedAlbumManager] saveImageToAlbum:currentPhotoView.imageView.image albumName:APP_DISPLAYNAME withCompletionBlock:^(NSError *error) {
            if (error) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:[NSString stringWithFormat:@"您可以打开 设置 - 隐私 - 照片 找到%@，查看%@是否有访问相册的权限，如果没有，打开即可。", APP_DISPLAYNAME, APP_DISPLAYNAME] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                
            }else{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                UIImage *image = [UIImage imageNamed:@"checkmark"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                hud.customView = imageView;
                hud.mode = MBProgressHUDModeCustomView;
                hud.labelText = @"保存成功!";
                hud.labelColor = [UIColor whiteColor];
                hud.backgroundColor = [UIColor colorWithWhite:0 alpha:.8];
                hud.minSize = CGSizeMake(150.f, 100.f);
                [hud hide:YES afterDelay:.7];                
            }
        }];
        
    }];

    if (self.imgArr.count > 1) {
        _bottomLabel.text = [NSString stringWithFormat:@"   %ld/%ld", self.currentIndex + 1, self.imgArr.count];
    }
    
}

-(void)initScrollView{
//    [[SDImageCache sharedImageCache] cleanDisk];
//    [[SDImageCache sharedImageCache] clearMemory];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,  SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    self.scrollView.contentSize = CGSizeMake(self.imgArr.count*SCREEN_WIDTH, SCREEN_HEIGHT);
    self.scrollView.delegate = self;
    self.scrollView.contentOffset = CGPointMake(0, 0);
    //设置放大缩小的最大，最小倍数
//    self.scrollView.minimumZoomScale = 1;
//    self.scrollView.maximumZoomScale = 2;
    [self.view addSubview:self.scrollView];
    
    for (int i = 0; i < self.imgArr.count; i++) {
        [_subViewList addObject:[NSNull class]];
    }

}

-(void)setPicCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*currentIndex, 0);
    [self loadPhote:_currentIndex];
    [self loadPhote:_currentIndex+1];
    [self loadPhote:_currentIndex-1];
}

-(void)loadPhote:(NSInteger)index{
    if (index<0 || index >=self.imgArr.count) {
        return;
    }
    
    id currentPhotoView = [_subViewList objectAtIndex:index];
    if (![currentPhotoView isKindOfClass:[PhotoView class]]) {
        //url数组
        CGRect frame = CGRectMake(index*_scrollView.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height);
        PhotoView *photoV = [[PhotoView alloc] initWithFrame:frame withPhotoUrl:[self.imgArr objectAtIndex:index]];
        photoV.delegate = self;
        [self.scrollView insertSubview:photoV atIndex:0];
        [_subViewList replaceObjectAtIndex:index withObject:photoV];
    }
}

#pragma mark - PhotoViewDelegate
-(void)TapHiddenPhotoView{
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)OnTapView{
    [self dismissViewControllerAnimated:NO completion:nil];
}
//手势
-(void)pinGes:(UIPinchGestureRecognizer *)sender{
    if ([sender state] == UIGestureRecognizerStateBegan) {
        lastScale = 1.0;
    }
    CGFloat scale = 1.0 - (lastScale -[sender scale]);
    lastScale = [sender scale];
    self.scrollView.contentSize = CGSizeMake(self.imgArr.count*SCREEN_WIDTH, SCREEN_HEIGHT*lastScale);
//    NSLog(@"scale:%f   lastScale:%f",scale,lastScale);
    CATransform3D newTransform = CATransform3DScale(sender.view.layer.transform, scale, scale, 1);
    
    sender.view.layer.transform = newTransform;
    if ([sender state] == UIGestureRecognizerStateEnded) {
        //
    }
}

#pragma mark - UIScrollViewDelegate
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"scrollViewDidEndDecelerating");
//    int i = scrollView.contentOffset.x/SCREEN_WIDTH;
//    [self loadPhote:i];
//    _pageControl.currentPage = i;
//}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int i = (scrollView.contentOffset.x + SCREEN_WIDTH/2.0) / SCREEN_WIDTH;
    if (i != _lastIndex) {

        PhotoView *lastPhotoView = [_subViewList objectAtIndex:_lastIndex];
        if ([lastPhotoView isKindOfClass:[PhotoView class]]) {
            //url数组
            [lastPhotoView reset];
        }

        _lastIndex = i;
        _bottomLabel.text = [NSString stringWithFormat:@"   %ld/%ld", _lastIndex + 1, self.imgArr.count];
    }
    [self loadPhote:i - 1];
    [self loadPhote:i];
    [self loadPhote:i + 1];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
