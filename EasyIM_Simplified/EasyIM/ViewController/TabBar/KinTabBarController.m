//
//  KinTabBarController.m
//  kin
//
//  Created by OnVo on 2017/3/8.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "KinTabBarController.h"
#import "YFButton.h"

#import "ChatViewController.h"
#import "MMContactsViewController.h"
#import "GameViewController.h"
#import "MMGameViewController.h"
#import "MeViewController.h"
#import "GroupViewController.h"

static const NSInteger TabbarItemNums = 5;
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#define kselectedImageArray @[@"tabbar_01ed",@"tabbar_02ed",@"tabbar_05ed",@"tabbar_05ed",@"tabbar_04ed"]
#define kimageArray @[@"tabbar_01",@"tabbar_02",@"tabbar_05",@"tabbar_03",@"tabbar_04"]
#define ktitleArray @[@"聊天",@"通讯录",@"群组",@"游戏",@"我"]

@interface KinTabBarController ()<YFButtonDelegate>

@property (nonatomic, strong) UIView *moreBackgroundView;
@property (nonatomic, strong) YFButton *foreMoreButton; //点击更多之前的按钮
@property (nonatomic, strong) YFButton *homePageButton; //首页
@property (nonatomic, strong) UIView *barImageView;

@property (nonatomic, strong) MMContactsViewController *contactVC;
@property (nonatomic, strong) ChatViewController *chatVC;
@property (nonatomic, strong) MeViewController *meVC;
@property (nonatomic, strong) MMGameViewController *gameVC;
@property (nonatomic, strong) GroupViewController *GroupVC;
@end

@implementation KinTabBarController

- (instancetype)initWithSelectVCIndex:(NSInteger)selectVCIndex {
    if (self = [super init]) {
        [self createTabbarButtonWithSelectVCIndex:selectVCIndex];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    //聊天、通讯录、游戏、我
    BaseNavgationController *chatnav = [[BaseNavgationController alloc] initWithRootViewController:self.chatVC];
    BaseNavgationController *contactNav = [[BaseNavgationController alloc] initWithRootViewController:self.contactVC];
    BaseNavgationController *GroupNav = [[BaseNavgationController alloc] initWithRootViewController:self.GroupVC];
    BaseNavgationController *gameNav = [[BaseNavgationController alloc] initWithRootViewController:self.gameVC];
    BaseNavgationController *meNav = [[BaseNavgationController alloc] initWithRootViewController:self.meVC];
    self.viewControllers = @[
                             chatnav,
                             contactNav,
                             GroupNav,
                             gameNav,
                             meNav
                        ];
}

- (void)createTabbarButtonWithSelectVCIndex:(NSInteger)selectVCIndex
{
    //在系统的Tabbar上添加UIImageView控件
    [self.tabBar addSubview:self.barImageView];
    for (int i = 0; i < self.viewControllers.count; i++) {
        //tabbar宽度
        float width = G_SCREEN_WIDTH/(float)self.viewControllers.count;
        
        UIButton *tabbarButton = [[UIButton alloc] initWithFrame:CGRectMake(width*i, 0, width, 49)];
        tabbarButton.tag = 0x845564+i;
        [tabbarButton addTarget:self action:@selector(YFChoiceButtonSelectedButton:) forControlEvents:UIControlEventTouchUpInside];
        if ([self isIphoneX]) {
            tabbarButton.frame = CGRectMake(width*i, 0, width, 80);
        }
        UIImageView *normalImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, G_GET_SCALE_HEIGHT(4), G_GET_SCALE_HEIGHT(27), G_GET_SCALE_HEIGHT(27))];
        normalImage.image = [UIImage imageNamed:kimageArray[i]];
        if (i == 0) {
            normalImage.image = [UIImage imageNamed:kselectedImageArray[i]];
        }
        normalImage.centerX = width/2;
        normalImage.tag = 0x544454+i;
        [tabbarButton addSubview:normalImage];
        UILabel *btnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 45, 11)];
        btnTitleLabel.font = [UIFont systemFontOfSize:11];
        btnTitleLabel.textColor = [UIColor colorWithHexString:@"#A9A9A9"];
        btnTitleLabel.text = ktitleArray[i];
        [tabbarButton addSubview:btnTitleLabel];
        btnTitleLabel.textAlignment = NSTextAlignmentCenter;
        btnTitleLabel.centerX = normalImage.centerX;
        btnTitleLabel.top = normalImage.bottom+2;
        btnTitleLabel.tag = 0x4855485+i;
        if (i == 0) {
            btnTitleLabel.textColor = [UIColor colorWithHexString:@"#007bf3"];
        }
        [self.barImageView addSubview:tabbarButton];
    }
}
-(UIView *)barImageView{
    if (!_barImageView) {
        _barImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, ZWTabbarHeight)];
        _barImageView.backgroundColor = [UIColor whiteColor];
        _barImageView.userInteractionEnabled = YES;
    }
    return _barImageView;
}
//MARK: - lazy load
-(MMContactsViewController *)contactVC{
    if (!_contactVC) {
        _contactVC = [[MMContactsViewController alloc] init];
    }
    return _contactVC;
}

- (ChatViewController *)chatVC{
    if (!_chatVC) {
        _chatVC = [[ChatViewController alloc] init];
    }
    return _chatVC;
}
    
- (MeViewController *)meVC{
    if (!_meVC) {
        _meVC = [[MeViewController alloc] init];
    }
    return _meVC;
}

- (MMGameViewController *)gameVC{
    if (!_gameVC) {
        _gameVC = [[MMGameViewController alloc] init];
    }
    return _gameVC;
}
-(GroupViewController *)GroupVC{
    if (_GroupVC == nil) {
        _GroupVC = [[GroupViewController alloc]init];
    }
    return _GroupVC;
}

//MARK: - 小红点
//显示小红点
- (void)showBadgeOnItemIndex:(NSInteger)index
                   withValue:(NSInteger)badgeVal{
    //移除之前的小红点
    [self removeBadgeOnItemIndex:index];
    
    //新建小红点
    UILabel *badgeView = [[UILabel alloc] init];
    
    //文本
    badgeView.text = badgeVal>99?@"...":[NSString stringWithFormat:@"%ld",badgeVal];
    badgeView.textColor = [UIColor whiteColor];
    badgeView.font = FONT(10);
    badgeView.adjustsFontSizeToFitWidth = YES;
    badgeView.textAlignment = NSTextAlignmentCenter;
    badgeView.tag = 888 + index;
    badgeView.layer.cornerRadius = 7.5;//圆形
    badgeView.backgroundColor = [UIColor redColor];//颜色：红色
    CGRect tabFrame = self.barImageView.frame;
    
    //确定小红点的位置
    CGFloat percentX = (index + 0.6) / TabbarItemNums;
    CGFloat x = ceilf(percentX * tabFrame.size.width);
    CGFloat y = ceilf(0.1 * tabFrame.size.height);
    badgeView.frame = CGRectMake(x, y, 15.0, 15.0);//圆形大小为10
    badgeView.clipsToBounds = YES;
    [self.barImageView addSubview:badgeView];
}

//隐藏小红点
- (void)hideBadgeOnItemIndex:(NSInteger)index{
    //移除小红点
    [self removeBadgeOnItemIndex:index];
}

//移除小红点
- (void)removeBadgeOnItemIndex:(NSInteger)index{
    //按照tag值进行移除
    for (UIView *subView in self.barImageView.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}


#pragma mark - YFButtonDelegate
- (void)YFChoiceButtonSelectedButton:(UIButton *)button {
    long k = button.tag - 0x845564;
    UIImageView *selectImgView = [self.view viewWithTag:0x544454+k];
    selectImgView.image = [UIImage imageNamed:kselectedImageArray[k]];
    UILabel *btnTitleLabel = [self.view viewWithTag:0x4855485+k];
    btnTitleLabel.textColor = [UIColor colorWithHexString:@"007bf3"];
    for (int i = 0; i<kimageArray.count; i++) {
        if (i!=k) {
            UIImageView *normalImg = [self.view viewWithTag:0x544454+i];
            normalImg.image = [UIImage imageNamed:kimageArray[i]];
            UILabel *normalLabel = [self.view viewWithTag:0x4855485+i];
            normalLabel.textColor = [UIColor colorWithHexString:@"9a9a9a"];
        }
    }
    MMBaseViewController *vc = self.viewControllers[k];
    self.selectedViewController = vc;
}

- (void)selectHomePage {
    _foreMoreButton = _homePageButton;
    _homePageButton.choiceType = YFChoiceButtonStatusTypeSelected;
    self.selectedViewController = self.viewControllers[0];
}
- (BOOL)isIphoneX
{
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
