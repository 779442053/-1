//
//  MMNextAddBankViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMNextAddBankViewController.h"

//Model
#import "MMBankInfoModel.h"

//View
#import "MMNextAddBankCell.h"

// Colors
#define TABLEVIEWCOLOR RGBCOLOR(239, 239, 244)

// Cell高度
static CGFloat const cellHeight = 52.0f;

static NSString *const identifier = @"bankInfo_cell_identify";

@interface MMNextAddBankViewController ()<UITableViewDelegate,UITableViewDataSource,MMAddBankDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, assign) BOOL isRender;

@property (nonatomic, strong) UIButton *commitBtn;

@end

@implementation MMNextAddBankViewController

#pragma mark - Getter

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
        _tableView.scrollEnabled = NO;
        
        [_tableView registerClass:[MMNextAddBankCell class] forCellReuseIdentifier:identifier];
        
    }
    return _tableView;
}

- (UIButton *)commitBtn
{
    if (!_commitBtn) {
        _commitBtn = [BaseUIView createBtn:CGRectZero
                                  AndTitle:@"确认提交"
                             AndTitleColor:[UIColor whiteColor]
                                AndTxtFont:[UIFont zwwNormalFont:17]
                                  AndImage:nil
                        AndbackgroundColor:RGBCOLOR(6, 156, 232)
                            AndBorderColor:nil
                           AndCornerRadius:3
                              WithIsRadius:YES
                       WithBackgroundImage:nil
                           WithBorderWidth:0];
        [_commitBtn addTarget:self action:@selector(commitAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitBtn;
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
            make.left.right.top.mas_equalTo(self.view);
            make.height.mas_equalTo(260);
        }];
    }
}


#pragma mark - Private

- (void)setupUI
{
    //MARK: 初始化UI
    [self setTitle:@"添加银行卡"];
    [self showLeftBackButton];
    
    
    [self initData];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.commitBtn];
}

- (void)initData
{
    MMBankInfoModel *model1 = [[MMBankInfoModel alloc] init];
    model1.bankTitle = @"银行卡号";
    model1.bankName = @"中国银行(5888)";
    model1.bankPlaceholder = @"";
    model1.bankInfo = @"";
    
    MMBankInfoModel *model2 = [[MMBankInfoModel alloc] init];
    model2.bankTitle = @"姓名";
    model2.bankName = @"";
    model2.bankPlaceholder = @"请输入姓名";
    model2.bankInfo = @"";

    MMBankInfoModel *model3 = [[MMBankInfoModel alloc] init];
    model3.bankTitle = @"身份证";
    model3.bankName = @"";
    model3.bankPlaceholder = @"请输入身份证号";
    model3.bankInfo = @"";

    MMBankInfoModel *model4 = [[MMBankInfoModel alloc] init];
    model4.bankTitle = @"手机";
    model4.bankName = @"";
    model4.bankPlaceholder = @"银行预留手机号";
    model4.bankInfo = @"";

    MMBankInfoModel *model5 = [[MMBankInfoModel alloc] init];
    model5.bankTitle = @"验证码";
    model5.bankName = @"";
    model5.bankPlaceholder = @"请输入验证码";
    model5.bankInfo = @"";

    
    
    _dataArr = @[
                 model1,
                 model2,
                 model3,
                 model4,
                 model5
                 ];
    
    [_tableView reloadData];
}

#pragma mark - Action

- (void)commitAction:(UIButton *)sender
{
    //MARK: 确认提交
    [self.view endEditing:YES];
    
}

#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMNextAddBankCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell addDelegate:self andIndexPath:indexPath];
    
    cell.bankInfoModel = _dataArr[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellHeight;
}

#pragma mark - Delegate

- (void)dosomething
{
    //MARK: dosomething
    
}

- (void)sendCode
{
    //MARK: 发送验证码
    
}

@end
