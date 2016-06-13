//
//  FCXPictureBrowingView.m
//  FCXPictureBrowsing
//
//  Created by 冯 传祥 on 16/5/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXPictureBrowingView.h"
#import "FCXPictureBrowingCell.h"
#import "UIButton+Block.h"
#import "AlbumManager.h"
#import "MBProgressHUD.h"

@interface FCXPictureBrowingView () <UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>
{
    UICollectionView *_collectionView;
    UILabel *_bottomLabel;
}
@end

@implementation FCXPictureBrowingView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        [self setupCollectionView];
        [self setupBottomView];
    }
    return self;
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout alloc];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = [UIScreen mainScreen].bounds.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.minimumInteritemSpacing = 0;
    
    _collectionView  = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[FCXPictureBrowingCell class] forCellWithReuseIdentifier:FCXPictureBrowingCellReuseIdentifier];
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:_collectionView];
}

- (void)setupBottomView {
    _bottomLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 44, [UIScreen mainScreen].bounds.size.width, 44)];
    _bottomLabel.backgroundColor = [UIColor colorWithRed:((float)((0x25272a & 0xFF0000) >> 16))/255.0 green:((float)((0x25272a & 0xFF00) >> 8))/255.0 blue:((float)(0x25272a & 0xFF))/255.0 alpha:.3];
    _bottomLabel.textColor = [UIColor whiteColor];
    _bottomLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    _bottomLabel.userInteractionEnabled = YES;
    [self addSubview:_bottomLabel];
    
    UIButton *downLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downLoadBtn setImage:[UIImage imageNamed:@"icon_download"] forState:UIControlStateNormal];
    downLoadBtn.frame = CGRectMake(_bottomLabel.frame.size.width - 60, 0, 60, 40);
    [_bottomLabel addSubview:downLoadBtn];
    [downLoadBtn defaultControlEventsWithHandler:^(UIButton *button) {
        
        FCXPictureBrowingCell *cell = (FCXPictureBrowingCell *)[_collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        if (cell.image) {
            
            NSString *displayName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
            
            [[AlbumManager sharedAlbumManager] saveImageToAlbum:cell.image albumName:displayName withCompletionBlock:^(NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:[NSString stringWithFormat:@"您可以打开 设置 - 隐私 - 照片 找到%@，查看%@是否有访问相册的权限，如果没有，打开即可。", displayName, displayName] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
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
        
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FCXPictureBrowingCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FCXPictureBrowingCellReuseIdentifier forIndexPath:indexPath];
    cell.imageURL = self.dataArray[indexPath.row];
    cell.singleTapBlock = ^(){
        [self dismiss];
    };
    return cell;
}

- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    if (self.dataArray.count > 1) {
        _bottomLabel.text = [NSString stringWithFormat:@"   %ld/%ld", self.currentIndex + 1, self.dataArray.count];
    }else {
        _bottomLabel.text = nil;
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    _collectionView.contentOffset = CGPointMake( [UIScreen mainScreen].bounds.size.width * currentIndex, _collectionView.frame.size.height);
    if (self.dataArray.count > 1) {
        _bottomLabel.text = [NSString stringWithFormat:@"   %ld/%ld", self.currentIndex + 1, self.dataArray.count];
    }
}

- (void)show {
    [UIApplication sharedApplication].statusBarHidden = YES;
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    self.frame = [UIScreen mainScreen].bounds;
    [window addSubview:self];
}

- (void)dismiss {
    [UIApplication sharedApplication].statusBarHidden = NO;
    [self removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int i = (scrollView.contentOffset.x + [UIScreen mainScreen].bounds.size.width/2.0) /  [UIScreen mainScreen].bounds.size.width;
    if (i != _currentIndex) {
        _currentIndex = i;
        _bottomLabel.text = [NSString stringWithFormat:@"   %ld/%ld", _currentIndex + 1, self.dataArray.count];
    }
}

@end
