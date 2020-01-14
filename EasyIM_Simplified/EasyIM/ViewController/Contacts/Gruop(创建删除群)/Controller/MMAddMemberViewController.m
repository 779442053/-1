//
//  MMAddMemberViewController.m
//  EasyIM
//
//  Created by momo on 2019/6/1.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMAddMemberViewController.h"
#import "NewGroupViewCell.h"
#import "ContactsModel.h"
#import "MMContactsViewController.h"
#import "ZWSocketManager.h"
#import "YJProgressHUD.h"
#import "MMDateHelper.h"
@interface MMAddMemberViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView     *tableView;        //表格
@property (nonatomic,   copy) NSArray         *dataSource;       //数据源
@property (nonatomic, strong) UIButton        *inviteBtn;        //邀请按钮
@property (nonatomic,strong) NSMutableArray   *selectArray;
@property (nonatomic,strong) NSMutableArray   *userIDArr;        //ID数组
@end
@implementation MMAddMemberViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:_isLinkman?@"联系人":@"邀请成员"];
    [self showLeftBackButton];
    [self.view addSubview:self.tableView];
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-77, SCREEN_WIDTH, 77)];
    bottomView.hidden = _isLinkman?YES:NO;
    [bottomView addSubview:self.inviteBtn];
    [self.view addSubview:bottomView];
}
- (void)inviteAtion:(UIButton *)sender
{
    __weak typeof(self) weakSelf = self;
    //MARK:邀请好友群音视频
    if (self.isGroupVideo || self.isGroupAudio) {
        if (!_userIDArr || [_userIDArr count] < 1) {
            [MMProgressHUD showHUD:@"请选择群成员"];
            return;
        }
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mmInvitationMemberFinish:andGroupId:andDetailsData:andIsVideo:)]) {
            // [S] 将邀请的用户具体信息携带过去，UI展示需要用到
            NSDictionary *dicData;
            NSMutableArray *muarrTemp = [NSMutableArray array];
            for (id objData in self.dataSource) {
                if ([objData isKindOfClass:[ContactsModel classForCoder]]) {
                    ContactsModel *tmodel = (ContactsModel *)objData;
                    if ([_userIDArr containsObject:tmodel.userId]) {
                        dicData = @{
                                    @"userId":tmodel.userId,
                                    @"photoUrl":tmodel.photoUrl?tmodel.photoUrl:@"",
                                    @"userName":tmodel.userName?tmodel.userName:@"",
                                    @"initiator":@(NO)
                                    };
                    }
                }
                else if([objData isKindOfClass:[MemberList classForCoder]]){
                    MemberList *tmodel = (MemberList *)objData;
                    if ([_userIDArr containsObject:tmodel.memberId]) {
                        dicData = @{
                                    @"userId":tmodel.memberId,
                                    @"photoUrl":tmodel.photoUrl?tmodel.photoUrl:@"",
                                    @"userName":tmodel.username?tmodel.username:@"",
                                    @"initiator":@(NO)
                                    };
                    }
                }
                if (dicData && ![muarrTemp containsObject:dicData]) {
                    [muarrTemp addObject:dicData];
                }
            }
            [muarrTemp addObject:@{
                                   @"userId":[ZWUserModel currentUser]?[ZWUserModel currentUser].userId:@"",
                                   @"photoUrl":[ZWUserModel currentUser]?[ZWUserModel currentUser].photoUrl:@"",
                                   @"userName":[ZWUserModel currentUser]?[ZWUserModel currentUser].userName:@"",
                                   @"initiator":@(YES)
                                   }];
            // [E] 将邀请的用户具体信息携带过去，UI展示需要用到
            [weakSelf.delegate mmInvitationMemberFinish:[_userIDArr copy]
                                             andGroupId:weakSelf.groupId
                                         andDetailsData:[muarrTemp copy]
                                             andIsVideo:weakSelf.isGroupVideo];
        }
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }
    else{
        ZWWLog(@"邀请好友加群")
        NSString *friendId = [_userIDArr componentsJoinedByString:@","];
        NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
        parma[@"cmd"] = @"inviteFrd2Group";
        parma[@"type"] = @"req";
        parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
        parma[@"friendID"] = friendId;
        parma[@"groupID"] = self.groupId;
        parma[@"timeStamp"] = [MMDateHelper getNowTime];
        [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
            if (!error) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(mmAddMemberFinish)]) {
                    [weakSelf.delegate mmAddMemberFinish];
                }
                [YJProgressHUD showSuccess:@"您已发出邀请,等待对方同意"];
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }else{
                [YJProgressHUD showError:@"邀请失败,请稍后再试"];
            }
        }];
    }
}
- (BOOL)isMembers:(NSInteger)indexPath
{
    if (self.dataSource && [self.dataSource count] > indexPath) {
        ContactsModel *model = self.dataSource[indexPath];
        if (![model isKindOfClass:[ContactsModel class]]) {
            return NO;
        }
        NSString *strUserId = [model isKindOfClass:[ContactsModel classForCoder]]?model.userId:((MemberList *)model).memberId;
        if (strUserId.checkTextEmpty) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"memberId",strUserId];
            NSArray *arrTemp = [_memberData filteredArrayUsingPredicate:predicate];
            if (arrTemp && [arrTemp count]) {
                return YES;
            }
        }
    }
    return NO;
}
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
    static NSString *cellIde = @"NewGroupViewCell";
    NewGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell==nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewGroupViewCell" forIndexPath:indexPath];
    }
    if (self.dataSource && [self.dataSource count] > indexPath.row) {
        NSString *strNickName;
        NSString *userId;
        if ([self.dataSource[indexPath.row] isKindOfClass:[ContactsModel class]] ||
            [self.dataSource[indexPath.row] isKindOfClass:[MemberList class]]) {
            ContactsModel *model = self.dataSource[indexPath.row];
            strNickName = [model isKindOfClass:[ContactsModel classForCoder]]?model.nickName:((MemberList *)model).username;
            userId = [model isKindOfClass:[ContactsModel classForCoder]]?model.userId:((MemberList *)model).memberId;
            [cell.name setText:strNickName];
            [cell.logoImage sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:K_DEFAULT_USER_PIC];
            cell.selImage.image = (model.isSelect && [self.selectArray containsObject:strNickName]) ? [UIImage imageNamed:@"group_selected"]:[UIImage imageNamed:@"group_unSelected"];
        }
        cell.delegate = (id<NewGroupViewCellDelegate>)self;
        cell.indexPath = indexPath;
        
        //MARK:群视频邀请判断
        NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
        if ((self.isGroupVideo || self.isGroupAudio) && [ZWUserModel currentUser] && [userId isEqualToString:userID]) {
            //灰色不可选择
            cell.userInteractionEnabled = NO;
            cell.name.textColor = G_EEF0F3_COLOR;
            cell.desLable.textColor = G_EEF0F3_COLOR;
            cell.selImage.image = [UIImage imageNamed:@"group_unSelected"];
        }
        //MARK:群成员邀请入群判断
        else if (((!self.isGroupVideo || self.isGroupVideo == NO) && (!self.isGroupAudio || self.isGroupAudio == NO)) && [self isMembers:indexPath.row]) {
            //灰色不可选择
            cell.userInteractionEnabled = NO;
            cell.name.textColor = G_EEF0F3_COLOR;
            cell.desLable.textColor = G_EEF0F3_COLOR;
            cell.selImage.image = [UIImage imageNamed:@"group_unSelected"];
        }
        else{
            cell.userInteractionEnabled = YES;
            cell.name.textColor = [UIColor blackColor];
            cell.desLable.textColor = [UIColor colorWithHexString:@"#7E8A8A"];
        }
    }
    cell.selImage.hidden = _isLinkman?YES:NO;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headSection = [[UIView alloc] init];
    headSection.backgroundColor = MMColor(242, 242, 242);
    UILabel *sectionLbl = [[UILabel alloc] init];
    sectionLbl.text = @"选择成员";
    sectionLbl.frame = CGRectMake(15, 0, 80, 30);
    sectionLbl.font = [UIFont systemFontOfSize:15];
    sectionLbl.textColor = [UIColor blackColor];
    [headSection addSubview:sectionLbl];
    return headSection;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
#pragma mark - NewGroupViewCellDelegate

-(void)selectCellWithSelectText:(NSString *)selectText
                       isSelect:(BOOL)isSelect
                      indexPath:(NSIndexPath *)indexPath
{
    ZWWLog(@"========%@   %d   %@",selectText,isSelect,indexPath)
    if (!self.dataSource || [self.dataSource count] <= indexPath.row) {
        MMLog(@"索引越界");
        return;
    }
    ContactsModel *model = self.dataSource[indexPath.row];
    if (![model isKindOfClass:[ContactsModel class]] && ![model isKindOfClass:[MemberList class]]) {
        ZWWLog(@"数据不合法");
        return;
    }
    NSString *userId = [model isKindOfClass:[ContactsModel classForCoder]]?model.userId:((MemberList *)model).memberId;
    //联系人
    if (_isLinkman && self.delegate && [self.delegate respondsToSelector:@selector(mmDidSelectForLinkmanId:andUserName:andNickName:andPhoto:)]) {
        ZWWLog(@"选择的账户信息=%@",model.userId)
        [self.delegate mmDidSelectForLinkmanId:model.userId
                                   andUserName:model.userName
                                   andNickName:model.nickName
                                      andPhoto:model.photoUrl];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    else if (model.isSelect && [_selectArray containsObject:selectText]) {
        model.isSelect = NO;
        ZWWLog(@"111")
        if ([self.selectArray containsObject:selectText]) {
            [self.selectArray removeObject:selectText];
            [self.userIDArr removeObject:userId];
        }
    }
    else{
        ZWWLog(@"群视频邀请人数限制或者邀请好友入群")
        if (self.isGroupVideo && [self.selectArray count] >= CALL_VEDIO1VM_MAX) {
            [MMProgressHUD showHUD:[NSString stringWithFormat:@"群视频一次最多邀请%d人",CALL_VEDIO1VM_MAX]];
            return;
        }
        model.isSelect = YES;
        if (![self.selectArray containsObject:selectText]) {
            [self.selectArray addObject:selectText];
            [self.userIDArr addObject:userId];
        }
    }
    if (self.selectArray.count >= 1) {
        self.inviteBtn.enabled = YES;
        [_inviteBtn setBackgroundColor:MMColor(71, 186, 254)];
    }else {
        self.inviteBtn.enabled = NO;
        [_inviteBtn setBackgroundColor:[UIColor grayColor]];
    }
    [self.tableView reloadData];
}
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT-ZWStatusAndNavHeight - ZWTabbarSafeBottomMargin) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = G_EEF0F3_COLOR;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = MMColor(242, 242, 242);
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[NewGroupViewCell class] forCellReuseIdentifier:@"NewGroupViewCell"];
    }
    return _tableView;
}
- (NSArray *)dataSource
{
    if (!_dataSource) {
        if (self.isGroupVideo || self.isGroupAudio)
            _dataSource = self.memberData;
        else
           _dataSource = [MMContactsViewController shareInstance].arrData;
    }
    return _dataSource;
}
- (UIButton *)inviteBtn
{
    if (!_inviteBtn) {
        _inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_inviteBtn setTitle:self.isGroupVideo?@"立即发起":@"立即邀请" forState:UIControlStateNormal];
        [_inviteBtn setBackgroundColor:[UIColor grayColor]];
        [_inviteBtn setFrame:CGRectMake(20, 16, SCREEN_WIDTH-2*20, 45)];
        [_inviteBtn setEnabled:NO];
        [_inviteBtn.layer setCornerRadius:22.5];
        [_inviteBtn.layer setMasksToBounds:YES];
        [_inviteBtn addTarget:self action:@selector(inviteAtion:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _inviteBtn;
}
-(NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}
-(NSMutableArray *)userIDArr
{
    if (!_userIDArr) {
        _userIDArr = [[NSMutableArray alloc] init];
    }
    return _userIDArr;
}
@end
