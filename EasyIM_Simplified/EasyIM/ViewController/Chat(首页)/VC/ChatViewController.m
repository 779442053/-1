//
//  ChatViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/20.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ChatViewController.h"
#import "MMChatManager.h"
#import "KinTabBarController.h"
#import "ContactTableViewCell.h"
//添加好友
#import "SearchFriendsViewController.h"
#import "ZWAddFriendViewController.h"
#import "AddFriViewController.h"

#import "AddFriendStatusViewController.h"
#import "MMTools.h"
//相册
#import <Photos/Photos.h>
//群聊
#import "NewGroupViewController.h"
//下拉菜单列表
#import <YBPopupMenu.h>
//扫一扫
#import "SweepViewController.h"
#import "ZWChatViewModel.h"
#import "LoginVC.h"
#import "NewFriendModel.h"
static NSString *const identifier = @"ContactTableViewCell";
@interface ChatViewController ()<UITableViewDelegate,UITableViewDataSource,MMChatManager,YBPopupMenuDelegate,SweepViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray *laterPersonDataArr;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZWChatViewModel *ViewModel;
@property(nonatomic,strong)NSMutableArray *pushListARR;
@end
@implementation ChatViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    //if (ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].sessionID)) {
        [[self.ViewModel.socketContactCommand execute:nil] subscribeNext:^(id  _Nullable x) {
            if ([x intValue] == 0) {
                //[YJProgressHUD showSuccess:@"连接成功"];
            }else{
                [YJProgressHUD showError:@"Tcp连接失败"];
            }
        }];
//    }else{
//        ZWWLog(@"登录的时候,已经进行了登录IMw服务器操作啦\n登录的时候,已经进行了登录IMw服务器操作啦 ")
//    }
    
}
-(ZWChatViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWChatViewModel alloc]init];
    }
    return _ViewModel;
}
-(void)zw_bindViewModel{
    //获取最近的通知
    [[self.ViewModel.GetPushdataCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [self.pushListARR addObjectsFromArray:x[@"res"]];
            if (self.pushListARR.count) {
                KinTabBarController *tabbar = (KinTabBarController *)self.tabBarController;
                if (tabbar) {
                    if (self.pushListARR.count > 0) {
                        [tabbar showBadgeOnItemIndex:1 withValue:self.pushListARR.count];
                    }
                    else{
                        [tabbar hideBadgeOnItemIndex:1];
                    }
                }
            }
            MMRecentContactsModel *model = [[MMRecentContactsModel alloc]init];
            model.unReadCount = self.pushListARR.count;
            model.latestMsgStr = [NSString stringWithFormat:@"您有%lu条未读通知消息",(unsigned long)self.pushListARR.count];
            model.latestnickname = @"通知消息";
            model.latestHeadImage = @"tongzhi";
            NewFriendModel *notifionModel = self.pushListARR.lastObject;
            model.latestMsgTimeStamp = [notifionModel.time longLongValue];
            [self.laterPersonDataArr insertObject:model atIndex:0];
            [self.tableView reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:IMPushData object:self.pushListARR];
        }else if ([x[@"code"] intValue] == 2){
            LoginVC *login = [[LoginVC alloc]init];
            BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:login];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            return ;
        }
    }];
}
-(void)zw_addSubviews{
    [self.view addSubview:self.tableView];
    //2.注册通知
    [self registerNotic];
    //3.设置成当前的VC
    [MMClient sharedClient].chatListViewC = self;
    [[MMClient sharedClient] addDelegate:self];
    [self setTitle:@"聊天"];
    //搜索
    UIButton *rightSearch = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth - 44 - 44 - 10, ZWStatusBarHeight, 44, 44)];
    [rightSearch addTarget:self action:@selector(rightAction)forControlEvents:UIControlEventTouchUpInside];
    [rightSearch setImage:[UIImage imageNamed:@"contact_search"] forState:UIControlStateNormal];
    
    //添加
    UIButton *rightPluss = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth - 44 - 10, ZWStatusBarHeight, 44, 44)];
    [rightPluss addTarget:self action:@selector(rightBarButtonClicked:)forControlEvents:UIControlEventTouchUpInside];
    [rightPluss setImage:[UIImage imageNamed:@"添加"] forState:UIControlStateNormal];
    [self.navigationBgView addSubview:rightSearch];
    [self.navigationBgView addSubview:rightPluss];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //MARK:设置总的未读消息数
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self setTotalUnReadCount];
    });
    //MARK:获取本地最近联系人
    [self queryDataFromDB];
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEARLYLISTRELOAD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONTACTS_RELOAD object:nil];
}
//MARK: - 右边工具栏
- (void)rightBarButtonClicked:(UIButton *)sender
{
    //MARK: 下拉
    NSArray *titles = @[
                        @"发起群聊",
                        @"加好友",
                        @"扫一扫",
                        @"帮助",
                        ];
    NSArray *icons = @[
                       @"群聊",
                       @"添加好友",
                       @"扫一扫",
                       @"帮助"
                       ];
    [YBPopupMenu showRelyOnView:sender titles:titles icons:icons menuWidth:150.0f otherSettings:^(YBPopupMenu *popupMenu) {
        popupMenu.dismissOnSelected = YES;
        popupMenu.isShowShadow = NO;
        popupMenu.delegate = (id<YBPopupMenuDelegate>)self;
        popupMenu.offset = 10;
        popupMenu.type = YBPopupMenuTypeDefault;
        popupMenu.rectCorner = UIRectCornerBottomRight;
    }];
}
//MARK: - 搜索
- (void)rightAction{
    SearchFriendsViewController *searchVC = [[SearchFriendsViewController alloc] init];
    searchVC.item = MMConGroup_Friend;
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)registerNotic
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticReload:) name:NEARLYLISTRELOAD object:nil];//我的最近联系人记录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noticReload:) name:CONTACTS_RELOAD object:nil];//通讯录
}
// 通知常用联系人/常用联系群 重新加载数据
- (void)noticReload:(NSNotification *) notification
{
    NSString *tagType = notification.userInfo[@"tagType"];
    ZWWLog(@"收到的通知==%@",tagType)
    if ([tagType isEqualToString:@"12"]) {
        [self loadData:TargetType_TopC];//常用联系人
    }else{
        [self loadData:TargetType_ComG];//常用群组
    }
}
// 请求加载数据
- (void)loadData:(TargetType)tag;
{
    NSString * tagStr = @(tag).description;
    [[self.ViewModel.requestCommand execute:tagStr] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [self.laterPersonDataArr removeAllObjects];
            [self.laterPersonDataArr addObjectsFromArray:x[@"res"]];
        }else if ([x[@"code"] intValue] == 2){
            LoginVC *login = [[LoginVC alloc]init];
            BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:login];
            [self.navigationController presentViewController:nav animated:YES completion:nil];
            return ;
        }
    }];
}
- (void)noticFitchData:(NSNotification *) notification
{
    //刷新表格,造成数据库死锁
    [self queryDataFromDB];
}
//MARK: - 设置总的未读消息数
-(void)setTotalUnReadCount
{
    NSInteger mcount  = 0;
    NSMutableArray *arrTemp = [NSMutableArray array];
    if (self.laterPersonDataArr && [self.laterPersonDataArr count] > 0) {
        [arrTemp addObjectsFromArray:self.laterPersonDataArr];
    }
    MMRecentContactsModel *model;
    for (NSInteger i = 0,len = [arrTemp count]; i < len; i++) {
        id temp = arrTemp[i];
        if (temp && [temp isKindOfClass:[MMRecentContactsModel class]]) {
            model = (MMRecentContactsModel *)temp;
            mcount += model.unReadCount;
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        KinTabBarController *tabbar = (KinTabBarController *)self.tabBarController;
        if (tabbar) {
            if (mcount > 0) {
                [tabbar showBadgeOnItemIndex:0 withValue:mcount];
            }
            else{
                [tabbar hideBadgeOnItemIndex:0];
            }
        }
    });
}
#pragma mark - load data
- (void)queryDataFromDB
{
    [self.laterPersonDataArr removeAllObjects];
    [[MMChatDBManager shareManager] getAllConversations:^(NSArray<MMRecentContactsModel *> * _Nonnull conversations) {
        [self.laterPersonDataArr addObjectsFromArray:conversations];
        [self.tableView reloadData];
    }];
}
#pragma mark - YBPopupMenuDelegate
- (void)ybPopupMenu:(YBPopupMenu *)ybPopupMenu didSelectedAtIndex:(NSInteger)index
{
    switch (index) {
        //MARK:发起群聊
        case 0:
        {
            NewGroupViewController *group = [[NewGroupViewController alloc] init];
            [self.navigationController pushViewController:group animated:YES];
        }
            break;
        case 1:
        {
            ZWAddFriendViewController *search = [[ZWAddFriendViewController alloc] init];
            [self.navigationController pushViewController:search animated:YES];
        }
            break;
        case 2:{
            //相册权限检测
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized) {
                    NSLog(@"开启权限设置");
                    [MMTools openSetting];
                    return;
                }
            }];
            SweepViewController *sweepVC = [[SweepViewController alloc] init];
            sweepVC.delegate = (id<SweepViewControllerDelegate>)self;
            [self presentViewController:sweepVC animated:YES completion:nil];
        }
            break;
        case 3:{
            [YJProgressHUD showMessage:@"帮助"];
        }
            break;
        default:
            break;
    }
}
//MARK: - SweepViewControllerDelegate(二维码扫描委托)
-(void)sweepViewDidFinishSuccess:(id)sweepResult
{
    NSString *strInfo = [NSString stringWithFormat:@"%@",sweepResult];
    ZWWLog(@"扫描成功，详见：%@",sweepResult);
    NSArray *arrTemp = [strInfo componentsSeparatedByString:@"://"];
    NSString *strId = [NSString stringWithFormat:@"%@",arrTemp.lastObject];
    if (!strId.checkTextEmpty) {
        [MMProgressHUD showHUD:@"信息不存在"];
        return;
    }
    //MARK:扫码添加用户
    if ([strInfo containsString:K_APP_QRCODE_USER]) {
        NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
        if ([strId isEqualToString:userID]) {
            [MMProgressHUD showHUD:@"不能添加自己为好友"];
            return;
        }
        //到达好友详情界面
        AddFriViewController *VC = [[AddFriViewController alloc]init];
        VC.FromType = @"扫一扫";
        VC.userID = strId;
        [self.navigationController pushViewController:VC animated:YES];
    }
    //MARK:扫码加群
    else if([strInfo containsString:K_APP_QRCODE_GROUP]){
        [YJProgressHUD showMessage:@"扫码加入群聊"];
    }
}
-(void)sweepViewDidFinishError{}
#pragma mark - UITableViewDelegate and UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.laterPersonDataArr && [self.laterPersonDataArr count] > 0) {
        return [self.laterPersonDataArr count];
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return G_GET_SCALE_HEIGHT(50.0f);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
    ContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ContactTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (self.laterPersonDataArr && [self.laterPersonDataArr count] > indexPath.row) {
        [cell recentContactsWithModel:self.laterPersonDataArr[indexPath.row]];
    }
    return cell;
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *topTitle = @"置顶";//@"取消置顶" : @"置顶";
    NSString *readTitle = @"标为已读";//@"标为已读" : @"标为未读";
    
    //设置删除按钮
    UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self deleteNormalAction:indexPath];
    }];
    
    //置顶
    UITableViewRowAction * topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:topTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //[self setTopCellWithIndexPath:indexPath currentTop:group.isTop];
    }];
    
    //标记已读
    UITableViewRowAction * collectRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:readTitle handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //[self markerReadWithIndexPath:indexPath currentUnReadCount:group.unReadCount];
    }];
    
    collectRowAction.backgroundColor = [UIColor grayColor];
    topRowAction.backgroundColor     = [UIColor orangeColor];
    
    NSMutableArray *rowActionArr = [[NSMutableArray alloc] init];
    [rowActionArr addObject:deleteRowAction];
    [rowActionArr addObject:collectRowAction];
    [rowActionArr addObject:topRowAction];
    
    return  rowActionArr;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MMRecentContactsModel *model;
    if (self.laterPersonDataArr && [self.laterPersonDataArr count] > indexPath.row) {
        model = self.laterPersonDataArr[indexPath.row];
        if (model.userId) {
            [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
        }else{
            ZWWLog(@"进到通知界面")
            AddFriendStatusViewController *vc = [[AddFriendStatusViewController alloc]init];
            vc.newFriendsArr = self.pushListARR;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}
    
    
#pragma mark - Action
- (void)deleteNormalAction:(NSIndexPath *)indexPath
{
    MMRecentContactsModel *model;
    if (self.laterPersonDataArr && [self.laterPersonDataArr count] > indexPath.row) {
        model = self.laterPersonDataArr[indexPath.row];
    }
    
    WEAKSELF
    [[MMChatDBManager shareManager] deleteConversation:model.targetId
                                            completion:^(NSString * _Nonnull aConversationId,
                                                         NSError * _Nonnull aError) {
        if (!aError) {
            [weakSelf.laterPersonDataArr removeObjectAtIndex:indexPath.row];
            [weakSelf.tableView reloadData];
        }else{
            MMLog(@"删除失败");
        }
    }];
}
- (MMRecentContactsModel *)isExistConversationWithToUser:(NSString *)toUser
{
    MMRecentContactsModel *conversationModel;
    NSInteger index = 0;
    for (MMRecentContactsModel *conversation in self.laterPersonDataArr) {
        if ([conversation.userId isEqualToString:toUser]) {
            conversationModel = conversation;
            break;
        }
        index++;
    }
    return conversationModel;
}
- (void)addOrUpdateConversation:(NSString *)conversationName latestMessage:(MMMessageFrame *)message isRead:(BOOL)isRead
{
    MMRecentContactsModel *conversation = [self isExistConversationWithToUser:conversationName];
    if (conversation) {
        ZWWLog(@"当前会话未开启，未读消息")
        conversation.latestMsgStr = message.aMessage.slice.content;
        conversation.latestMsgTimeStamp = message.aMessage.timestamp;
        [self updateLatestMsgForConversation:conversation latestMessage:message isRead:isRead];
    }
    else {
        ZWWLog(@"如果当前会话开启，则已读消息")
        [self addConversationWithMessage:message conversationId:conversationName isReaded:isRead];
    }
}
    
- (void)addConversationWithMessage:(MMMessageFrame *)message conversationId:(NSString *)conversationId isReaded:(BOOL)read
{
    MMRecentContactsModel *conversation = [[MMRecentContactsModel alloc] init];
    conversation.unReadCount = read?0:1;
    conversation.userId = conversationId;
    [self.laterPersonDataArr insertObject:conversation atIndex:0];
    [self.tableView reloadData];
}
- (void)updateLatestMsgForConversation:(MMRecentContactsModel *)conversation latestMessage:(MMMessageFrame *)message isRead:(BOOL)isRead
{
    conversation.unReadCount += 1;
    if (isRead) {
        conversation.unReadCount = 0;
    }
    [self.laterPersonDataArr removeObject:conversation];
    [self.laterPersonDataArr insertObject:conversation atIndex:0];
    [self.tableView reloadData];
}
- (void)updateRedPointForUnreadWithConveration:(NSString *)conversationName
{
    MMRecentContactsModel *conversation = [self isExistConversationWithToUser:conversationName];
    if (conversation) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.laterPersonDataArr indexOfObject:conversation] inSection:0];
        [self updateRedPointForCellAtIndexPath:indexPath];
    }
}
// 打开会话，更新未读消息数量
- (void)updateRedPointForCellAtIndexPath:(NSIndexPath *)indexPath {
    MMRecentContactsModel *model = self.laterPersonDataArr[indexPath.row];
    model.unReadCount = 0;
    ContactTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    [cell updateUnreadCount:0];
}

- (void)clientManager:(MMClient *)manager didReceivedMessage:(MMMessage *)message
{
    MMMessageFrame *mf = [[MMMessageFrame alloc] init];
    mf.aMessage = message;
    NSString *conversationName = message.isSender  ? message.toID : message.fromID;
    BOOL isRead = [conversationName isEqualToString:[MMClient sharedClient].chattingConversation.conversationModel.toUid];
    [self addOrUpdateConversation:conversationName latestMessage:mf isRead:isRead];
}
- (NSMutableArray *)laterPersonDataArr
{
    if (!_laterPersonDataArr) {
        _laterPersonDataArr = [NSMutableArray new];
    }
    return _laterPersonDataArr;
}
- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat h = KScreenHeight - ZWStatusAndNavHeight - ZWTabbarHeight;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, KScreenWidth, h)
                                                  style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:identifier];
    }
    return _tableView;
}
-(NSMutableArray *)pushListARR{
    if (_pushListARR == nil) {
        _pushListARR = [[NSMutableArray alloc]init];
    }
    return _pushListARR;
}
@end

