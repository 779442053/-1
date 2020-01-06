//
//  AppDelegate.m
//  EasyIM
//
//  Created by momo on 2019/1/3.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "AppDelegate.h"
#import "AppDelegate+ZWAppDelegate.h"
#import<CoreTelephony/CTCellularData.h>
#import "ZWDataManager.h"

#import <AFNetworking/AFNetworking.h>

//Bugly Bug鐩戞帶
#import "Bugly/Bugly.h"

@interface AppDelegate ()<BuglyDelegate>
@property (strong,nonatomic) Reachability* reachablity;
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initUserManager];
    [self initWindow];

    //1.获取网络权限 根绝权限进行人机交互
    if (__IPHONE_10_0) {
        self.reachablity = [Reachability reachabilityWithHostName:@"www.taobao.com"];
        [self.reachablity startNotifier];
        NetworkStatus status = [self.reachablity currentReachabilityStatus];
        [self monitorNetworkStatus:status];
        [self networkStatus:application didFinishLaunchingWithOptions:launchOptions];
    }else {
        //2.2已经开启网络权限 监听网络状态
        [self addReachabilityManager:application didFinishLaunchingWithOptions:launchOptions];
    }
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
     ZWWLog(@"当程序进入后台的时候调用")
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
    [ZWDataManager saveUserData];
    //    清除角标
    [[UIApplication alloc] setApplicationIconBadgeNumber:0];
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication alloc] setApplicationIconBadgeNumber:0];
}
- (void)applicationWillTerminate:(UIApplication *)application {
    [ZWDataManager saveUserData];
    [[UIApplication alloc] setApplicationIconBadgeNumber:0];
}
+(UIViewController *)appRootViewController {
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (appRootVC.presentedViewController) {
        appRootVC = appRootVC.presentedViewController;
    }
    return appRootVC;
}
/*
 CTCellularData在iOS9之前是私有类，权限设置是iOS10开始的，所以App Store审核没有问题
 获取网络权限状态
 */
- (void)networkStatus:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    //2.根据权限执行相应的交互
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    /*
     此函数会在网络权限改变时再次调用
     */
    cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state) {
        switch (state) {
            case kCTCellularDataRestricted:
                NSLog(@"Restricted");
                //2.1权限关闭的情况下 再次请求网络数据会弹出设置网络提示
                [self getAppInfo];
                break;
            case kCTCellularDataNotRestricted:
                NSLog(@"NotRestricted");
                //2.2已经开启网络权限 监听网络状态
                [self addReachabilityManager:application didFinishLaunchingWithOptions:launchOptions];
                [self getInfo_application:application didFinishLaunchingWithOptions:launchOptions];
                break;
            case kCTCellularDataRestrictedStateUnknown:
                NSLog(@"Unknown");
                //2.3未知情况 （还没有遇到推测是有网络但是连接不正常的情况下）
                [self getAppInfo];
                break;

            default:
                break;
        }
    };
}
/**
 实时检查当前网络状态
 */
- (void)addReachabilityManager:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    AFNetworkReachabilityManager *afNetworkReachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [afNetworkReachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:{
                NSLog(@"网络不通：%@",@(status) );
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi:{
                NSLog(@"网络通过WIFI连接：%@",@(status));
                [self getInfo_application:application didFinishLaunchingWithOptions:launchOptions];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN:{
                NSLog(@"网络通过无线连接：%@",@(status) );
                [self getInfo_application:application didFinishLaunchingWithOptions:launchOptions];
                break;
            }
            default:
                break;
        }
    }];
    [afNetworkReachabilityManager startMonitoring];  //开启网络监视器；
}
///网络权限.修改
- (void)getInfo_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    ///此时,手机已经获取到了网络..开始配置第三方服务
    [self initBugly];
    //有网,添加自己的网络监测工具类
    NetworkStatus status = [self.reachablity currentReachabilityStatus];
    [self monitorNetworkStatus:status];
}
-(void)getAppInfo{
    ZWWLog(@"有网络,可以配置第三方")
    self.reachablity = [Reachability reachabilityWithHostName:@"https://www.baidu.com"];
    [self.reachablity startNotifier];
    NetworkStatus status = [self.reachablity currentReachabilityStatus];
    //网络监听
    [self monitorNetworkStatus:status];
}
//当收到Received memory warning.会调用次方法
-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    SDWebImageManager *mgr = [SDWebImageManager sharedManager];
    //取消下载
    [mgr cancelAll];
    //清空缓存
    [mgr.imageCache clearMemory];
}
/** Bugly */
-(void)initBugly{
    @autoreleasepool {
        //开启Bugly配置
        BuglyConfig *config = [[BuglyConfig alloc] init];
        config.delegate = (id<BuglyDelegate>)self;
        //SDK Debug信息
#if DEBUG
        config.debugMode = YES;
        config.consolelogEnable = YES;
#else
        config.debugMode = NO;
        config.consolelogEnable = NO;
#endif
        //卡顿监控开关，默认关闭
        config.blockMonitorEnable = YES;
        //卡顿监控判断间隔，单位为秒
        config.blockMonitorTimeout = 1.0;
        //非正常退出事件记录开关，默认关闭
        config.unexpectedTerminatingDetectionEnable = YES;
        //设置自定义日志上报的级别，默认不上报自定义日志
        config.reportLogLevel = BuglyLogLevelDebug;
        [Bugly startWithAppId:K_APP_BUGLY_APP_ID config:config];
    }
}
////////////////////////////////////////////////////////////////////////////////
//MARK: - BuglyDelegate
////////////////////////////////////////////////////////////////////////////////
- (NSString * BLY_NULLABLE)attachmentForException:(NSException * BLY_NULLABLE)exception{
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    NSLog(@"++++++ callStackSymbols ++++++\n%@\n++++++ reason ++++++\n%@\n++++++ name ++++++\n%@",arr, reason, name);
    NSString *strLog = [NSString stringWithFormat:@"callStackSymbols：%@\n reason：%@\n name：%@",exception.callStackSymbols,exception.reason,exception.name];
    return strLog;
}
+ (AppDelegate *)shareAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}
@end
