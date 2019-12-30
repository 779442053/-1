//
//  MMForward_GroupViewController.m
//  EasyIM
//
//  Created by momo on 2019/7/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMForward_GroupViewController.h"
#import "ZWChartViewModel.h"
@interface MMForward_GroupViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *selectDataArr;
@property (nonatomic, strong) ZWChartViewModel *ViewModel;
@end

@implementation MMForward_GroupViewController

- (instancetype)initWithSelectDataArr:(NSArray *)dataArr
{
    self = [super init];
    if (self) {
        [self.selectDataArr addObjectsFromArray:dataArr];
    }
    
    return self;
}
-(ZWChartViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWChartViewModel alloc]init];
    }
    return _ViewModel;
}
#pragma mark - Getter&Setter

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    
    return _dataSource;
}

- (NSMutableArray *)selectDataArr
{
    if (!_selectDataArr) {
        _selectDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectDataArr;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.创建UI
    [self setupUI];
    
    //2.加载数据
    [self loadData];
}

#pragma mark - Private

-(void)setupUI
{
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.tableView];
    
    [self.leftBtn setTitle:@"" forState:UIControlStateNormal];
    [self.leftBtn setImage:[UIImage imageNamed:@"App_back_1"] forState:UIControlStateNormal];
    
    if (self.selectDataArr.count > 0) {
        
        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送(%zd)",self.selectDataArr.count] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:RGBCOLOR(0, 202, 254)];
        [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightBtn setUserInteractionEnabled:YES];

    }else{
        
        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送"] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:RGBCOLOR(148, 240, 255)];
        [self.rightBtn setUserInteractionEnabled:NO];
    }
}

- (void)loadData
{
    //[self.ViewModel.GetGroupChartLishDataCommand ];
    WEAKSELF
    [MMRequestManager queryGroupCallBack:^(NSArray<MMGroupModel *> * _Nonnull groupList, NSError * _Nonnull error) {
        if (!error) {

            [groupList enumerateObjectsUsingBlock:^(MMGroupModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                MMCommonModel *model = [[MMCommonModel alloc] init];
                
                model.userId = obj.groupID;
                model.name = obj.name;
                model.photoUrl = @"contacts_group_icon";
                [weakSelf.dataSource addObject:model];

            }];
            
            [weakSelf.selectDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                MMCommonModel *rcMode = (MMCommonModel *)obj;
                NSString *userId = rcMode.userId;
                
                [weakSelf.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    MMCommonModel *cModel = (MMCommonModel *)obj;
                    if ([userId isEqualToString:cModel.userId]) {
                        cModel.isSelect = YES;
                    }
                    
                }];
            }];

            [weakSelf.tableView reloadData];
            
        }else{
            [MMProgressHUD showHUD: MMDescriptionForError(error)];
        }
    }];
    
}

-(void)leftAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelegate&UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    [header setBackgroundColor:RGBCOLOR(240, 240, 240)];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 40)];
    textLabel.text = @"我的群聊";
    [header addSubview:textLabel];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ForwardCell3";
    
    MMForwardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MMForwardCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.isEdit = YES;
    
    if (self.dataSource.count) {
        
        MMCommonModel *model = self.dataSource[indexPath.row];
        cell.model = model;
        
        if(model.isSelect){
            //设置选中图片
            cell.identifierImage.image = [UIImage imageNamed:@"group_selected"];
        }else {
            //设置未选中图片
            cell.identifierImage.image = [UIImage imageNamed:@"group_unSelected"];
        }

    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return G_GET_SCALE_HEIGHT(50.0f);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MMForwardCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    
    MMCommonModel *model = self.dataSource[indexPath.row];
    
    if(model.isSelect){
        
        model.isSelect = NO;
        cell.identifierImage.image = [UIImage imageNamed:@"group_unSelected"];
        [self.selectDataArr removeObject:model];
    }else {
        
        if (self.selectDataArr.count == 9) {
            //do something
            [self hintFullForward];
            return;
        }
        model.isSelect = YES;
        cell.identifierImage.image = [UIImage imageNamed:@"group_selected"];
        [self.selectDataArr addObject:model];

    }
    
    if (self.forwardDelegate && [self.forwardDelegate respondsToSelector:@selector(didSelectArr:)]) {
        [self.forwardDelegate didSelectArr:self.selectDataArr];
    }
    
    if (self.selectDataArr.count > 0) {
        
        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送(%zd)",self.selectDataArr.count] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:RGBCOLOR(0, 202, 254)];
        [self.rightBtn setUserInteractionEnabled:YES];
        
    }else{
        
        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送"] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:RGBCOLOR(148, 240, 255)];
        [self.rightBtn setUserInteractionEnabled:NO];
    }
    
}

@end
