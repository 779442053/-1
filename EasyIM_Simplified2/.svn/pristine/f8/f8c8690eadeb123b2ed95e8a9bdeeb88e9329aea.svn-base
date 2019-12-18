//
//  MBProgressHUDPrompt.h
//  speedauction
//
//  Created by apple on 16/12/9.
//  Copyright © 2016年 enjoyor. All rights reserved.
//

#import <MBProgressHUD.h>

@interface MMProgressHUD : MBProgressHUD

/**
 等待提示框
 
 */
+ (MMProgressHUD *)showHUD;

/**
 关闭等待提示框(有动画)
 
 */
- (void)hideWithAnimated;

/**
 提示框
 
 @param message 展示内容
 */
+ (void)showHUD:(NSString *)message;

/**
 提示框
 
 @param message 展示内容
 @param time 显示时间
 */
+ (void)showHUD:(NSString *)message withDelay:(float)time;

+ (MMProgressHUD *) showHUDWithProgress:(NSString *)message;

@end
