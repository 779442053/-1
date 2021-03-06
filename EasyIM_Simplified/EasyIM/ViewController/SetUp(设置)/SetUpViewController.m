//
//  SetUpViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/22.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "SetUpViewController.h"
#import "AppDelegate.h"
#import "ZWSetUpViewModel.h"
//安全
#import "SecurityViewController.h"

//登录
#import "LoginVC.h"

//关于
#import "MMAboutViewController.h"

static CGFloat const margin_left = 14;
static CGFloat const cell_height = 46;
static CGFloat const cell_section_height = 10;
static NSString *const cell_identify = @"setup_cell_identify";

@interface SetUpViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *listTableView;
@property(nonatomic,strong) NSArray *arrListData;

@property(nonatomic,strong) UIView *footView;
@property(nonatomic,strong)  ZWSetUpViewModel*ViewModel;
@end

@implementation SetUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"设置"];
    [self showLeftBackButton];
    [self.view addSubview:self.listTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginOut:) name:appLoginOut object:nil];
}
//MARK: - 新消息通知
-(IBAction)switchChangeAction:(UISwitch *)sender{
    BOOL currentStatus = sender.isOn;
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"type"] = @"req";
    parma[@"xns"] = @"xns_user";
    parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    parma[@"cmd"] = @"ignoreBulletin";
    parma[@"timestamp"] = [MMDateHelper getNowTime];
    parma[@"bulletinIds"] = @"";

    [MMProgressHUD showHUD:currentStatus?@"已开启":@"已关闭"];
}


//MARK: -  UITableViewDataSource、UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.arrListData && [self.arrListData count] > 0) {
        return [self.arrListData count];
    }
    return 1;
}

//MARK:组头、组尾
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.arrListData && [self.arrListData count] > 0) {
        return cell_section_height;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (self.arrListData && [self.arrListData count] > 0) {
        UIView *_sectionHeadView = [BaseUIView createView:CGRectMake(0, 0, G_SCREEN_WIDTH, cell_section_height)
                                       AndBackgroundColor:G_EEF0F3_COLOR
                                              AndisRadius:NO
                                                AndRadiuc:0
                                                   AndBorderWidth:0
                                                   AndBorderColor:nil];
        return _sectionHeadView;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
//MARK:表列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrListData && [self.arrListData count] > section) {
        return [[NSArray arrayWithArray:self.arrListData[section]] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_identify];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //MARK:标题
    NSInteger tag = 1235;
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:tag];
    if (!labTitle) {
        CGFloat h = 21;
        CGFloat y = (cell_height - h) * 0.5;
        labTitle = [BaseUIView createLable:CGRectMake(margin_left, y, 80, h)
                                   AndText:nil
                              AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                AndTxtFont:[UIFont zwwNormalFont:13]
                        AndBackgroundColor:nil];
        labTitle.textAlignment = NSTextAlignmentLeft;
        
        labTitle.tag = tag;
        [cell.contentView addSubview:labTitle];
    }
    
    //新消息通知
    if (indexPath.section == 1 && indexPath.row == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UISwitch *_switch;
        if ([cell.accessoryView isKindOfClass:[UISwitch classForCoder]]) {
            _switch = (UISwitch *)cell.accessoryView;
        }
        else{
            _switch = [[UISwitch alloc] init];
            cell.accessoryView = _switch;
            [_switch addTarget:self action:@selector(switchChangeAction:) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    if (self.arrListData && [self.arrListData count] > indexPath.section) {
        NSArray *arrTemp = [NSArray arrayWithArray:self.arrListData[indexPath.section]];
        if (arrTemp && [arrTemp count] > indexPath.row) {
            
            //标题
            labTitle.text = [NSString stringWithFormat:@"%@",[arrTemp objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.arrListData && [self.arrListData count] > indexPath.section) {
        switch (indexPath.section) {
            //MARK:安全
            case 0:{
                SecurityViewController *vc = [[SecurityViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            case 1:{
                //MARK:隐私
                if (indexPath.row == 1) {
                    [MMProgressHUD showHUD:@"隐私"];
                }
                //MARK:通用
                else if (indexPath.row == 2) {
                    [MMProgressHUD showHUD:@"通用"];
                }
            }
                break;
                
            //MARK:关于
            case 2:{
                MMAboutViewController *vc = [[MMAboutViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}
//MARK: - 退出
-(IBAction)btnExitAction:(UIButton *)sender{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"是否确定退出登录?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
         parma[@"type"] = @"req";
         parma[@"xns"] = @"xns_user";
         parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
         parma[@"cmd"] = @"logout";
         parma[@"timestamp"] = [MMDateHelper getNowTime];
        [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
            //暂时不做任何处理,,,,,需要断开相关链接.回到登录界面
            [ZWUserModel currentUser].token = @"";
            [ZWUserModel currentUser].nickName = @"";
            [ZWUserModel currentUser].userName = @"";
            [ZWUserModel currentUser].userId = @"";
            [ZWUserModel currentUser].sessionID = @"";
            [ZWDataManager saveUserData];
        }];
    }];
    UIAlertAction *cancerAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:OKAction];
    [alertController addAction:cancerAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
-(void)LoginOut:(NSNotification *)notion{
    ZWWLog(@"退出IM登录成功,开始清除本地数据=回到登录界面")
    [ZWSaveTool setBool:NO forKey:@"IMislogin"];
    [ZWDataManager removeUserData];
    [ZWSocketManager DisConnectSocket];
    BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:[LoginVC new]];
    self.view.window.rootViewController  = nav;
}

//MARK: - lazy load
- (NSArray *)arrListData{
    if (!_arrListData) {
        _arrListData = @[
                         @[@"安全"],
                         @[@"新消息通知",@"隐私",@"通用"],
                         @[@"关于"]];
    }
    return _arrListData;
}

- (UITableView *)listTableView{
    if (!_listTableView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight;
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, h)
                                                      style:UITableViewStylePlain];
        _listTableView.backgroundColor = [UIColor clearColor];
        //分割线
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _listTableView.separatorColor = G_EEF0F3_COLOR;
        //是否允许选中
        _listTableView.allowsSelection = YES;
        _listTableView.allowsMultipleSelection = NO;
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _listTableView.tableFooterView = self.footView;
        //注册
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cell_identify];
    }
    return _listTableView;
}
- (UIView *)footView{
    if (!_footView) {
        _footView = [BaseUIView createView:CGRectMake(0, 0, G_SCREEN_WIDTH, 58)
                        AndBackgroundColor:G_EEF0F3_COLOR
                               AndisRadius:NO
                                 AndRadiuc:0
                            AndBorderWidth:0
                            AndBorderColor:nil];
        
        //退出
        UIButton *btn = [BaseUIView createBtn:CGRectMake(0, 12, G_SCREEN_WIDTH, 46)
                                 AndTitle:@"退出登录"
                            AndTitleColor:[UIColor colorWithHexString:@"#333333"]
                               AndTxtFont:[UIFont zwwNormalFont:13]
                                 AndImage:nil
                       AndbackgroundColor:[UIColor whiteColor]
                           AndBorderColor:nil
                          AndCornerRadius:0
                             WithIsRadius:NO
                      WithBackgroundImage:nil
                          WithBorderWidth:0];
        
        btn.showsTouchWhenHighlighted = YES;
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        [btn addTarget:self
                      action:@selector(btnExitAction:)
            forControlEvents:UIControlEventTouchUpInside];
        [_footView addSubview:btn];
    }
    return _footView;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
