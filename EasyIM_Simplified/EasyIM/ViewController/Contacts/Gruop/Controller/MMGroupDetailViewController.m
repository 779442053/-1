//
//  MMGroupDetailViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/26.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMGroupDetailViewController.h"

//View
//#import "UserInfoNavView.h"
#import "MMMemberCell.h"
#import "GroupMemberModel.h"

//创建UI
#import "BaseUIView.h"
#import "MMChatHandler.h"

//ViewController
#import "MMAddMemberViewController.h"
#import "MMEditGroupViewController.h"

//二维码
#import "QRCodeViewController.h"
#import "ZWGroudDetailViewModel.h"
static const NSInteger max_cell = 4;
static const CGFloat foot_view_h = 62;

@interface MMGroupDetailViewController ()<UITableViewDelegate,UITableViewDataSource,AddGroupMemberDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,MMEditGroupViewControllerDelegate,MMAddMemberViewControllerDelegate>

@property (nonatomic, strong) UITableView        *tableView;     //表格
@property (nonatomic, strong) NSMutableArray     *dataSource;    //数据源

////////////////////////////////////////////////////////////////////////
//@property (nonatomic, strong) UserInfoNavView    *infoView;      //表头
@property (nonatomic, strong) UIButton           *btnGroupQrCode;//群二维码

////////////////////////////////////////////////////////////////////////
@property (nonatomic, strong) UIView *footView;
@property (nonatomic, strong) ZWGroudDetailViewModel *viewModel;
@end

@implementation MMGroupDetailViewController{
    UIImage *_selectImg;
}

#pragma mark - Getter
-(ZWGroudDetailViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[ZWGroudDetailViewModel alloc]init];
    }
    return _viewModel;
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT - ZWStatusAndNavHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = G_EEF0F3_COLOR;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = self.footView;
        //_tableView.tableHeaderView = self.infoView;//设置表头
    }
    return _tableView;
}

//- (UserInfoNavView *)infoView
//{
//    if (!_infoView) {
//        _infoView = [[UserInfoNavView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
//        _infoView.navController = self.navigationController;
//        _infoView.backgroundColor = [UIColor whiteColor];
//        _infoView.userName = _name;
//        _infoView.userDetail = _groupId;
//        _infoView.isHideRightBtn = YES;
//        _infoView.deletgate = (id<MMRightActionDeltegate>)self;
//
//        //MARK:群二维码
//        [_infoView addSubview:self.btnGroupQrCode];
//    }
//    return _infoView;
//}

-(UIButton *)btnGroupQrCode{
    if (!_btnGroupQrCode) {
        CGFloat w = 44;
        CGFloat h = 44;
        CGFloat x = G_SCREEN_WIDTH - w - 20;
        CGFloat y = ISIphoneX?44:20;
        
        _btnGroupQrCode = [BaseUIView createBtn:CGRectMake(x, y, w, h)
                                       AndTitle:nil
                                  AndTitleColor:nil
                                     AndTxtFont:nil
                                       AndImage:[UIImage imageNamed:@"setting_erweima_icon_white"]
                             AndbackgroundColor:nil
                                 AndBorderColor:nil
                                AndCornerRadius:0
                                   WithIsRadius:NO
                            WithBackgroundImage:nil
                                WithBorderWidth:0];
        
        [_btnGroupQrCode addTarget:self action:@selector(btnGroupAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnGroupQrCode;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

-(UIView *)footView{
    if (!_footView) {
        _footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, foot_view_h)];
        _footView.backgroundColor = [UIColor clearColor];
        
        //如果群的创建ID等于用户ID 则为群主 权利是解散该群 不是则有退出该群
        if ([self.creatorId isEqualToString:[ZWUserModel currentUser].userId]) {
            UIButton *disbandedGroup = [UIButton  buttonWithType:UIButtonTypeCustom];
            disbandedGroup.backgroundColor = [UIColor redColor];
            [disbandedGroup setTitle:@"解散该群" forState:UIControlStateNormal];
            [disbandedGroup setFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 44)];
            [disbandedGroup.layer setMasksToBounds:YES];
            [disbandedGroup.layer setCornerRadius:22];
            [disbandedGroup addTarget:self action:@selector(disbandedGroupAction:) forControlEvents:UIControlEventTouchUpInside];
            [_footView addSubview:disbandedGroup];
        }
        else{
            UIButton *exitGroup = [UIButton  buttonWithType:UIButtonTypeCustom];
            exitGroup.backgroundColor = [UIColor redColor];
            [exitGroup setTitle:@"退出该群" forState:UIControlStateNormal];
            [exitGroup setFrame:CGRectMake(20, 0, SCREEN_WIDTH-40, 44)];
            [exitGroup.layer setMasksToBounds:YES];
            [exitGroup.layer setCornerRadius:22];
            [exitGroup addTarget:self action:@selector(exitGroupAction:) forControlEvents:UIControlEventTouchUpInside];
            
            [_footView addSubview:exitGroup];
        }
    }
    
    return _footView;
}


#pragma mark - Init
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.初始化UI
    [self setupUI];
    
    //2.加载数据(请求数据)
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    //设置导航栏背景图片为一个空的image,这样就透明了
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    //去掉透明后导航栏下边的黑边
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


#pragma mark - Private

- (void)setupUI
{
    //添加表格
    [self.view addSubview:self.tableView];
}


//MARK: - 加载数据
- (void)loadData
{
     NSDictionary *dicData = @{
                                 @"groupid":self.groupId,
                                 @"page":@"0",//第一页0
                                 @"perpage":@"100"
                                 };
    [[self.viewModel.getGroupPeopleListCommand execute:dicData]subscribeNext:^(NSDictionary *x) {
        if ([x[@"code"] intValue] == 0) {
            NSArray<MemberList *> *memberList = [MemberList mj_objectArrayWithKeyValuesArray:x[@"res"]];
            [self.dataSource addObjectsFromArray:memberList];
            if ([[x allValues] containsObject:@"cid"]) {
                self.creatorId = x[@"cid"];
            }
            [self.tableView reloadData];
        }
    }];
}


//MARK: - 解散该群
- (void)disbandedGroupAction:(UIButton *)sender
{
    
   
    
}


//MARK: - 退出该群
- (void)exitGroupAction:(UIButton *)sender
{
    [[self.viewModel.exitGroupWithGroupid execute:@{@"groupid":self.groupId,@"msg":@"为啥推出啊?"}] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];

}


//MARK: - 群二维码
-(IBAction)btnGroupAction:(UIButton *)sender{
    QRCodeViewController *qrcodeVC = [[QRCodeViewController alloc]
                                      initWithType:1
                                      AndFromId:self.groupId
                                      AndFromName:self.name
                                      WithFromPic:nil];
    [self.navigationController pushViewController:qrcodeVC animated:YES];
}
//MARK: - 设置群背景图
-(void)setGroupChatBg:(NSString * _Nonnull)strUrlBg{
    
    NSDictionary *dicParams = @{
                                @"cmd":@"SetGroupBackground",
                                @"sessionId":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                                @"groupid":self.groupId,
                                @"background":strUrlBg
                                };
    
    __weak typeof(self) weakSelf = self;
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API
                         parameters:dicParams
                            success:^(id  _Nonnull responseObject) {
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUDForView:weakSelf.view];
                                });

                                if (responseObject && K_APP_REQUEST_OK(responseObject[K_APP_REQUEST_CODE])) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MBProgressHUD showSuccess:@"群聊背景图设置成功!"];
                                    });
                                   
                                    //设置成功回调
                                    MMLog(@"群聊背景图设置成功!详见：{strUrlBg:%@}",strUrlBg);
                                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mmGroupDetailsSetBackgroundSuccess:andImage:)]) {
                                        [weakSelf.delegate mmGroupDetailsSetBackgroundSuccess:strUrlBg
                                                                                     andImage:_selectImg];
                                    }
                                }
                                else{
                                    NSLog(@"群聊背景图设置失败！详见：%@",responseObject[K_APP_REQUEST_MSG]);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MBProgressHUD showError:responseObject[K_APP_REQUEST_MSG]];
                                    });
                                }
                            }
                            failure:^(NSError * _Nonnull error) {
                                NSLog(@"群聊背景图设置异常！详见：%@",error);
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MBProgressHUD hideHUDForView:weakSelf.view];
                                    [MBProgressHUD showError:error.localizedDescription];
                                });
                            }];
}


//MARK: - 消息免打扰设置
-(IBAction)switchChangeAction:(UISwitch *)sender{
    BOOL currentStatus = sender.isOn;
   
    //0 不启用消息 开启免打扰，1 启用接收消息,关闭免打扰
    NSString *_notify = currentStatus?@"0":@"1";
    
    NSDictionary *dicParams = @{
                                @"cmd":@"SetUserGroupNotify",
                                @"sessionId":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                                @"groupid":self.groupId,
                                @"nofity":_notify
                                };
    
    __block typeof(self) blockSelf = self;
    __weak typeof(self) weakSelf = self;
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API
                         parameters:dicParams
                            success:^(id  _Nonnull responseObject) {
                                if (responseObject && K_APP_REQUEST_OK(responseObject[K_APP_REQUEST_CODE])) {
                                    blockSelf.notify = _notify;
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MMProgressHUD showHUD:[NSString stringWithFormat:@"%@消息免打扰",currentStatus ? @"已开启":@"已关闭"]];
                                    });
                                    
                                    [weakSelf updateNotice:currentStatus];
                                }
                                else{
                                    NSLog(@"消息免打扰设置失败！详见：%@",responseObject[K_APP_REQUEST_MSG]);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MMProgressHUD showError:responseObject[K_APP_REQUEST_MSG]];
                                    });
                                }
                            }
                            failure:^(NSError * _Nonnull error) {
                                NSLog(@"消息免打扰设置异常！详见：%@",error);
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MMProgressHUD showError:error.localizedDescription];
                                });
                            }];
}

-(void)updateNotice:(BOOL)currentStatus{
    //开启群免打扰，接受消息时，不播放提示音和振动
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (currentStatus) {
            [[NSUserDefaults standardUserDefaults] setObject:[ZWUserModel currentUser]?[ZWUserModel currentUser].userId:@"" forKey:self.groupId];
        }
        else{
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:self.groupId];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    });
}


#pragma mark - UITableViewDelegateAndUITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (section) {
        case 0:
            return 2;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 2;
            break;
            
        default:
            return 0;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        return 86.0f;
    }else{
        return 44.0f;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0 && indexPath.row == 1) {
        MMMemberCell *mCell = [[MMMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mCell"];
        mCell.selectionStyle = UITableViewCellSelectionStyleNone;
        mCell.delegate = (id<AddGroupMemberDelegate>) self;
        if (self.dataSource.count > max_cell) {
            mCell.memberList = [self.dataSource subarrayWithRange:NSMakeRange(0, max_cell)].mutableCopy;
        }else{
            mCell.memberList = self.dataSource;
        }
        return mCell;
    }
    
    static NSString *identifier = @"groupDetailCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"群聊成员";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"共%ld人",(long)self.dataSource.count];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"管理群";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
            break;
        case 2:
        {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"设置聊天背景";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            //MARK:消息免打扰
            else if(indexPath.row == 1){
                cell.textLabel.text = @"消息免打扰";
                
                UISwitch *_switch;
                if ([cell.accessoryView isKindOfClass:[UISwitch classForCoder]]) {
                    _switch = (UISwitch *)cell.accessoryView;
                }
                else{
                    _switch = [[UISwitch alloc] init];
                    cell.accessoryView = _switch;
                    [_switch addTarget:self action:@selector(switchChangeAction:) forControlEvents:UIControlEventValueChanged];
                }
                
                /** notify — 0 不启用消息 开启免打扰，1 启用接收消息,关闭免打扰 */
                self.notify = !self.notify.checkTextEmpty?@"1":self.notify;
                BOOL isSwitch = ![self.notify boolValue];
                [_switch setOn:isSwitch];
                [self updateNotice:isSwitch];
                
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
            break;

        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        return 8.0f;
    }
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section != 0) {
        UIView *sectionView = [[UIView alloc] init];
        sectionView.backgroundColor = MMColor(242, 242, 242);
        return sectionView;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
        {
            if (self.dataSource.count > 9 ) {
                return 30;
            }else{
                return 0;
            }
        }
            break;
        case 1:
            
            break;
        case 2:
        {
            return 150.0f;
        }
            break;
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //MARK:群管理
    if (indexPath.section == 1) {
        MMEditGroupViewController *editGroup = [[MMEditGroupViewController alloc] init];
        editGroup.dataSource  = [self.dataSource mutableCopy];
        editGroup.groupId = self.groupId;
        editGroup.creatorId = self.creatorId;
        editGroup.deleget = (id<MMEditGroupViewControllerDelegate>)self;
        
        [self.navigationController pushViewController:editGroup animated:YES];
    }
    else if(indexPath.section == 2){
        //MARK:设置聊天背景
        if (indexPath.row == 0) {
            
            //群主才修改背景
            if (!self.creatorId.checkTextEmpty || ![self.creatorId isEqualToString:[ZWUserModel currentUser].userId]) {
                 [MMProgressHUD showHUD:@"非群主无法设置群聊背景"];
                return;
            }
            
            __block typeof(self) weakSelf = self;
            [BaseUIView createPhotosAndCameraPickerForMessage:@"选择群聊天背景图"
                                           andAlertController:^(UIAlertController * _Nullable _alertVC) {
                                               [weakSelf presentViewController:_alertVC animated:YES completion:nil];
                                           }
                                    withImagePickerController:^(UIImagePickerController * _Nullable _imgPickerVC) {
                                        _imgPickerVC.delegate = self;
                                        [weakSelf presentViewController:_imgPickerVC animated:YES completion:nil];
                                    }];
        }
    }
}


//MARK: - UIImagePickerControllerDelegate
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    MMLog(@"已取消操作");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *tmpImg = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (picker.isEditing)
        tmpImg = [info objectForKey:UIImagePickerControllerEditedImage];
    _selectImg = [UIImage imageWithData:[YHUtils zipNSDataWithImage:tmpImg]];
    
    if (!_selectImg) {
        [MBProgressHUD showError:@"图片不存在，请重新设置"];
        return;
    }
    
    //[S] 图片上传
    NSString *filePath = [[MMMediaManager sharedManager] saveImage:_selectImg];
    
    __weak typeof(self) weakSelf = self;
    [MBProgressHUD showMessage:@"上传中..." toView:self.view];
    
    [[MMChatHandler shareInstance] getUrl:filePath completion:^(NSString * _Nonnull url) {
        [MMFileTool removeFileAtPath:filePath];//上传文件失败成功都要删除本地文件
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view];
        });
        
        if (url.checkTextEmpty) {
            MMLog(@"图片上传成功！详见：%@",url);
            [weakSelf setGroupChatBg:url];
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD showError:@"上传失败"];
            });
        }
    }];
    //[E] 图片上传
}


#pragma mark - MMRightActionDeltegate
-(void)rightAction:(UIButton *)sender
{
    //编辑群
    MMLog(@"编辑群");
}


//MARK: - MMEditGroupViewControllerDelegate(移除群组成员回调)
-(void)mmEditGroupRemoveMemberSuccess:(MemberList *)member{
    if (member && self.dataSource) {
        [self.dataSource removeObject:member];
        
        [self.tableView reloadData];
    }
}

#pragma mark - AddGroupMemberDelegate(邀请好友)
- (void)addGroupMemberWithGesR:(UIGestureRecognizer *)gesture
{
    //2、点击邀请好友
    MMAddMemberViewController *addMember = [[MMAddMemberViewController alloc] init];
    addMember.memberData = [self.dataSource copy];
    addMember.isGroupVideo = NO;
    addMember.isGroupAudio = NO;
    addMember.groupId = self.groupId;
    addMember.creatorId = self.creatorId;
    addMember.delegate = (id<MMAddMemberViewControllerDelegate>)self;
    
    [self.navigationController pushViewController:addMember animated:YES];
}


//MARK: - MMAddMemberViewControllerDelegate
-(void)mmAddMemberFinish{
    NSLog(@"邀请好友入群，回调刷新");
    if (self.dataSource) {
        [self.dataSource removeAllObjects];
    }
    
    [self loadData];
}

@end