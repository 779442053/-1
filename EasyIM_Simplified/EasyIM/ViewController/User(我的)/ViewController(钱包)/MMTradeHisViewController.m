//
//  MMTradeHisViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/10.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMTradeHisViewController.h"

#import "ZJScrollPageView.h"
#import "MMChildViewController.h"

#define NAVTINTCOLOR RGBCOLOR(21, 126, 251)

@interface MMTradeHisViewController ()<ZJScrollPageViewDelegate>

@property(strong, nonatomic)NSArray<NSString *> *titles;
@property(strong, nonatomic)NSArray<UIViewController *> *childVcs;
@property (nonatomic, strong) ZJScrollPageView *scrollPageView;


@end

@implementation MMTradeHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

#pragma mark - Private

- (void)setupUI
{
    [self setTitle:@"交易记录"];
    [self showLeftBackButton];
    //必要的设置, 如果没有设置可能导致内容显示不正常
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    ZJSegmentStyle *style = [[ZJSegmentStyle alloc] init];
    //显示滚动条
    style.showLine = YES;
    // 颜色渐变
    style.gradualChangeTitleColor = YES;
    // 自动调整标题的宽度
    style.autoAdjustTitlesWidth = YES;
    // 滚动条颜色
    style.scrollLineColor = NAVTINTCOLOR;
    // 标题选中状态的颜色
    style.selectedTitleColor = NAVTINTCOLOR;
    
    self.titles = @[
                    @"全部",
                    @"收入",
                    @"支出",
                    ];
    // 初始化
    _scrollPageView = [[ZJScrollPageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-ZWStatusAndNavHeight) segmentStyle:style titles:self.titles parentViewController:self delegate:self];
    
    [self.view addSubview:_scrollPageView];
}


#pragma mark - ZJScrollPageViewDelegate

- (NSInteger)numberOfChildViewControllers {
    return self.titles.count;
}

- (UIViewController<ZJScrollPageViewChildVcDelegate> *)childViewController:(UIViewController<ZJScrollPageViewChildVcDelegate> *)reuseViewController forIndex:(NSInteger)index {
    UIViewController<ZJScrollPageViewChildVcDelegate> *childVc = reuseViewController;
    
    if (!childVc) {
        childVc = [[MMChildViewController alloc] init];
    }
    
        NSLog(@"%ld-----%@",(long)index, childVc);
    
    return childVc;
}


- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}


@end
