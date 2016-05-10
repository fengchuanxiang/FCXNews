//
//  FCXPictureBrowingCell.h
//  FCXPictureBrowsing
//
//  Created by 冯 传祥 on 16/5/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FCXPictureBrowingModel;

static NSString *const FCXPictureBrowingCellReuseIdentifier = @"FCXPictureBrowingCellReuseIdentifier";

@interface FCXPictureBrowingCell : UICollectionViewCell

@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, copy) dispatch_block_t singleTapBlock;
@property (nonatomic, strong, readonly) UIImage *image;


@end
