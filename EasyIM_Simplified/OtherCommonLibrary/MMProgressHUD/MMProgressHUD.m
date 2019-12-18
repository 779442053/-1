//
//  MBProgressHUDPrompt.m
//  speedauction
//
//  Created by apple on 16/12/9.
//  Copyright © 2016年 enjoyor. All rights reserved.
//

#import "MMProgressHUD.h"
//#import "GlobalVariable.h"

@implementation MMProgressHUD

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated {
    MMProgressHUD *hud = [[self alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    [view addSubview:hud];
    [hud show:animated];
    return hud;
}

+ (MMProgressHUD *) showHUDWithProgress:(NSString *)message {
    MMProgressHUD *hud = [MMProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    
    // Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    hud.labelText = message;
    return hud;
//    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
//        // Do something useful in the background and update the HUD periodically.
//        [self doSomeWorkWithProgress];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [hud hideAnimated:YES];
//        });
//    });
}

/**
 等待提示框
 
 */
+ (MMProgressHUD *)showHUD {
    return [MMProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
}

/**
 关闭等待提示框(有动画)

 */
- (void)hideWithAnimated {
    [self hideAnimated:YES];
}

/**
 关闭等待提示框

 @param animated 是否包含动画
 */
- (void)hideAnimated:(BOOL)animated {
    [super hide:animated];
}

/**
 提示框
 
 @param message 展示内容
 */
+ (void)showHUD:(NSString *)message {
    [self showHUD:message withDelay:1.5];
}

/**
 提示框
 
 @param message 展示内容
 @param time 显示时间
 */
+ (void)showHUD:(NSString *)message withDelay:(float)time {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];

    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
//    hud.labelText.numberOfLines = 0;
    hud.userInteractionEnabled = NO;
//    hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
    
//    hud.label.textColor = RGBCOLOR(255, 255, 255);
//    hud.bezelView.color = RGBCOLOR(85, 86, 83);
//    hud.label.font = [UIFont systemFontOfSize:16];
//    hud.margin = 10.f;
//    hud.bezelView.layer.cornerRadius = 4.0;
//    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:time];
}

@end
