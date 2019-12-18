//
//  MMBaseViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//


//
//基类：主要功能
//1.设置页面跳转拦截条件。
//2.返回是否登录并跳转。
//3.根据项目添加基类方法。
//

#import "ZWBaseViewControllerProtocol.h"
#import "BaseNavgationController.h"
#import "ZWMessage.h"
#import "MJRefresh.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMBaseViewController : UIViewController<ZWBsaeViewcontrollerProtocal>
@property (nonatomic, assign) BOOL isHidenHomeLine;
@property (nonatomic, assign) BOOL statusBarHidden;
@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) UIView *navigationBgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
- (void)setTitle:( NSString * _Nullable )title;
- (void)showLeftBackButton;

/**
 去登录
 */
- (void)isLogin;



- (BOOL)isIphoneX;



@end

NS_ASSUME_NONNULL_END
