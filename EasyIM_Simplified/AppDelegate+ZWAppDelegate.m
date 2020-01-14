//
//  AppDelegate+ZWAppDelegate.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/13.
//  Copyright © 2019 step. All rights reserved.
//

#import "AppDelegate+ZWAppDelegate.h"
#import <IQKeyboardManager.h>
#import "MMEasyIMHelper.h"
#import "KinTabBarController.h"
#import "LoginVC.h"
#import "ZWDataManager.h"

#import "Bugly/Bugly.h"
#import "MMCustomFormatter.h"
#import "ZWSaveTool.h"
@implementation AppDelegate (ZWAppDelegate)
-(void)initService{
   //初始化本地数据库表格==创建本地数据库,用来保存聊天记录.此时,和网络没有关系.所以,可以写在 判断网络之外

}
#pragma mark ————— 网络状态监听 —————
- (void)monitorNetworkStatus:(NetworkStatus )status{
    //1. 增加网络监听
    [[MMManagerGlobeUntil sharedManager] managerReachability];
    [MMEasyIMHelper shareHelper];
}
#pragma mark ————— 初始化window —————
-(void)initWindow{
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //3.首先进入启动界面,之后判断该用户是否进行啦登录,没有登录,进到登录界面(成功,刷新首页UI) 登录,进到首页
    BOOL islogin = [ZWSaveTool BoolForKey:@"IMislogin"];
    if (islogin) {
        [self enterMainUI];
    }else{
        LoginVC *login = [LoginVC new];
        BaseNavgationController *vc = [[BaseNavgationController alloc] initWithRootViewController:login];
        self.window.rootViewController = vc;
    }
   
    [[UIButton appearance] setExclusiveTouch:YES];
    //解决网页有黑边
    if(@available(iOS 11.0, *)){
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        UITableView.appearance.estimatedRowHeight = 0;
        UITableView.appearance.estimatedSectionHeaderHeight = 0;
        UITableView.appearance.estimatedSectionFooterHeight = 0;
    }else{

    }
    
    [self.window makeKeyAndVisible];
}
////////  无用的代码   ==采用自定义nav 的方式
- (void)enterMainUI {
    self.tabBarController = [[KinTabBarController alloc]initWithSelectVCIndex:0];
    BaseNavgationController *nav = [[BaseNavgationController alloc]initWithRootViewController:self.tabBarController];
    self.window.rootViewController = nav;
}

#pragma mark ————— 初始化用户系统 —————
-(void)initUserManager{
    //ZWWLog(@"设备IMEI ：%@",[OpenUDID value]);//移动设备国际识别码，又称为国际移动设备标识）是手机的唯一识别号码。
    //c14c1040f1e69c04e40a656637c3acd377cca4c4
    [ZWDataManager readUserData];
}
#pragma ===========键盘的回收事件 =============
-(void)zw_setKeyBord{
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;//点击背景,收起键盘
    manager.shouldToolbarUsesTextFieldTintColor = YES;//控制键盘上的工具条文字颜色是否用户自定义
    manager.toolbarDoneBarButtonItemText =@"完成";//将右边Done改成完成
    manager.enableAutoToolbar = YES;//显示输入框提示栏
    manager.toolbarManageBehaviour =IQAutoToolbarByTag;
}
-(UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;

    return result;
}
-(UIViewController *)getCurrentUIVC
{
    UIViewController  *superVC = [self getCurrentVC];
    if ([superVC isKindOfClass:[UITabBarController class]]) {
        UIViewController  *tabSelectVC = ((UITabBarController*)superVC).selectedViewController;
        if ([tabSelectVC isKindOfClass:[BaseNavgationController class]]) {
            return ((BaseNavgationController*)tabSelectVC).viewControllers.lastObject;
        }
        return tabSelectVC;
    }else
        if ([superVC isKindOfClass:[BaseNavgationController class]]) {
            return ((BaseNavgationController*)superVC).viewControllers.lastObject;
        }
    return superVC;
}
@end
