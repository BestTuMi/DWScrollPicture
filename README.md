# DWScrollPictures
---
#轻松实现新特性控制器与轮播图
#如果感觉不错，请Star我
---
#CocoaPods
	platform :ios, '8.0'
	pod 'DWScrollPictures'
#Clone
###git clone https://github.com/dwanghello/DWScrollPicture.git
###将DWScrollPictures文件夹导入到项目中
---
#第一步-新特性
####引入头文件
    在AppDelegate.m中引入头文件
    #import "DWScrollPictures.h"
	#import "新特性控制器.h"
	#import "首页控制器.h"
---
#第二步-新特性
####在- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{}方法中写入以下代码
	 self.window =[[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [DWScrollPictures dw_AppdelegateNewFeaturesWindow:self.window newFeaturesVC:[[新特性控制器 alloc] init] mainVC:[[首页控制器 alloc] init]];
	
	return YES;
---
#第三步-新特性
####新特性控制器中的实现
#####引入头文件，声明代理方法
	#import "DWScrollPictures.h"
	<DWScrollerPageCountDelegate>
---
####在@interface中添加以下代码
	@property (strong, nonatomic) DWScrollPictures *features;
---
####懒加载
	- (DWScrollPictures *)features {
    
   			 if (!_features) {
        
     	   _features = [[DWScrollPictures alloc] init];
     	   
   		 }	
   		 
    	return _features;
    
	}
---
####在viewDidLoad中实现以下方法
	//设置新特性图片
    [self.features dw_SetNewFeaturesView:self.view 	delegate:self	imageName:@[@"图片名称.JPG"] currentPageIndicatorTintColor:[pageController选中时的颜色] pageIndicatorTintColor:[pageController默认颜色] lastPageWithView:^(UIView *lastPageView) {
        
            //最后一个视图
            
    }];
---
####实现代理方法
	- (void)dw_NewFeaturesPageCount:(double)pageCount imageCount:(NSInteger)imageCount{
	/**
 	 *  @param pageCount  当前所在界面索引
 	 *  @param imageCount 新特性图片总数
 	 */
	}
---
---
#自动轮播图
##第一步
#####在需要使用轮播图的地方引入头文件
	#import "DWScrollPictures.h"
---
##第二步
#####声明对象
	@property (strong, nonatomic) DWScrollPictures *rebirth;
---
#第三步
#####开始设置轮播图片
	
	//设置pageController选中时的颜色
	[self.rebirth setPageSelctColor:[pageController选中时的颜色]];
	
	//设置pageController未选中时的颜色
	[self.rebirth setPageNormalColor:[pageController未选中时的颜色]];
	
	[self.rebirth dw_SetShufflingFigureView:self.view sizeY:0 height:self.view.frame.size.height/2 pageY:50 imageArray:@[@"图片名称数组,暂时只能为本地图片"] timeInterval:轮播时间 animateTimer:完成每次的轮播的时间];
	
	//开始进行轮播
	self.rebirth dw_startShuffling];
	
	//停止自动轮播
	[self.rebirth dw_stopShuffling];
	
	//删除pageController
	[self.rebirth dw_removePageControl];
