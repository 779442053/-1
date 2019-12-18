//
//  AppDelegate+ZWAppDelegate.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/13.
//  Copyright © 2019 step. All rights reserved.
//

#import "AppDelegate.h"

#import "Reachability.h"
NS_ASSUME_NONNULL_BEGIN

@interface AppDelegate (ZWAppDelegate)
//初始化服务
-(void)initService;
//初始化 window
-(void)initWindow;
//初始化用户系统
-(void)initUserManager;
//键盘事件
- (void)zw_setKeyBord;
/**
 当前顶层控制器
 */
-(UIViewController*) getCurrentVC;

-(UIViewController*) getCurrentUIVC;
//监听网络状态
- (void)monitorNetworkStatus:(NetworkStatus )status;
@end

NS_ASSUME_NONNULL_END
