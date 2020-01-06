//
//  MMBaseViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

#import "LoginVC.h"

@interface MMBaseViewController ()

@end

@implementation MMBaseViewController
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    MMBaseViewController*viewController = [super allocWithZone:zone];
    ZWWWeakSelf(viewController)

    [[viewController rac_signalForSelector:@selector(viewDidLoad)] subscribeNext:^(id x) {
        ZWWStrongSelf(viewController);
        [viewController zw_addSubviews];
        [viewController zw_bindViewModel];
    }];
    [[viewController rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id x) {
        ZWWStrongSelf(viewController);
        [viewController zw_layoutNavigation];
        [viewController zw_getNewData];
    }];
    return viewController;
}
- (instancetype)initWithViewModel:(id<ZWBaseViewModelProtocol>)viewModel {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    self.statusBarStyle = UIStatusBarStyleLightContent;
    self.view.backgroundColor = [UIColor colorWithHexString:@"f2f2f7"];
    //防止顶部出现未知空白
    if (@available(iOS 11.0, *)) {
        [UITableView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [UICollectionView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else {
        if([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
        {
            self.automaticallyAdjustsScrollViewInsets=NO;
        }
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
            //通过设置此属性，你可以指定view的边（上、下、左、右）延伸到整个屏幕。
        }
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setNavView];
}
- (void)viewDidLayoutSubviews
{
    [self.view bringSubviewToFront:_navigationView];//始终放在最上层
}
- (void)setNavView
{
    _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ZWStatusAndNavHeight)];
    _navigationView.backgroundColor = [UIColor colorWithHexString:@"#333237"];
    [self.view addSubview:_navigationView];
    _navigationBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, ZWStatusAndNavHeight)];
    _navigationBgView.backgroundColor = [UIColor colorWithHexString:@"#333237"];
    [_navigationView addSubview:_navigationBgView];
}
- (void)setTitle:(NSString *)title
{
    [_navigationView addSubview:self.titleLabel];
    _titleLabel.text = title;
}
- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_navigationView.mj_w/2 - 100, _navigationView.mj_h - 30, 200, 20)];
        _titleLabel.font = [UIFont zwwNormalFont:18];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}
- (void)showLeftBackButton
{
    _leftButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _leftButton.frame = CGRectMake(15, ZWStatusBarHeight + 5, 45, 35);
    [_leftButton setImage:[UIImage imageNamed:@"App_back"] forState:(UIControlStateNormal)];
    [_leftButton addTarget:self action:@selector(backAction) forControlEvents:(UIControlEventTouchUpInside)];
    [_navigationView addSubview:_leftButton];
}
- (void)backAction
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    viewControllerToPresent.modalPresentationStyle = 0;
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}
#if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
- (UIUserInterfaceStyle)overrideUserInterfaceStyle{
    return UIUserInterfaceStyleLight;
}
#endif
//MARK: - 状态栏颜色
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)isLogin {
    BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:[LoginVC new]];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (BOOL)isIphoneX{
    if (@available(iOS 11.0, *)) {
        CGFloat a =  [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom;
        if (a>0) {
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}
//点击屏幕任一点.键盘消失=
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}
//隐藏iPhone X的home条
- (BOOL)prefersHomeIndicatorAutoHidden {
    return self.isHidenHomeLine;
}
- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}
#pragma mark - RAC
/**
 *  添加控件
 */
- (void)zw_addSubviews {}
/**
 *  绑定
 */
- (void)zw_bindViewModel {}
/**
 *  设置navation
 */
- (void)zw_layoutNavigation {}
/**
 *  初次获取数据
 */
- (void)zw_getNewData {}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ZWWLog(@"%@--释放了释放了释放了释放了",NSStringFromClass([self class]));
}

@end
