//
//  PhotoView.m
//  aoyouHH
//
//  Created by jinzelu on 15/4/30.
//  Copyright (c) 2015年 jinzelu. All rights reserved.
//

#import "PhotoView.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"
#import "AlbumManager.h"

@interface PhotoView ()<UIScrollViewDelegate, UIActionSheetDelegate>
{
    UIScrollView *_scrollView;
    MBProgressHUD *_hud;
    BOOL _showSheet;
    UILongPressGestureRecognizer *_longPress;
}

@end

@implementation PhotoView

-(id)initWithFrame:(CGRect)frame withPhotoUrl:(NSString *)photoUrl{
    self = [super initWithFrame:frame];
    if (self) {
        //添加scrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        //添加图片
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        BOOL isCached = [manager cachedImageExistsForURL:[NSURL URLWithString:photoUrl]];
        if (!isCached) {//没有缓存
            _hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
            _hud.mode = MBProgressHUDModeDeterminate;
        }
        
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoUrl] placeholderImage:[UIImage imageNamed:@"comment_empty_img"] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
            _hud.progress = ((float)receivedSize)/expectedSize;
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
            NSLog(@"图片加载完成");
            if (!isCached) {
                [_hud hide:YES];
            }
        }];
        
        [self.imageView setUserInteractionEnabled:YES];
        [_scrollView addSubview:self.imageView];
        
        //添加手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;//需要点两下
        
        [self.imageView addGestureRecognizer:singleTap];
        [self.imageView addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击了，则不响应单击事件
        
//        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
//        [self.imageView addGestureRecognizer:_longPress];
        
        [_scrollView setZoomScale:1];
    }
    return self;
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
//    NSLog(@"======long");
    if (!_longPress.enabled) {
        return;
    }
    _longPress.enabled = NO;

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存", nil];
    [actionSheet showInView:self.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (self.imageView.image) {

            [[AlbumManager sharedAlbumManager] saveImageToAlbum:self.imageView.image albumName:APP_DISPLAYNAME withCompletionBlock:^(NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:[NSString stringWithFormat:@"您可以打开 设置 - 隐私 - 照片 找到%@，查看%@是否有访问相册的权限，如果没有，打开即可。", APP_DISPLAYNAME, APP_DISPLAYNAME] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                    [alertView show];
                    
                }else{
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.superview animated:YES];
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
        }
    }
    
    _longPress.enabled = YES;
}

-(id)initWithFrame:(CGRect)frame withPhotoImage:(UIImage *)image{
    self = [super initWithFrame:frame];
    if (self) {
        //添加scrollView
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.minimumZoomScale = 1;
        _scrollView.maximumZoomScale = 3;
        
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
        //添加图片
        self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageView setImage:image];
        
        [self.imageView setUserInteractionEnabled:YES];
        [_scrollView addSubview:self.imageView];
        
        //添加手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;//需要点两下
        
        [self.imageView addGestureRecognizer:singleTap];
        [self.imageView addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击了，则不响应单击事件
        
        [_scrollView setZoomScale:1];
    }
    return self;
}

#pragma mark - UIScrollViewDelegate
//scroll view处理缩放和平移手势，必须需要实现委托下面两个方法,另外 maximumZoomScale和minimumZoomScale两个属性要不一样
//1.返回要缩放的图片
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}
//2.重新确定缩放完后的缩放倍数
-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [scrollView setZoomScale:scale+0.01 animated:NO];
    [scrollView setZoomScale:scale animated:NO];
}


#pragma mark - 图片的点击，touch事件
-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer{
//    NSLog(@"单击");
    if (gestureRecognizer.numberOfTapsRequired == 1) {
        [self.delegate TapHiddenPhotoView];
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{
//    NSLog(@"双击");
    if (gestureRecognizer.numberOfTapsRequired == 2) {
        if(_scrollView.zoomScale == 1){
            float newScale = [_scrollView zoomScale] *2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }else{
            float newScale = [_scrollView zoomScale]/2;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
            [_scrollView zoomToRect:zoomRect animated:YES];
        }
    }
}

#pragma mark - 缩放大小获取方法
-(CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    //大小
    zoomRect.size.height = [_scrollView frame].size.height/scale;
    zoomRect.size.width = [_scrollView frame].size.width/scale;
    
    if (scale == 2) {
        CGFloat imageWidth = _scrollView.frame.size.width * scale;
        CGFloat imageHeight = _imageView.image.size.height * (imageWidth/_imageView.image.size.width);
        
        CGFloat heightScale = imageHeight/SCREEN_HEIGHT;
//        NSLog(@"scale %f", heightScale);
        heightScale = MAX(1.5, heightScale);
        zoomRect.size.height = _scrollView.frame.size.height/heightScale;
    }
    

    
    if (scale == 1) {
        zoomRect = self.bounds;
    }
    //原点
    zoomRect.origin.x = center.x - zoomRect.size.width/2;
    zoomRect.origin.y = center.y - zoomRect.size.height/2;

    return zoomRect;
}

- (void)reset {

    if (_scrollView.zoomScale != 1) {
        [_scrollView zoomToRect:self.bounds animated:NO];
    }
}


@end
