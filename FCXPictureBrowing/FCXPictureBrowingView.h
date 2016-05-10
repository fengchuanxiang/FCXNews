//
//  FCXPictureBrowingView.h
//  FCXPictureBrowsing
//
//  Created by 冯 传祥 on 16/5/9.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FCXPictureBrowingView : UIView

@property (nonatomic, strong) NSArray *dataArray;
/**
 *  接收当前图片的序号,默认的是0
 */
@property(nonatomic, assign) NSInteger currentIndex;

- (void)show;
- (void)dismiss;

@end
