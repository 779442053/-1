//
//  UINavigationBarSet.m
//  hjqinspection
//
//  Created by yuanku on 2017/3/25.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "UINavigationBarSet.h"
#import <UIKit/UIKit.h>
#import "GlobalVariable.h"


@implementation UINavigationBarSet

/**
 设置导航栏
 */
+ (void)setUP {
    //导航栏颜色
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#333237"]];
    
    //导航栏标题
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //关闭模糊效果
    [[UINavigationBar appearance] setTranslucent:NO];

//自定义返回箭头 2019.4.11
//    //更改返回箭头颜色
//    [[UINavigationBar appearance] setTintColor:G_COLOR_BLACK_333333];
//
//    //设置返回的箭头自定义图片//imageWithRenderingMode 这个是图片的显示模式，设置成其他的选项，你的返回按钮的颜色不是自己图片颜色
//    UIImage  *backimage =[[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    //注意：下面两个属性都得设置，只设置一个是无效的
//    [[UINavigationBar appearance]  setBackIndicatorTransitionMaskImage:backimage];
//    [[UINavigationBar appearance] setBackIndicatorImage:backimage];
}

@end