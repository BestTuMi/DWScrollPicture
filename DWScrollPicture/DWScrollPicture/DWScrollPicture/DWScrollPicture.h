//
//  DWNewFeatures.h
//  DWNewFeatures
//
//  Created by cdk on 16/8/2.
//  Copyright © 2016年 dwang_sui. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol DWScrollerPageCountDelegate <NSObject>

@optional
/**
 *  新特性视图代理方法
 *
 *  @param pageCount  当前所在界面索引
 *  @param imageCount 新特性图片总数
 */
- (void)dw_NewFeaturesPageCount:(double)pageCount imageAllCount:(NSInteger)imageAllCount;

@end

@interface DWScrollPicture : NSObject

/**
 *  pageController选中时的颜色
 */
@property (weak, nonatomic) UIColor *pageSelctColor;

/**
 *  pageController未选中的颜色
 */
@property (weak, nonatomic) UIColor *pageNormalColor;


/** 代理 */
@property (assign, nonatomic) id <DWScrollerPageCountDelegate>delegate;


/**
 *  设置引导页控制器与主页面控制器
 *
 *  @param window        主window
 *  @param newFeaturesVC 新特性控制器
 *  @param mainVC        主页控制器
 */
+ (void)dw_AppdelegateNewFeaturesWindow:(UIWindow *)window newFeaturesVC:(id)newFeaturesVC mainVC:(id)mainVC;

/**
 *  设置引导图
 *
 *  @param view                          当前控制器View
 *  @param delegate                      代理遵守者
 *  @param imageNameArray                引导图数组
 *  @param pageImageView                 imageView/某个imageView/imageView总量
 */
- (void)dw_SetNewFeaturesView:(UIView *)view delegate:(id)delegate imageName:(NSArray *)imageNameArray pageImageView:(void(^) (UIView *pageImageView ,int imageCount, int imageAllCount))pageImageView;


/**
 *  设置轮播图
 *
 *  @param view         当前控制器View
 *  @param sizeY        轮播视图Y值
 *  @param height       轮播图高度
 *  @param pageY        pageController高度
 *  @param imageArray   轮播图数组
 *  @param timeInterval 轮播图轮播时间
 *  @param animateTimer 轮播图完成一次轮播的时间
 */
- (void)dw_SetShufflingFigureView:(UIView *)view sizeY:(CGFloat)sizeY  height:(CGFloat)height pageY:(CGFloat)pageY imageArray:(NSArray *)imageArray timeInterval:(NSTimeInterval)timeInterval animateTimer:(NSTimeInterval)animateTimer;

/**
 *  删除PageController
 */
- (void)dw_removePageControl;

/**
 *  暂时停止自动轮播
 */
- (void)dw_stopShufflingTimer;

/**
 *  开启自动轮播
 */
- (void)dw_startShufflingTimer;

/**
 *  关闭自动轮播
 */
- (void)dw_dismissShufflingTimer;

@end
