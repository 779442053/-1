//
//  MeViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/20.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MeViewController.h"

//二维码
#import "QRCodeViewController.h"

//我的钱包
#import "MMMyWalletViewController.h"

//个人资料
#import "MMProfileViewController.h"

//扫一扫
#import "SweepViewController.h"

//设置
#import "SetUpViewController.h"
#import "ZWMeViewModel.h"
static CGFloat const margin_left = 19;
static CGFloat const cell_height = 46;
static CGFloat const cell_section_height = 10;
static NSString *const cell_identify = @"contact_cell_identify";

static CGFloat const head_view_height = 106;

static NSString *const k_data_pic = @"pic";
static NSString *const k_data_name = @"name";

#define NAVTINTCOLOR [UIColor blackColor];

@interface MeViewController ()<UITableViewDelegate,UITableViewDataSource,SweepViewControllerDelegate>

@property(nonatomic,strong) UITableView *listTableView;
@property(nonatomic,strong) NSArray *arrListData;

//////////////////////////////////////////////////////
@property(nonatomic,strong) UIView *headView;
@property(nonatomic,strong) UIView *headContentView;

@property(nonatomic,strong) UIButton *btnPic;
@property(nonatomic,strong) UILabel  *labUserName;
@property(nonatomic,strong) UILabel  *labAccount;
@property(nonatomic,strong) UIButton *btnQRcode;
@property(nonatomic,strong) ZWMeViewModel *ViewModel;
@end
@implementation MeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"我"];
}
-(void)zw_addSubviews{
    [self.view addSubview:self.listTableView];
}
-(void)zw_bindViewModel{
    [[self.ViewModel.getMyUserInfoCommand execute:[ZWUserModel currentUser].userId] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            self.labUserName.text = [ZWUserModel currentUser].nickName;
            self.labAccount.text = [NSString stringWithFormat:@"账号:%@",[ZWUserModel currentUser].userId];
            [self.btnPic sd_setImageWithURL:[ZWUserModel currentUser].photoUrl.mj_url
                    forState:UIControlStateNormal
            placeholderImage:K_DEFAULT_USER_PIC];
        }
    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([ZWUserModel currentUser].photoUrl.checkTextEmpty) {
        [self.btnPic sd_setImageWithURL:[ZWUserModel currentUser].photoUrl.mj_url
                               forState:UIControlStateNormal
                       placeholderImage:K_DEFAULT_USER_PIC];
    }
}
//获取列数据
-(NSArray *_Nullable)getListCellForSection:(NSInteger)section{
    if (self.arrListData && [self.arrListData count] > section) {
        NSArray *arrTemp = self.arrListData[section];
        return arrTemp;
    }
    return nil;
}
- (UIView *)createSectionHeadViewForTitle:(NSString *_Nullable)strTitle{
    UIView *_sectionHeadView = [BaseUIView createView:CGRectMake(0, 0, G_SCREEN_WIDTH, cell_section_height)
                                   AndBackgroundColor:[UIColor colorWithHexString:@"#EFEFF4"]
                                          AndisRadius:NO
                                            AndRadiuc:0
                                       AndBorderWidth:0
                                       AndBorderColor:nil];
    
    //标题
    if (strTitle) {
        CGFloat w = 50;
        CGFloat h = 21;
        CGFloat y = (cell_section_height - h) * 0.5;
        UILabel *labTitle = [BaseUIView createLable:CGRectMake(17, y, w, h)
                                            AndText:strTitle
                                       AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                         AndTxtFont:[UIFont zwwNormalFont:13]
                                 AndBackgroundColor:nil];
        labTitle.textAlignment = NSTextAlignmentLeft;
        [_sectionHeadView addSubview:labTitle];
    }
    
    return _sectionHeadView;
}

-(void)btnShowAction:(UIButton *)sender{
    MMProfileViewController *vc = [[MMProfileViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
-(void)btnMineQrCodeAction:(UIButton *)sender{

    QRCodeViewController *codeVC = [[QRCodeViewController alloc]
                                    initWithType:0
                                    AndFromId:[ZWUserModel currentUser].userId
                                    AndFromName:[ZWUserModel currentUser].nickName
                                    WithFromPic:[ZWUserModel currentUser].photoUrl];
    
    [self.navigationController pushViewController:codeVC animated:YES];
}

-(void)sweepViewDidFinishSuccess:(id)sweepResult
{
    NSString *strInfo = [NSString stringWithFormat:@"%@",sweepResult];
    MMLog(@"扫描成功，详见：%@",sweepResult);
    NSArray *arrTemp = [strInfo componentsSeparatedByString:@"://"];
    NSString *strId = [NSString stringWithFormat:@"%@",arrTemp.lastObject];
    if (!strId.checkTextEmpty) {
        [MMProgressHUD showHUD:@"信息不存在"];
        return;
    }
    if ([strInfo containsString:K_APP_QRCODE_USER]) {
        if ([strId isEqualToString:[ZWUserModel currentUser].userId]) {
            [MMProgressHUD showHUD:@"不能添加自己为好友"];
            return;
        }
        [[self.ViewModel.addFriendCommand execute:strId] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [MMProgressHUD showHUD: @"添加好友申请发送成功"];
            }
        }];
    }
    //MARK:扫码加群
    else if([strInfo containsString:K_APP_QRCODE_GROUP]){
        [[self.ViewModel.add2GroupCommand execute:strId] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [MMProgressHUD showHUD: @"入群申请发送成功"];
            }
        }];
        [MMRequestManager inviteFrd2GroupWithGroupId:strId
                                            friendId:[ZWUserModel currentUser].userId
                                         aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
                                             if (K_APP_REQUEST_OK(dic[K_APP_REQUEST_CODE])) {
                                                 [MMProgressHUD showHUD:@"入群申请发送成功"];
                                             }else{
                                                 [MMProgressHUD showHUD:error?MMDescriptionForError(error):dic[K_APP_REQUEST_MSG]];
                                             }
                                         }];
    }
}

-(void)sweepViewDidFinishError
{
    [YJProgressHUD showError:@"扫描失败"];
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
    
    if (self.arrListData && [self.arrListData count] > section) {
        return [self createSectionHeadViewForTitle:nil];
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

//MARK:表列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrTemp = [self getListCellForSection:section];
    if (arrTemp) return [arrTemp count];
    
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
    
    //MARK:图像
    NSInteger tag = 1234;
    UIImageView *imgPic = (UIImageView *)[cell.contentView viewWithTag:tag];
    if (!imgPic) {
        CGFloat w = 17;
        CGFloat h = 17;
        CGFloat y = (cell_height - h) * 0.5;
        imgPic = [BaseUIView createImage:CGRectMake(margin_left, y, w, h)
                                AndImage:kDefaultPic
                      AndBackgroundColor:nil
                               AndRadius:NO
                             WithCorners:0];
        
        imgPic.tag = tag;
        [cell.contentView addSubview:imgPic];
    }
    
    //MARK:标题
    tag = 1235;
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:tag];
    if (!labTitle) {
        CGFloat h = 21;
        CGFloat x = imgPic.width + imgPic.x + 13;
        CGFloat y = (cell_height - h) * 0.5;
        labTitle = [BaseUIView createLable:CGRectMake(x, y, 80, h)
                                   AndText:nil
                              AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                AndTxtFont:[UIFont zwwNormalFont:13]
                        AndBackgroundColor:nil];
        labTitle.textAlignment = NSTextAlignmentLeft;
        
        labTitle.tag = tag;
        [cell.contentView addSubview:labTitle];
    }
    
    NSArray *arrTemp = [self getListCellForSection:indexPath.section];
    if (arrTemp && [arrTemp count] > indexPath.row){
        NSDictionary *dicCellData = arrTemp[indexPath.row];
        
        //图像赋值
        NSString *strInfo = [NSString stringWithFormat:@"%@",dicCellData[k_data_pic]];
        imgPic.image = [UIImage imageNamed:strInfo];
        
        //标题
        labTitle.text = dicCellData[k_data_name];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.arrListData && [self.arrListData count] > indexPath.section) {
        
        if (indexPath.section == 0) {
            //MARK:扫一扫
            if (indexPath.row == 0) {
                SweepViewController *vc = [[SweepViewController alloc] init];
                vc.delegate = self;
                vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                [self presentViewController:vc animated:YES completion:nil];
            }
            //MARK:我的钱包
            else if (indexPath.row == 1){
                MMMyWalletViewController *vc = [[MMMyWalletViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else if(indexPath.section == 1){
            //MARK:设置
            if (indexPath.row == 0) {
                SetUpViewController *vc = [[SetUpViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            //MARK:帮助
            else if(indexPath.row == 1){
                
            }
        }
    }
}


//MARK: - lazy load
- (NSArray *)arrListData{
    if (!_arrListData) {
        _arrListData = @[
                         @[
                             @{k_data_pic:@"mine_sao",k_data_name:@"扫一扫"},
                             @{k_data_pic:@"mine_wallet",k_data_name:@"我的钱包"}
                             ],
                         @[
                           @{k_data_pic:@"mine_set",k_data_name:@"设置"},
                           @{k_data_pic:@"mine_help",k_data_name:@"帮助"}]
                            ];
    }
    return _arrListData;
}
- (UITableView *)listTableView{
    if (!_listTableView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight - ZWTabbarHeight;
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
        _listTableView.tableHeaderView = self.headView;
        _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        //注册
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cell_identify];
    }
    return _listTableView;
}
- (UIView *)headView{
    if (!_headView) {
        _headView = [BaseUIView createView:CGRectMake(0, 0, G_SCREEN_WIDTH, head_view_height)
                        AndBackgroundColor:G_EEF0F3_COLOR
                               AndisRadius:NO
                                 AndRadiuc:0
                            AndBorderWidth:0
                            AndBorderColor:nil];
        [_headView addSubview:self.headContentView];
    }
    return _headView;
}
- (UIView *)headContentView{
    if (!_headContentView) {
        CGRect rect = _headView.bounds;
        rect.origin.y = 22;
        rect.size.height -= 22;
        _headContentView = [BaseUIView createView:rect
                               AndBackgroundColor:[UIColor whiteColor]
                                      AndisRadius:NO
                                        AndRadiuc:0
                                   AndBorderWidth:0
                                   AndBorderColor:nil];
        //MARK:图像
        [_headContentView addSubview:self.btnPic];
        //MARK:用户名
        [_headContentView addSubview:self.labUserName];
        //MARK:账号
        [_headContentView addSubview:self.labAccount];
        //MARK:二维码
        [_headContentView addSubview:self.btnQRcode];
    }
    return _headContentView;
}
- (UIButton *)btnPic{
    if (!_btnPic) {
        CGFloat w = 52;
        CGFloat h = 53;
        CGFloat y = (_headContentView.height - h) * 0.5;
        _btnPic = [BaseUIView createBtn:CGRectMake(margin_left, y, w, h)
                               AndTitle:nil
                          AndTitleColor:nil
                             AndTxtFont:nil
                               AndImage:nil
                     AndbackgroundColor:nil
                         AndBorderColor:nil
                        AndCornerRadius:3
                           WithIsRadius:YES
                    WithBackgroundImage:K_DEFAULT_USER_PIC
                        WithBorderWidth:0];
        [_btnPic addTarget:self
                    action:@selector(btnShowAction:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnPic;
}
- (UILabel *)labUserName{
    if (!_labUserName) {
        CGFloat x = _btnPic.x + _btnPic.width + 8;
        _labUserName = [BaseUIView createLable:CGRectMake(x, _btnPic.y, 160, 21)
                                       AndText:[ZWUserModel currentUser].nickName
                                  AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                    AndTxtFont:[UIFont zwwNormalFont:13]
                            AndBackgroundColor:nil];
        
        _labUserName.textAlignment = NSTextAlignmentLeft;
    }
    return _labUserName;
}

- (UILabel *)labAccount{
    if (!_labAccount) {
        CGFloat y = _btnPic.y + _btnPic.height - 21;
        _labAccount = [BaseUIView createLable:CGRectMake(_labUserName.x, y, 160, 21)
                                       AndText:[NSString stringWithFormat:@"账号：%@",[ZWUserModel currentUser].userId]
                                  AndTextColor:[UIColor colorWithHexString:@"#999999"]
                                    AndTxtFont:[UIFont zwwNormalFont:13]
                            AndBackgroundColor:nil];
        
        _labAccount.textAlignment = NSTextAlignmentLeft;
    }
    return _labAccount;
}

- (UIButton *)btnQRcode{
    if (!_btnQRcode) {
        CGFloat w = 44;
        CGFloat h = 44;
        CGFloat x = G_SCREEN_WIDTH - w - margin_left;
        CGFloat y = (_headContentView.height - h) * 0.5;
        _btnQRcode = [BaseUIView createBtn:CGRectMake(x, y, w, h)
                                  AndTitle:@"   >"
                             AndTitleColor:[UIColor lightGrayColor]
                                AndTxtFont:[UIFont zwwNormalFont:13]
                                  AndImage:[UIImage imageNamed:@"mine_qrcode"]
                        AndbackgroundColor:nil
                            AndBorderColor:nil
                           AndCornerRadius:0
                              WithIsRadius:NO
                       WithBackgroundImage:nil
                           WithBorderWidth:0];
        
        [_btnQRcode addTarget:self
                       action:@selector(btnMineQrCodeAction:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnQRcode;
}
-(ZWMeViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWMeViewModel alloc]init];
    }
    return _ViewModel;
}
@end
