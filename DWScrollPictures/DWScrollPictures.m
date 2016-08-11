//
//  DWNewFeatures.m
//  DWNewFeatures
//
//  Created by cdk on 16/8/2.
//  Copyright © 2016年 dwang_sui. All rights reserved.
//----------------------------QQ:739814184-----------------------
//----------------------------e-mail:dwang.hello@outlook.com-------------------

#import "DWScrollPictures.h"
#import "UIView+Extension.h"

@interface DWScrollPictures ()<UIScrollViewDelegate>

//获取屏幕 宽度、高度
#define DWScreen_Frame [UIScreen mainScreen].bounds
#define DWScreen_Width [UIScreen mainScreen].bounds.size.width
#define DWScreen_Height [UIScreen mainScreen].bounds.size.height

//偏好设置
#define DWUser_Defaults [NSUserDefaults standardUserDefaults]

/** pageController */
@property (weak, nonatomic) UIPageControl       *pageControl;

/** 新特性本地图片数组 */
@property (strong, nonatomic) NSArray           *NewFeaturesImageNameArray;

/** 新特性网络图片数组 */
@property (strong, nonatomic) NSArray           *NewFeaturesImageLinkArray;

/** 轮播图本地图片数组 */
@property (strong, nonatomic) NSArray           *shufflingFigureImageNameArray;

/** 轮播图网络图片数组 */
@property (strong, nonatomic) NSArray           *imageLinkArray;

/** 轮播图完成一次轮播的时间 */
@property (assign, nonatomic) NSTimeInterval    animateTimer;

/** 轮播方式 */
@property (assign, nonatomic) BOOL              isbool;

/** 轮播图计时器 */
@property (weak, nonatomic) NSTimer             *shufflingTimer;

@property (weak, nonatomic) UIScrollView        *scrollView;

@end

#define key_ShortVersion @"key_ShortVersion"
@implementation DWScrollPictures

#pragma mark ---Appdelegate设置引导页控制器
+ (void)dw_AppdelegateNewFeaturesWindow:(UIWindow *)window newFeaturesVC:(id)newFeaturesVC mainVC:(id)mainVC {
    
    //本地保存的版本号
    NSString *localShortVersionStr = [[NSUserDefaults standardUserDefaults] objectForKey:key_ShortVersion];
    
    //取出当前app的版本号
    NSString *currentShortVersionStr = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    //判断当前本地保存的版本号为空,或者本地保存的版本号小于当前app的版本号,就直接进入到新特性页面
    if (!localShortVersionStr || [localShortVersionStr compare:currentShortVersionStr] == NSOrderedAscending || ![DWUser_Defaults boolForKey:@"lastPage"]) {
        
        //进入新特性控制器之前,保存一下当前app的版本号,以便下次进入的时候判断
        [[NSUserDefaults standardUserDefaults] setObject:currentShortVersionStr forKey:key_ShortVersion];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //加载新特性页面
        window.rootViewController = newFeaturesVC;
        
    }else{
        
        //加载首页控制器
        window.rootViewController = mainVC;
        
    }
    
    [window makeKeyAndVisible];
}

#pragma mark ---设置新特性页面/本地图片
- (void)dw_SetNewFeaturesView:(UIView *)view delegate:(id)delegate imageName:(NSArray *)imageNameArray pageImageView:(void (^)(UIView *PageImageView, int imageCount, int imageAllCount))pageImageView {
    
    self.NewFeaturesImageNameArray = imageNameArray;
    
    self.delegate = delegate;
    
    //初始化一个ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:DWScreen_Frame];
    
    self.scrollView = scrollView;
    
    //隐藏水平方向的滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    
    //开启分页
    scrollView.pagingEnabled = YES;
    
    //监听滑动-->成为代理
    scrollView.delegate = self;
    
    for (int i = 0; i < [imageNameArray count]; i ++) {
        
        //循环添加imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:imageNameArray[i]];
        
        //设置大小与位置
        imageView.size = scrollView.size;
        
        imageView.x = i * scrollView.width;
        
        [scrollView addSubview:imageView];
        
        
        if (pageImageView) {
            
            imageView.userInteractionEnabled = true;
            
            pageImageView(imageView,i, (int)[imageNameArray count] - 1);
            
        }
    }
    
    //设置scrollView的内容大小
    [scrollView setContentSize:CGSizeMake([imageNameArray count] * scrollView.width, 0)];
    
    [view addSubview:scrollView];
    
    
    //添加pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    //设置显示几页
    pageControl.numberOfPages = [imageNameArray count];
    
    //选中的颜色
    if (self.pageSelctColor) {
        
        pageControl.currentPageIndicatorTintColor = self.pageSelctColor;
        
    }else {
        
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        
    }
    
    //未选中的颜色
    if (self.pageNormalColor) {
        
        pageControl.pageIndicatorTintColor = self.pageNormalColor;
        
    }else {
        
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
    }
    
    [view addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    //设置位置
    pageControl.centerX = view.centerX;
    pageControl.y = view.height - 100;
    
    
}

#pragma mark ---设置新特性页面/网络图片
- (void)dw_SetNetworkingNewFeaturesView:(UIView *)view delegate:(id)delegate imageLinkArray:(NSArray *)imageLinkArray pageImageView:(void (^)(UIView *PageImageView, int imageCount, int imageAllCount))pageImageView {
    
    self.NewFeaturesImageLinkArray = imageLinkArray;
    
    self.delegate = delegate;
    
    //初始化一个ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:DWScreen_Frame];
    
    self.scrollView = scrollView;
    
    //隐藏水平方向的滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    
    //开启分页
    scrollView.pagingEnabled = YES;
    
    //监听滑动-->成为代理
    scrollView.delegate = self;
    
    for (int i = 0; i < [imageLinkArray count]; i ++) {
        
        //循环添加imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        
        NSURL *url = [NSURL URLWithString:imageLinkArray[i]];
        
        dispatch_queue_t queue =dispatch_queue_create("loadImage",NULL);
        
        dispatch_async(queue, ^{
            
            NSData *resultData = [NSData dataWithContentsOfURL:url];
            
            UIImage *img = [UIImage imageWithData:resultData];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                imageView.image = img;
                
            });
            
        });

        //设置大小与位置
        imageView.size = scrollView.size;
        
        imageView.x = i * scrollView.width;
        
        [scrollView addSubview:imageView];
        
        
        if (pageImageView) {
            
            imageView.userInteractionEnabled = true;
            
            pageImageView(imageView,i, (int)[imageLinkArray count] - 1);
            
        }
    }
    
    //设置scrollView的内容大小
    [scrollView setContentSize:CGSizeMake([imageLinkArray count] * scrollView.width, 0)];
    
    [view addSubview:scrollView];
    
    
    //添加pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    //设置显示几页
    pageControl.numberOfPages = [imageLinkArray count];
    
    //选中的颜色
    if (self.pageSelctColor) {
        
        pageControl.currentPageIndicatorTintColor = self.pageSelctColor;
        
    }else {
        
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        
    }
    
    //未选中的颜色
    if (self.pageNormalColor) {
        
        pageControl.pageIndicatorTintColor = self.pageNormalColor;
        
    }else {
        
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
    }
    
    [view addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    //设置位置
    pageControl.centerX = view.centerX;
    pageControl.y = view.height - 100;

    
}

#pragma mark ---设置轮播图／本地图片
- (void)dw_SetShufflingFigureView:(UIView *)view sizeY:(CGFloat)sizeY  height:(CGFloat)height pageY:(CGFloat)pageY imageNameArray:(NSArray *)imageNameArray timeInterval:(NSTimeInterval)timeInterval animateTimer:(NSTimeInterval)animateTimer {
    
    self.shufflingFigureImageNameArray = imageNameArray;
    
    self.animateTimer = animateTimer;
    
    //初始化一个ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, sizeY, DWScreen_Width, height)];
    
    self.scrollView = scrollView;
    
    //隐藏水平方向的滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    
    //开启分页
    scrollView.pagingEnabled = YES;
    
    //监听滑动-->成为代理
    scrollView.delegate = self;
    
    for (int i = 0; i < [imageNameArray count]; i ++) {
        
        //循环添加imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        
        imageView.image = [UIImage imageNamed:imageNameArray[i]];
        
        //设置大小与位置
        imageView.size = scrollView.size;
        
        imageView.x = i * scrollView.width;
        
        [scrollView addSubview:imageView];
        
    }
    
    //设置scrollView的内容大小
    [scrollView setContentSize:CGSizeMake([imageNameArray count] * scrollView.width, 0)];
    
    [view addSubview:scrollView];
    
    
    //添加pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    //设置显示几页
    pageControl.numberOfPages = [imageNameArray count];
    
    //选中的颜色
    if (self.pageSelctColor) {
        
        pageControl.currentPageIndicatorTintColor = self.pageSelctColor;
        
    }else {
        
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        
    }
    
    //未选中的颜色
    if (self.pageNormalColor) {
        
        pageControl.pageIndicatorTintColor = self.pageNormalColor;
        
    }else {
        
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
    }
    
    [view addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    //设置位置
    pageControl.centerX = view.centerX;
    pageControl.y = view.height - pageY;
    
    
    self.shufflingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(startShuffling) userInfo:nil repeats:YES];
    
    [self dw_stopShuffling];
    
}

#pragma mark ---设置轮播图／网络图片
- (void)dw_SetNetworkingShufflingFigureView:(UIView *)view sizeY:(CGFloat)sizeY  height:(CGFloat)height pageY:(CGFloat)pageY imageLinkArray:(NSArray *)imageLinkArray timeInterval:(NSTimeInterval)timeInterval animateTimer:(NSTimeInterval)animateTimer {
    
    self.imageLinkArray = imageLinkArray;
    
    self.animateTimer = animateTimer;
    
    //初始化一个ScrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, sizeY, DWScreen_Width, height)];
    
    self.scrollView = scrollView;
    
    //隐藏水平方向的滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    
    //开启分页
    scrollView.pagingEnabled = YES;
    
    //监听滑动-->成为代理
    scrollView.delegate = self;

    for (int i = 0; i < [imageLinkArray count]; i ++) {
        
        //循环添加imageView
        UIImageView *imageView = [[UIImageView alloc] init];
        
        NSURL *url = [NSURL URLWithString:imageLinkArray[i]];
        
        dispatch_queue_t queue =dispatch_queue_create("loadImage",NULL);
        
        dispatch_async(queue, ^{
            
            NSData *resultData = [NSData dataWithContentsOfURL:url];
            
            UIImage *img = [UIImage imageWithData:resultData];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
                imageView.image = img;
                
            });
            
        });

        
        //设置大小与位置
        imageView.size = scrollView.size;
        
        imageView.x = i * scrollView.width;
        
        [scrollView addSubview:imageView];
        
    }
    
    //设置scrollView的内容大小
    [scrollView setContentSize:CGSizeMake([imageLinkArray count] * scrollView.width, 0)];
    
    [view addSubview:scrollView];
    
    
    //添加pageControl
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    //设置显示几页
    pageControl.numberOfPages = [imageLinkArray count];
    
    //选中的颜色
    if (self.pageSelctColor) {
        
        pageControl.currentPageIndicatorTintColor = self.pageSelctColor;
        
    }else {
        
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        
    }
    
    //未选中的颜色
    if (self.pageNormalColor) {
        
        pageControl.pageIndicatorTintColor = self.pageNormalColor;
        
    }else {
        
        pageControl.pageIndicatorTintColor = [UIColor grayColor];
        
    }
    
    [view addSubview:pageControl];
    
    self.pageControl = pageControl;
    
    //设置位置
    pageControl.centerX = view.centerX;
    pageControl.y = view.height - pageY;
    
    
    self.shufflingTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(startShuffling) userInfo:nil repeats:YES];
    
    [self dw_stopShuffling];

}

#pragma mark ---开始进行轮播
- (void)startShuffling {
    
    CGPoint point;
    
    if (self.scrollView.contentOffset.x == DWScreen_Width * ([self.shufflingFigureImageNameArray count] - 1) || self.scrollView.contentOffset.x == DWScreen_Width * ([self.imageLinkArray count] - 1)) {
        
        self.isbool = YES;
        
        
    }else if (self.scrollView.contentOffset.x == 0) {
        
        self.isbool = NO;
        
    }
    
    if (self.isbool) {
        
        point = CGPointMake(self.scrollView.contentOffset.x - DWScreen_Width, 0);
        
    }else if (!self.isbool){
        
        point = CGPointMake(self.scrollView.contentOffset.x + DWScreen_Width, 0);
        
    }
    
    [UIView animateWithDuration:self.animateTimer animations:^{
        
        
        self.scrollView.contentOffset = point;
        
        
    }];
    
}


#pragma mark ---scrollerViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //计算滑动到第几页
    double page = scrollView.contentOffset.x / scrollView.width;
    
    self.pageControl.currentPage = (int)(page + 0.5);
    
    if (page >= self.NewFeaturesImageNameArray.count - 1 || page >= self.NewFeaturesImageLinkArray.count - 1) {
        
        [DWUser_Defaults setBool:YES forKey:@"lastPage"];
        
    }
    
    if (self.NewFeaturesImageNameArray) {
        
        //代理方法
        if ([self.delegate respondsToSelector:@selector(dw_nowPageCount:imageAllCount:)]) {
            
            [self.delegate dw_nowPageCount:page imageAllCount:self.NewFeaturesImageNameArray.count - 1];
            
        }

    }else if (self.NewFeaturesImageLinkArray) {
        
        //代理方法
        if ([self.delegate respondsToSelector:@selector(dw_nowPageCount:imageAllCount:)]) {
            
            [self.delegate dw_nowPageCount:page imageAllCount:self.NewFeaturesImageLinkArray.count - 1];
            
        }

        
    }
    
    
}

#pragma mark ---关闭定时器
- (void)dw_stopShuffling {
    
    [self.shufflingTimer setFireDate:[NSDate distantFuture]];
}

#pragma mark ---开启定时器
- (void)dw_startShuffling {
    
    [self.shufflingTimer setFireDate:[NSDate distantPast]];
    
}

#pragma mark ---取消定时器
- (void)dw_dismissShuffling {
    
    [self.shufflingTimer invalidate];
    
    self.shufflingTimer = nil;
    
}

#pragma mark ---删除pageController
- (void)dw_removePageControl {
    
    [self.pageControl removeFromSuperview];
    
}


@end
