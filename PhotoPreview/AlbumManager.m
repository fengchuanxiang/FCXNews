//
//  AlbumManager.m
//  Camera
//
//  Created by 冯 传祥 on 15/2/17.
//  Copyright (c) 2015年 冯 传祥. All rights reserved.
//

#import "AlbumManager.h"


@implementation AlbumManager


+(AlbumManager *)sharedAlbumManager
{
    static AlbumManager *albumManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        albumManager = [[AlbumManager alloc] init];
    });
    
    return albumManager;
}

//  保存照片到相册
-(void)saveImageToAlbum:(UIImage *)image albumName:(NSString *)albumName withCompletionBlock:(AlbumBlock)completionBlock {
    
    [self writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if (error != nil) {
            completionBlock(error);
            return;
        }
        
        [self addAssetURL: assetURL toAlbum:albumName withCompletionBlock:completionBlock];
        
    }];
}

-(void)addAssetURL:(NSURL*)assetURL toAlbum:(NSString*)albumName withCompletionBlock:(SaveImageCompletion)completionBlock {
    __block BOOL albumWasFound = NO;
    
    [self enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // 对比相册名
        if ([albumName compare:[group valueForProperty:ALAssetsGroupPropertyName]] == NSOrderedSame) {
            albumWasFound = YES;
            
            [self assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                [group addAsset:asset];
                
                completionBlock(nil);
            } failureBlock:completionBlock];
        }
        
        // 没有找到相册、创建之
        if (group == nil && albumWasFound == NO) {
            __weak ALAssetsLibrary *weakSelf = self;
            
            // 创建相册
            [self addAssetsGroupAlbumWithName:albumName resultBlock:^(ALAssetsGroup *group) {
                [weakSelf assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                    
                    [group addAsset:asset];
                    
                    completionBlock(nil);
                    
                } failureBlock:completionBlock];
                
            } failureBlock:completionBlock];
            
            return;
        }
        
    } failureBlock:completionBlock];
}


-(void)saveAction
{
    UIImage *image;
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

// 指定回调方法
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != nil){
        msg = @"保存图片失败" ;
    }else{//保存图片成功

    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
