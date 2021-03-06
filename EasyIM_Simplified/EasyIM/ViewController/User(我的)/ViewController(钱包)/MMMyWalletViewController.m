//
//  MMMyWalletViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMMyWalletViewController.h"

//Tools
#import "GlobalVariable.h"

//Venders
#import <MJRefresh.h>

//ViewControlls
#import "MMRechargeViewController.h"
#import "MMWithdrawalViewController.h"
#import "MMAccountInfoViewController.h"
#import "MMLineConversionViewController.h"
#import "MMBlankSettingViewController.h"
#import "MMTradeHisViewController.h"

////////////////////////////////////////////////////////////////////////

#define NAVTINTCOLOR RGBCOLOR(21, 126, 251)
#define TABLEVIEWCOLOR RGBCOLOR(239, 239, 244)
#define APPLYVIEWCOLOR RGBCOLOR(6, 101, 214)

////////////////////////////////////////////////////////////////////////

// Cell高度
static CGFloat const cellHeight = 46.0f;
// Section高度
static CGFloat const sectionHeight = 12.0f;

////////////////////////////////////////////////////////////////////////

@interface MMMyWalletViewController ()<UITableViewDelegate,UITableViewDataSource>
/** 上半部分*/
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIButton *rechargeBtn;    // 充值button
@property (nonatomic, strong) UIButton *withdrawalBtn; // 提现button
@property (nonatomic, strong) UIButton *accountBalanceBtn; // 账户余额button
@property (nonatomic, strong) UIImageView *accountBalanceImg; // 账户余额Image
@property (nonatomic, strong) UILabel *accountLabel;// 显示余额

/** 下半部分*/
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

/** 渲染*/
@property (nonatomic, assign) BOOL isRender;

@end

@implementation MMMyWalletViewController

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!_isRender) {
        _isRender = YES;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).with.mas_offset(ZWStatusAndNavHeight);
        }];
        
        [self.accountBalanceImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.accountBalanceBtn.mas_left).offset(-6);
            make.centerY.mas_equalTo(self.accountBalanceBtn.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(16, 18));
        }];
        
        [self.accountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.headView.mas_centerX);
            make.top.mas_equalTo(self.accountBalanceImg.mas_bottom).offset(12);
        }];
        
    }
}


#pragma mark - Private

- (void)setupUI
{
    //1.设置导航栏
    [self setTitle:@"我的钱包"];
    self.navigationView.backgroundColor = NAVTINTCOLOR;
    self.navigationBgView.backgroundColor = NAVTINTCOLOR;
    //2.添加返回按钮
    [self showLeftBackButton];
    //3.添加TableView
    [self.view addSubview:self.tableView];
}

- (void)getData
{
    //MARK: 获取接口数据
    
    [_tableView.mj_header endRefreshing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - Getter

- (UIView *)headView
{
    if (!_headView) {
        
        CGFloat h = 168.0f;
        CGFloat w = SCREEN_WIDTH;
        CGFloat x = 0.0;
        CGFloat y = 0.0;
        
        _headView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [_headView setBackgroundColor:NAVTINTCOLOR];
        
        // 账户余额(图片,文字)
        [_headView addSubview:self.accountBalanceBtn];
        [_headView addSubview:self.accountBalanceImg];
        [_headView addSubview:self.accountLabel];
        
        // 充值,提现View
        h = 45.0f;
        y = CGRectGetHeight(_headView.frame) - h;
        
        UIView *applyView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
        [applyView setBackgroundColor:APPLYVIEWCOLOR];
        [_headView addSubview:applyView];
        
        // 添加充值,提现按钮
        [applyView addSubview:self.rechargeBtn];
        [applyView addSubview:self.withdrawalBtn];
        
        // 添加中间白线
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectZero];
        [lineView setBackgroundColor:[UIColor whiteColor]];
        lineView.frame = CGRectMake((SCREEN_WIDTH-1)/2, 8.5, 1, 28);
        [applyView addSubview:lineView];
        
        
        
    }
    return _headView;
}

-(UITableView *)tableView
{
    if (! _tableView) {
        
        _tableView = [[UITableView alloc]
                      initWithFrame:CGRectZero
                      style:UITableViewStylePlain];
        _tableView.delegate = (id<UITableViewDelegate>)self;
        _tableView.dataSource = (id<UITableViewDataSource>)self;
        
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = TABLEVIEWCOLOR;
        
        _tableView.tableFooterView = [UIView new];
        _tableView.tableHeaderView = self.headView;
        
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getData];
            });
        }];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = @[
                        @{
                            @"icon":@"wallet_account",
                            @"name":@"账户信息"
                            },
                        @{
                            @"icon":@"wallet_history",
                            @"name":@"交易记录"
                            },
                        @{
                            @"icon":@"wallet_account",
                            @"name":@"额度转换"
                            },
                        @{
                            @"icon":@"wallet_bank",
                            @"name":@"银行卡设置"
                            },
                        ].mutableCopy;
    }
    return _dataSource;
}
- (UIButton *)rechargeBtn
{
    if (!_rechargeBtn) {
        _rechargeBtn = [BaseUIView createBtn:CGRectMake(0, 0, SCREEN_WIDTH/2, 45)
                                    AndTitle:@"充值"
                               AndTitleColor:[UIColor whiteColor]
                                  AndTxtFont:FONT(15)
                                    AndImage:[UIImage imageNamed:@"wallet_recharge"]
                          AndbackgroundColor:[UIColor clearColor]
                              AndBorderColor:nil
                             AndCornerRadius:0
                                WithIsRadius:NO
                         WithBackgroundImage:nil
                             WithBorderWidth:0
                        ];
        //button图片的偏移量，距上左下右分别(10, 10, 10, 50)像素点
        _rechargeBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 50);
        //button标题的偏移量，这个偏移量是相对于图片的
        _rechargeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        
        [_rechargeBtn addTarget:self action:@selector(rechargeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rechargeBtn;
}

- (UIButton *)withdrawalBtn
{
    if (!_withdrawalBtn) {
        _withdrawalBtn = [BaseUIView createBtn:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 45)
                                      AndTitle:@"提现"
                                 AndTitleColor:[UIColor whiteColor]
                                    AndTxtFont:FONT(15)
                                      AndImage:[UIImage imageNamed:@"wallet_withdrawal"]
                            AndbackgroundColor:[UIColor clearColor]
                                AndBorderColor:nil
                               AndCornerRadius:0
                                  WithIsRadius:NO
                           WithBackgroundImage:nil
                               WithBorderWidth:0
                          ];
        //button图片的偏移量，距上左下右分别(10, 10, 10, 50)像素点
        _withdrawalBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 50);
        //button标题的偏移量，这个偏移量是相对于图片的
        _withdrawalBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
        
        [_withdrawalBtn addTarget:self action:@selector(withdrawalAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _withdrawalBtn;
}

- (UIButton *)accountBalanceBtn
{
    if (!_accountBalanceBtn) {
        _accountBalanceBtn = [BaseUIView createBtn:CGRectMake(0, 25, 70, 44)
                                      AndTitle:@"账户余额"
                                 AndTitleColor:[UIColor whiteColor]
                                    AndTxtFont:FONT(15)
                                      AndImage:nil
                            AndbackgroundColor:[UIColor clearColor]
                                AndBorderColor:nil
                               AndCornerRadius:0
                                  WithIsRadius:NO
                           WithBackgroundImage:nil
                               WithBorderWidth:0
                          ];
        _accountBalanceBtn.centerX = self.view.centerX + 10;
    }
    return _accountBalanceBtn;
}

- (UIImageView *)accountBalanceImg
{
    if (!_accountBalanceImg) {
        _accountBalanceImg = [BaseUIView createImage:CGRectZero
                                            AndImage:[UIImage imageNamed:@"wallet_cont"]
                                  AndBackgroundColor:nil
                                        WithisRadius:NO
                              ];
    }
    return _accountBalanceImg;
}

- (UILabel *)accountLabel
{
    if (!_accountLabel) {
        _accountLabel = [BaseUIView createLable:CGRectZero
                                        AndText:@"¥100.00"
                                   AndTextColor:[UIColor whiteColor]
                                     AndTxtFont:FONT(17)
                             AndBackgroundColor:nil
                         ];
    }
    return _accountLabel;
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSDictionary *dic = self.dataSource[indexPath.row];
    [cell.imageView setImage:[UIImage imageNamed:dic[@"icon"]]];
    [cell.textLabel setText:dic[@"name"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headSection = [[UIView alloc] init];
    [headSection setBackgroundColor:TABLEVIEWCOLOR];
    return headSection;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMBaseViewController *viewController;
    switch (indexPath.row) {
        case 0:
        {
            //MARK: 跳转账户信息
            viewController = [[MMAccountInfoViewController alloc] init];
        }
            break;
        case 1:
        {
            //MARK: 交易记录
            viewController = [[MMTradeHisViewController alloc] init];
        }
            break;
        case 2:
        {
            //MARK: 转换额度
            viewController = [[MMLineConversionViewController alloc] init];
        }
            break;
        case 3:
        {
            //MARK: 银行卡设置
            viewController = [[MMBlankSettingViewController alloc] init];
        }
            break;

        default:
            break;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Action

- (void)rechargeAction:(UIButton *)sender
{
    //MARK: 充值
    MMRechargeViewController *recharge = [[MMRechargeViewController alloc] init];
    [self.navigationController pushViewController:recharge animated:YES];
}

- (void)withdrawalAction:(UIButton *)sender
{
    //MARK: 提现
    MMWithdrawalViewController *withdrawal = [[MMWithdrawalViewController alloc] init];
    [self.navigationController pushViewController:withdrawal animated:YES];
}


@end
