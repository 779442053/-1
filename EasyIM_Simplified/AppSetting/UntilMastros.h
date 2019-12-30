//
//  UntilMastros.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/13.
//  Copyright © 2019 step. All rights reserved.
//
/////  ==  这里,是我自己定义的第三方 头文件管理工具

#ifndef UntilMastros_h
#define UntilMastros_h

//获取系统对象
#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController

//获取屏幕宽高
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreen_Bounds [UIScreen mainScreen].bounds]

//屏幕适配==6s 做的适配
#define kRealValueWidth(with) (with)*KScreenWidth/375.0
#define kRealValueHeight(height) (height)*KScreenHeight/667.0
////根据ip6的屏幕来拉伸===
#define kRealValue(with) ((with)*(KScreenWidth/375.0f))
//字体的适配使用runtime交换方法.将系统的字体设置方法换掉

/// iPhone X
#define K_APP_ISIOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define K_APP_ISIPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ZWiPhoneX (K_APP_ISIOS11 && K_APP_ISIPHONE && (MIN(KScreenWidth,KScreenHeight) >= 375 && MAX(KScreenWidth,KScreenHeight) >= 812))/** 判断设备类型是否iPhoneX*/

#define ZWStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
/// navigation bar
#define ZWNavBarHeight self.navigationController.navigationBar.frame.size.height
///  Status bar & navigation bar height
#define ZWStatusAndNavHeight (ZWStatusBarHeight + ZWNavBarHeight)

/// Tabbar height.
#define  ZWTabbarHeight (ZWiPhoneX ? (49.f+34.f) : 49.f)
/// Tabbar safe bottom margin.
#define  ZWTabbarSafeBottomMargin (ZWiPhoneX ? 34.f : 0.f)
//强弱引用
#define ZWWWeakSelf(type)  __weak typeof(type) weak##type = type;
#define ZWWStrongSelf(type) __strong typeof(type) type = weak##type;

#define ZW(weakSelf)  __weak __typeof(&*self)weakSelf = self;

///IOS 版本判断
#define IOSAVAILABLEVERSION(version) ([[UIDevice currentDevice] availableVersion:version] < 0)
// 当前系统版本
#define CurrentSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]
//当前语言K
#define KCurrentLanguage ([NSLocale preferredLanguages] objectAtIndex:0])
//APP版本号
#define KAPP_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

//是否是空对象
#define ZWWOBJECT_IS_EMPYT(object) \
({ \
BOOL flag = NO; \
if ([object isKindOfClass:[NSNull class]] || object == nil || object == Nil || object == NULL) \
flag = YES; \
if ([object isKindOfClass:[NSString class]]) \
if ([(NSString *)object length] < 1) \
flag = YES; \
if ([object isKindOfClass:[NSArray class]]) \
if ([(NSArray *)object count] < 1) \
flag = YES; \
if ([object isKindOfClass:[NSDictionary class]]) \
if ([(NSDictionary *)object allKeys].count < 1) \
flag = YES; \
(flag); \
})

//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#define ZWWLog(fmt, ...) NSLog((@"\n[文件名:%s]\n""[函数名:%s]""[行号:%d] \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define ZWWLog(...)
#endif
#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#endif /* UntilMastros_h */
