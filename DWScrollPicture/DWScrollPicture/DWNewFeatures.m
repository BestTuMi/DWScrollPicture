//
//  NewFeatures.m
//  DWScrollPicture
//
//  Created by cdk on 16/8/3.
//  Copyright © 2016年 dwang. All rights reserved.
//

#import "DWNewFeatures.h"
#import "DWScrollPicture.h"
#import "DWViewController.h"

@interface DWNewFeatures ()<DWScrollerPageCountDelegate>

@property (strong, nonatomic) DWScrollPicture *features;

@end

//获取屏幕 宽度、高度
#define DWScreen_Width [UIScreen mainScreen].bounds.size.width
#define DWScreen_Height [UIScreen mainScreen].bounds.size.height


@implementation DWNewFeatures

- (DWScrollPicture *)features {
    
    if (!_features) {
        
        _features = [[DWScrollPicture alloc] init];
    }
    return _features;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.features.delegate = self;
    
    //设置新特性图片
    [self.features dw_SetNewFeaturesView:self.view imageName:@[@"IMG_1.JPG",@"IMG_2.JPG",@"IMG_3.JPG",@"IMG_4.JPG"] currentPageIndicatorTintColor:[UIColor orangeColor] pageIndicatorTintColor:[UIColor grayColor] lastPageWithView:^(UIView *lastPageView) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(DWScreen_Width / 2 - 50, DWScreen_Height - 150, 100, 35)];
        
        [button setTitle:@"进入主页" forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        button.backgroundColor = [UIColor orangeColor];
        
        [button addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        
        [lastPageView addSubview:button];
        
    }];
    
}


- (void)dw_ScrollerPageCount:(double)pageCount imageCount:(NSInteger)imageCount{
    
    //最后一张新特性图片
    if (pageCount > imageCount) {
        
        //跳转到首页控制器
        [self presentViewController:[DWViewController new] animated:YES completion:nil];
        
        //删除当前控制器
        [self removeFromParentViewController];
        
    }
    
}

- (void)click {
    
    //跳转到首页控制器
    [self presentViewController:[DWViewController new] animated:YES completion:nil];
    
}
@end
