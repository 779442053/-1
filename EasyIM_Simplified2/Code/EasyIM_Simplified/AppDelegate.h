//
//  AppDelegate.h
//  EasyIM
//
//  Created by 魏勇城 on 2019/1/3.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KinTabBarController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) KinTabBarController *tabBarController;
+(UIViewController *)appRootViewController;
//单例
+ (AppDelegate *)shareAppDelegate;
@end

