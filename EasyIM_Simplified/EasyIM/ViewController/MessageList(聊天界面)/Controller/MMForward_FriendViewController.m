//
//  MMForward_FriendViewController.m
//  EasyIM
//
//  Created by momo on 2019/7/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMForward_FriendViewController.h"
#import "MMContactsViewController.h"

@interface MMForward_FriendViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *selectDataArr;

@end

@implementation MMForward_FriendViewController

- (instancetype)initWithSelectDataArr:(NSArray *)dataArr
{
    self = [super init];
    if (self) {
        [self.selectDataArr addObjectsFromArray:dataArr];
    }
    
    return self;
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

    NSArray *frdArr = [MMContactsViewController shareInstance].arrData;
    
    [frdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj isKindOfClass:[ContactsModel class]]) {
            ContactsModel *cModel = (ContactsModel *)obj;
            MMCommonModel *model = [[MMCommonModel alloc] init];
            
            model.userId = cModel.userId;
            model.name = cModel.remarkName.length ? cModel.remarkName : cModel.nickName;
            model.photoUrl = cModel.photoUrl;
            [self.dataSource addObject:model];
        }
    }];
    
    
    [self.selectDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MMCommonModel *rcMode = (MMCommonModel *)obj;
        NSString *userId = rcMode.userId;
        
        [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            MMCommonModel *cModel = (MMCommonModel *)obj;
            if ([userId isEqualToString:cModel.userId]) {
                cModel.isSelect = YES;
            }
            
        }];
    }];
    
    
    [self.tableView reloadData];
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
    textLabel.text = @"我的好友";
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
    
    MMCommonModel *cModel = self.dataSource[indexPath.row];
    
    if(cModel.isSelect){
        cell.identifierImage.image = [UIImage imageNamed:@"group_unSelected"];
        cModel.isSelect = NO;
        [self.selectDataArr removeObject:cModel];
    }else {
        
        if (self.selectDataArr.count == 9) {
            //do something
            [self hintFullForward];
            return;
        }
        
        cModel.isSelect = YES;
        cell.identifierImage.image = [UIImage imageNamed:@"group_selected"];
        [self.selectDataArr addObject:cModel];

    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectArr:)]) {
        [self.delegate didSelectArr:self.selectDataArr];
    }
    
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

@end
