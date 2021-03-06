//
//  MMChildViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMChildViewController.h"

//Categoties
#import "UIViewController+ZJScrollPageController.h"

//Venders
#import <MJRefresh.h>

//View
#import "MMChildCell.h"

//Model
#import "MMChildModel.h"

// Colors
#define TABLEVIEWCOLOR RGBCOLOR(239, 239, 244)


@interface MMChildViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL isRender;


@end

@implementation MMChildViewController

#pragma mark - Getter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:0];

        MMChildModel *model1 = [[MMChildModel alloc] init];
        model1.bankName = @"中国银行(5888)";
        model1.bankAmount = -100;
        model1.bankTime = @"9月11日 01:11";
        model1.bankState = 0;
        
        MMChildModel *model3 = [[MMChildModel alloc] init];
        model3.bankName = @"中国银行(5888)";
        model3.bankAmount = +10000;
        model3.bankTime = @"9月11日 01:11";
        model3.bankState = 1;
        
        MMChildModel *model2 = [[MMChildModel alloc] init];
        model2.bankName = @"中国银行(5888)";
        model2.bankAmount = 88.88;
        model2.bankTime = @"9月11日 01:00";
        model2.bankState = 2;
        
        [_dataSource addObject:model1];
        [_dataSource addObject:model3];
        [_dataSource addObject:model2];
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
//        _tableView.backgroundColor = TABLEVIEWCOLOR;
        _tableView.tableFooterView = [UIView new];
        
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

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)zj_viewDidLoadForIndex:(NSInteger)index {
    NSLog(@"%@",self.view);
    NSLog(@"%@", self.zj_scrollViewController);

    [self setupUI];
}

- (void)zj_viewDidAppearForIndex:(NSInteger)index
{
    
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
    self.view.backgroundColor = TABLEVIEWCOLOR;
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

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    MMChildCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MMChildCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if ([self.dataSource count] > indexPath.row) {
        cell.childModel = self.dataSource[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.0f;
}

@end
