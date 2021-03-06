//
//  MMBlankSettingViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBlankSettingViewController.h"

//Venders
#import <MJRefresh.h>

//View
#import "MMBlankSettingCell.h"

//ViewController
#import "MMAddBankViewController.h"

// Colors
#define TABLEVIEWCOLOR RGBCOLOR(239, 239, 244)

// Cell高度
static CGFloat const cellHeight = 80.0f;
static CGFloat const headHeight = 15.0f;

static NSString *const identifier = @"bankInfo_cell_identify";

@interface MMBlankSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL isRender;

@end

@implementation MMBlankSettingViewController

#pragma mark - Getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
        
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
        
        _tableView.tableFooterView = [UIView new];
        
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        
        [_tableView registerClass:[MMBlankSettingCell class] forCellReuseIdentifier:identifier];
        
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self getData];
            });
        }];
    }
    return _tableView;
}

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


#pragma mark - Private

- (void)setupUI
{
    [self setTitle:@"银行卡设置"];
    [self showLeftBackButton];
    //[self addRightBtnWithImage:[UIImage imageNamed:@"wallet_addBank"]];
    [self.view addSubview:self.tableView];
}

- (void)rightAction
{
    //MARK: 右键"加"按钮事件
    MMAddBankViewController *addBank = [[MMAddBankViewController alloc] init];
    [self.navigationController pushViewController:addBank animated:YES];
}

- (void)getData
{
    //MARK: 获取接口数据
    
    [_tableView.mj_header endRefreshing];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return [self.dataSource count];
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMBlankSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.dataSource count]>indexPath.row) {
#warning 暂不设置数据
//        cell.bankSettingModel = self.dataSource.count;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [UIView new];
    return sectionView;
}

@end
