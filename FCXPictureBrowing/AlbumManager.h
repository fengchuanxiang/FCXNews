//
//  AlbumManager.h
//  Camera
//
//  Created by 冯 传祥 on 15/2/17.
//  Copyright (c) 2015年 冯 传祥. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>


typedef void(^SaveImageCompletion)(NSError* error);
typedef void(^AlbumBlock)(NSError *error);

@interface AlbumManager : ALAssetsLibrary

+ (AlbumManager *)sharedAlbumManager;


//  保存照片到相册
- (void)saveImageToAlbum:(UIImage *)image albumName:(NSString *)albumName withCompletionBlock:(AlbumBlock)completionBlock;


@end
