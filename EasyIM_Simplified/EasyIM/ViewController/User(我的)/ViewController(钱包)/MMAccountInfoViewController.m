//
//  MMAccountInfoViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMAccountInfoViewController.h"

//Views
#import "MMAccountInfoCell.h"

//Venders
#import <MJRefresh.h>

//Model
#import "MMAccountInfoModel.h"


#define TABLEVIEWCOLOR RGBCOLOR(239, 239, 244)

static NSString *const identifier = @"accountInfoCell";

@interface MMAccountInfoViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL isRender;

@end

@implementation MMAccountInfoViewController

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
    }
}

#pragma mark - Getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
        /** 测试数据*/
        
        MMAccountInfoModel *model1 = [[MMAccountInfoModel alloc] init];
        model1.accountName = @"中心钱包";
        model1.accountWallet = 100;
        
        MMAccountInfoModel *model2 = [[MMAccountInfoModel alloc] init];
        model2.accountName = @"AG钱包";
        model2.accountWallet = 20;

        MMAccountInfoModel *model3 = [[MMAccountInfoModel alloc] init];
        model3.accountName = @"eBET钱包";
        model3.accountWallet = 100;

        MMAccountInfoModel *model4 = [[MMAccountInfoModel alloc] init];
        model4.accountName = @"PG钱包";
        model4.accountWallet = 100;

        MMAccountInfoModel *model5 = [[MMAccountInfoModel alloc] init];
        model5.accountName = @"捕鱼钱包";
        model5.accountWallet = 100;
        
        [_dataSource addObject:model1];
        [_dataSource addObject:model2];
        [_dataSource addObject:model3];
        [_dataSource addObject:model4];
        [_dataSource addObject:model5];

    }
    return _dataSource;
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
        
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        
        [_tableView registerClass:[MMAccountInfoCell class] forCellReuseIdentifier:identifier];
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getData];
            });
        }];
    }
    return _tableView;
}
#pragma mark - Private
- (void)setupUI
{
    [self setTitle:@"账户信息"];
    [self showLeftBackButton];
    [self.view addSubview:self.tableView];
}

- (void)getData
{
    [_tableView.mj_header endRefreshing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMAccountInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /** 每行只有一个Row 共有[DataSource count] 个Section*/
    if (self.dataSource && [self.dataSource count] > indexPath.section) {
        cell.accountModel = self.dataSource[indexPath.section];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [UIView new];
    [sectionView setBackgroundColor:TABLEVIEWCOLOR];
    return sectionView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // do something
    
}

@end
