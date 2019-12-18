//
//  MBProgressHUD+KGTips.m
//    
//
//  Created by yaoyao on 2017/9/27.
//  Copyright © 2017年 yaoyao. All rights reserved.
//

#import "MBProgressHUD+KGTips.h"

@implementation MBProgressHUD (KGTips)
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
//    hud.label.numberOfLines = 0;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hide:YES afterDelay:1];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    
    return hud;
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message
{
    return [self showMessage:message toView:nil];
    
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view delay:(NSTimeInterval)time {
    
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.labelText = message;
    HUD.mode = MBProgressHUDModeCustomView;
    [HUD show:YES];
    [HUD hide:YES afterDelay:time];
    return HUD;
}

+ (MBProgressHUD *)showMessage:(NSString *)message  delay:(NSTimeInterval)time {
    
    return [self showMessage:message toView:nil delay:time];
}
@end
