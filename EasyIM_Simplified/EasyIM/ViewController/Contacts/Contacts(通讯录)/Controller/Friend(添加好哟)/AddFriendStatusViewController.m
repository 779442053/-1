//
//  AddFriendStatusViewController.m
//  EasyIM
//
//  Created by momo on 2019/4/10.
//  Copyright © 2019年 余谦. All rights reserved.
//
//添加好友反馈
#import "AddFriendStatusViewController.h"
#import "NewFriendCell.h"
#import "NewFriendModel.h"
#import "MMDateHelper.h"
#import "MMFriendAppViewController.h"
#import "VerificationViewController.h"//验证
#import "FriDetailViewController.h"//发消息

#import "ZWSocketManager.h"
@interface AddFriendStatusViewController ()<UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate,AddFriendAgreeDelegate,AddFriendAgreeDelegate2>
@property (nonatomic, weak)   UITableView *resultListView;
@property (nonatomic, strong) NSString *startTag;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) NSString *userId;
@end
@implementation AddFriendStatusViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"新的消息"];
    [self showLeftBackButton];
    CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight;
    UITableView *resultListView = [[UITableView alloc] initWithFrame:CGRectMake(0,ZWStatusAndNavHeight , G_SCREEN_WIDTH, h)
                                                  style:UITableViewStylePlain];
    resultListView.dataSource = self;
    resultListView.delegate = self;
    resultListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    resultListView.backgroundColor = [UIColor whiteColor];
    resultListView.tableFooterView = [UIView new];
    resultListView.firstReload = NO;
    [self.view addSubview:resultListView];
    self.resultListView = resultListView;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete){
        NewFriendModel *Model = self.newFriendsArr[indexPath.row];
        NSMutableDictionary *parma = [[NSMutableDictionary alloc] init];
        parma[@"type"] = @"req";
        parma[@"xns"] = @"xns_user";
        parma[@"cmd"] = @"ignoreBulletin";
        parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
        parma[@"timestamp"] = [MMDateHelper getNowTime];
        parma[@"bulletinIds"] = Model.uid;
        [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
            if (!error) {
                [self.newFriendsArr removeObject:Model];
                [self.resultListView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.newFriendsArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"newFriendCell";
    NewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[NewFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.delegate =  self;
    }
    cell.model = self.newFriendsArr[indexPath.row];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,KScreenWidth, 44)];
    [sectionView setBackgroundColor:MMColor(234, 237, 244)];
    UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 80, 24)];
    [titleLabel setText:@"新的消息"];
    [titleLabel setFont:[UIFont systemFontOfSize:15]];
    [titleLabel setTextColor:[UIColor lightGrayColor]];
    [sectionView addSubview:titleLabel];
    return sectionView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    NewFriendModel *NFModel = self.newFriendsArr[indexPath.row];
    if (NFModel.bulletinType == 0) {//对方请求加我为好友
        VerificationViewController *verVC = [[VerificationViewController alloc]init];
           verVC.model = self.newFriendsArr[indexPath.row];
           verVC.delegate = self;
        [self.navigationController pushViewController:verVC animated:YES];
    }else if(NFModel.bulletinType == 1){//已经是好友
        FriDetailViewController *sendMsgVC = [[FriDetailViewController alloc]init];
        sendMsgVC.Nmodel = NFModel;
        [self.navigationController pushViewController:sendMsgVC animated:YES];
        
    }else if (NFModel.bulletinType == 2) {
        [MMProgressHUD showHUD:@"对方已拒绝您的请求"];
        return;
    }
//    MMFriendAppViewController *fApp = [[MMFriendAppViewController alloc] init];
//    fApp.model = self.newFriendsArr[indexPath.row];
//    fApp.delegate = self;
    
}
#pragma mark - AddFriendAgreeDelegate
//同意加为好友
- (void)didAgreeWithCell:(NewFriendCell *)cell
{
    NSIndexPath *indexPath = [self.resultListView indexPathForCell:cell];
    NewFriendModel *model = self.newFriendsArr[indexPath.row];
    switch (model.bulletinType) {
        case 0:
        {
            ZWWLog(@"接受别人邀请加我为好友")
            NSMutableDictionary *Parma = [[NSMutableDictionary alloc] init];
            Parma[@"type"] = @"req";
            Parma[@"cmd"] = @"acceptFriend";
            Parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            Parma[@"toID"] = model.fromID;
            Parma[@"time"] = [MMDateHelper getNowTime];
            Parma[@"msg"] = @"";
            [ZWSocketManager SendDataWithData:Parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    //修改数据源
                    model.bulletinType = BULLETIN_TYPE_ACCEPT_FRIEND;
                    [self.resultListView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
            
        }
            break;
        case 11:
        {
            ZWWLog(@"接受别人请求加入群")
            NSMutableDictionary *Parma = [[NSMutableDictionary alloc] init];
            Parma[@"type"] = @"req";
            Parma[@"cmd"] = @"acceptFriend";
            Parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            Parma[@"toID"] = model.fromID;
            Parma[@"groupID"] = model.groupID;
            Parma[@"time"] = [MMDateHelper getNowTime];
            Parma[@"msg"] = @"";
            [ZWSocketManager SendDataWithData:Parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    //修改数据源
                    model.bulletinType = BULLETIN_TYPE_ACCEPT_FRIEND;
                    [self.resultListView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            }];
        }
            break;
        case 1:
        {
            ZWWLog(@"不进行操作")
        }
            break;
            
        default:
            break;
    }
}
/**好友状态界面里面的回调*/
//同意加为好友
- (void)acceptRquestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock
{//修改数据源
    NewFriendModel *model = self.newFriendsArr[_indexPath.row];
    model.bulletinType = BULLETIN_TYPE_ACCEPT_FRIEND;
    [self.resultListView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
//拒绝加为好友
- (void)rejectRequestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock
{
    NewFriendModel *model = self.newFriendsArr[_indexPath.row];
    model.bulletinType = BULLETIN_TYPE_REJECT_FRIEND;
    [self.resultListView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationFade];
}
- (NSMutableArray *)newFriendsArr {
    if (_newFriendsArr == nil) {
        _newFriendsArr = [[NSMutableArray alloc] init];
    }
    return _newFriendsArr;
}

@end
