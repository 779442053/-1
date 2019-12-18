//
//  KinTabBarController.h
//  kin
//
//  Created by OnVo on 2017/3/8.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KinTabBarController : UITabBarController

- (void)selectHomePage;

/**
 设置初始选择VC
 
 @param selectVCIndex VC位置
 @return tabbar控制器
 */
- (instancetype)initWithSelectVCIndex:(NSInteger)selectVCIndex;

/** 显示小红点 */
- (void)showBadgeOnItemIndex:(NSInteger)index
                   withValue:(NSInteger)badgeVal;

/** 隐藏小红点 */
- (void)hideBadgeOnItemIndex:(NSInteger)index;

@end
