//
//  FCXPictureBrowingCell.m
//  FCXPictureBrowsing
//
//  Created by 冯 传祥 on 16/5/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXPictureBrowingCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface FCXPictureBrowingCell () <UIGestureRecognizerDelegate, UIScrollViewDelegate>

@end

@implementation FCXPictureBrowingCell
{
    UIScrollView *_scrollView;
    UIImageView *_imageView;
    MBProgressHUD *_hud;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:.5];
        self.backgroundColor = [UIColor blackColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        [self.contentView addSubview:_scrollView];
        [self.contentView addGestureRecognizer:_scrollView.panGestureRecognizer];
        
        _imageView = [[UIImageView alloc] init];
        _imageView.userInteractionEnabled = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview:_imageView];
        
        //添加手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;//需要点两下
        [singleTap requireGestureRecognizerToFail:doubleTap];//如果双击了，则不响应单击事件

        [_scrollView addGestureRecognizer:singleTap];
        [_scrollView addGestureRecognizer:doubleTap];
        
        _hud = [[MBProgressHUD alloc] initWithView:self];
        _hud.removeFromSuperViewOnHide = YES;
        _hud.mode = MBProgressHUDModeDeterminate;
    }
    return self;
}

#pragma mark - 图片的点击，touch事件
-(void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (self.singleTapBlock) {
        self.singleTapBlock();
    }
}

-(void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer{

    if(fabs(_scrollView.zoomScale - _scrollView.maximumZoomScale) > 0.001) {
        CGFloat width = _scrollView.bounds.size.width / _scrollView.maximumZoomScale;
        CGFloat height = _scrollView.bounds.size.height / _scrollView.maximumZoomScale;
        
        CGPoint touchPoint = [gestureRecognizer locationInView:_imageView];
        [_scrollView zoomToRect:CGRectMake(touchPoint.x - width / 2, touchPoint.y - height / 2, width, height) animated:YES];
    }else {
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _scrollView.frame = self.bounds;
}

- (void)setImageURL:(NSString *)imageURL {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    BOOL isCached = [manager cachedImageExistsForURL:[NSURL URLWithString:imageURL]];
    
    if (_hud.superview) {//复用问题
        [_hud hide:NO];
    }
    if (!isCached) {//没有缓存
        [self addSubview:_hud];
        [_hud show:YES];
    }
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
        _hud.progress = ((float)receivedSize)/expectedSize;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){

        if (!isCached) {
            [_hud hide:YES];
        }
        if (!image || !_imageView.image) {
            return ;
        }
        _imageView.frame = _scrollView.bounds;
        
        CGFloat Rw = _scrollView.frame.size.width/image.size.width;
        CGFloat Rh = _scrollView.frame.size.height/image.size.height;
        CGFloat ratio = MIN(Rw, Rh);
        
        if (Rw > 1 && Rh > 1) {
            _scrollView.minimumZoomScale = ratio;
            _scrollView.maximumZoomScale = MAX(ratio + 2, MAX(Rw, Rh));
        }else {
            _scrollView.minimumZoomScale = MIN(ratio, 1/ratio);
            CGFloat ratio = MAX(Rw, Rh);
            _scrollView.maximumZoomScale = MAX(MAX(ratio, 1/ratio), 2);
        }
        
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:NO];
   
    }];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat Ws = _scrollView.frame.size.width;
    CGFloat Hs = _scrollView.frame.size.height - _scrollView.contentInset.top - _scrollView.contentInset.bottom;
    CGFloat W = _imageView.image.size.width*_scrollView.zoomScale;
    CGFloat H = _imageView.image.size.height*_scrollView.zoomScale;

    CGRect rct = _imageView.frame;
    rct.origin.x = MAX((Ws-W)/2, 0);
    rct.origin.y = MAX((Hs-H)/2, 0);
    rct.size = CGSizeMake(W, H);
    _imageView.frame = rct;
    
    _scrollView.contentSize = rct.size;
}

- (UIImage *)image {
    return _imageView.image;
}

@end
