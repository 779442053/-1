//
//  MMSelectBankMViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMSelectBankMViewController.h"

#import "MMSelectBankCell.h"
#import "MMSelectBankModel.h"

@interface MMSelectBankMViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 底部整体View*/
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, strong) UIView *headView;
@property (nonatomic, strong) UIButton *dimissBtn;


@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;


@end

@implementation MMSelectBankMViewController

static NSString *const identifier = @"cell_identify";

// Cell高度
static CGFloat const cellHeight = 60.0f;

#pragma mark - Getter

- (UIView *)bodyView
{
    if (!_bodyView) {
        _bodyView = [BaseUIView createView:CGRectZero
                        AndBackgroundColor:[UIColor grayColor]
                               AndisRadius:NO
                                 AndRadiuc:0
                            AndBorderWidth:0
                            AndBorderColor:nil
                     ];
    }
    return _bodyView;
}

- (UIView *)headView
{
    if (!_headView) {
        _headView = [BaseUIView createView:CGRectZero
                        AndBackgroundColor:[UIColor whiteColor]
                               AndisRadius:NO
                                 AndRadiuc:0
                            AndBorderWidth:0
                            AndBorderColor:nil
                     ];
    }
    return _headView;
}

- (UIButton *)dimissBtn
{
    if (!_dimissBtn) {
        _dimissBtn = [BaseUIView createBtn:CGRectZero
                                  AndTitle:nil
                             AndTitleColor:nil
                                AndTxtFont:[UIFont zwwNormalFont:10]
                                  AndImage:[UIImage imageNamed:@"wallet_close"]
                        AndbackgroundColor:nil
                            AndBorderColor:nil
                           AndCornerRadius:0
                              WithIsRadius:NO
                       WithBackgroundImage:nil
                           WithBorderWidth:0
                      ];
        [_dimissBtn addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dimissBtn;
}

//- (UILabel *)titleLabel
//{
//    if (!_titleLabel) {
//        _titleLabel = [BaseUIView createLable:CGRectZero
//                                      AndText:@"选择充值银行卡"
//                                 AndTextColor:[UIColor blackColor]
//                                   AndTxtFont:FONT(17)
//                           AndBackgroundColor:nil
//                       ];
//    }
//    return _titleLabel;
//}

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
    
        [_tableView registerClass:[MMSelectBankCell class] forCellReuseIdentifier:identifier];
        
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
        
        MMSelectBankModel *model1 = [[MMSelectBankModel alloc] init];
        model1.bankName = @"招商银行(5888)";
        model1.bankImageName = @"wallet_small_icbc";
        
        MMSelectBankModel *model2 = [[MMSelectBankModel alloc] init];
        model2.bankName = @"农业银行(5888)";
        model2.bankImageName = @"wallet_small_icbc";
        
        MMSelectBankModel *model3 = [[MMSelectBankModel alloc] init];
        model3.bankName = @"上海银行(5888)";
        model3.bankImageName = @"wallet_small_icbc";
        
        MMSelectBankModel *model4 = [[MMSelectBankModel alloc] init];
        model4.bankName = @"天地银行(8888)";
        model4.bankImageName = @"wallet_small_icbc";
        
        MMSelectBankModel *model5 = [[MMSelectBankModel alloc] init];
        model5.bankName = @"使用新卡充值";
        model5.bankImageName = @"wallet_addCart";

        
        [_dataSource addObject:model1];
        [_dataSource addObject:model2];
        [_dataSource addObject:model3];
        [_dataSource addObject:model4];
        [_dataSource addObject:model5];
    }
    return _dataSource;
}

#pragma mark - Init

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
}

#pragma mark - Private

- (void)setupUI
{
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    [self.view addSubview:self.bodyView];
    [self.bodyView addSubview:self.headView];
    
    [self.headView addSubview:self.dimissBtn];
    [self.headView addSubview:self.titleLabel];
    [self.bodyView addSubview:self.tableView];
    [self addLayout];

}

- (void)addLayout
{
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(300);
        make.left.right.bottom.mas_equalTo(self.view);
    }];
    
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self.bodyView);
        make.height.mas_equalTo(60);
    }];
    
    [self.dimissBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.headView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.headView.mas_centerX);
        make.centerY.mas_equalTo(self.headView.mas_centerY);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self.bodyView);
        make.top.mas_equalTo(self.headView.mas_bottom).offset(0.5);
    }];
}

#pragma mark - Action

- (void)closeAction:(UIButton *)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectBankWithTitle:andIndexPath:)]) {
            MMSelectBankModel *model = _dataSource[_indexPath.row];
            NSString *nameStr = model.bankName;
            [self.delegate selectBankWithTitle:nameStr andIndexPath:_indexPath];
        }
    }];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMSelectBankCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    if (_indexPath == indexPath) {
        [cell.selectIcon setImage:[UIImage imageNamed:@"wallet_select"]];
    }else{
        [cell.selectIcon setImage:[UIImage imageNamed:@"wallet_unselect"]];
    }
    
    if (self.dataSource.count > indexPath.row && self.dataSource.count) {
        
        cell.selectBankModel = self.dataSource[indexPath.row];
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消之前的选择
    MMSelectBankCell *celled = [tableView cellForRowAtIndexPath:_indexPath];
    [celled.selectIcon setImage:[UIImage imageNamed:@"wallet_unselect"]];
    
    //记录当前的选择的位置
    _indexPath = indexPath;
    
    //当前选择的打钩
    MMSelectBankCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell.selectIcon setImage:[UIImage imageNamed:@"wallet_select"]];
}

@end
