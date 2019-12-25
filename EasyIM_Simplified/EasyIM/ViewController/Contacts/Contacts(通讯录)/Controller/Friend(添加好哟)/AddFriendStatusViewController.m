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
#import "SearchFriendsViewController.h"
#import "VerificationViewController.h"//验证
#import "FriDetailViewController.h"//发消息



@interface AddFriendStatusViewController ()<UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate,AddFriendAgreeDelegate,AddFriendAgreeDelegate2>
{
    UIView                      *EmptyView;     //空数据视图
}

@property (nonatomic,strong) UISearchBar *searchBar;//搜索框

@property (nonatomic, weak)   UITableView *resultListView;
@property (nonatomic, strong) NSString *startTag;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) NSMutableDictionary *mDic;
@property (nonatomic, strong) NSString *userId;
@end
@implementation AddFriendStatusViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_bindViewModel{
    //获取好友请求的列表
    //[weakSelf.newFriendsArr removeAllObjects];
    //            [weakSelf.newFriendsArr addObjectsFromArray:bulletionList];
    //            [weakSelf.resultListView reloadData];
}
-(void)zw_addSubviews{
    [self setTitle:@"新的朋友"];
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
    [self creatEmptyUI];
}
#pragma mark --UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 44+44)];
    [sectionView setBackgroundColor:MMColor(234, 237, 244)];
    [sectionView addSubview:self.searchBar];
    UIButton *searB = [UIButton buttonWithType:UIButtonTypeCustom];
    searB.frame = self.searchBar.frame;
    [searB addTarget:self action:@selector(clickSearch:) forControlEvents:UIControlEventTouchUpInside];
    [sectionView addSubview:searB];
    UILabel  *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8+44+8, 80, 24)];
    [titleLabel setText:@"新的朋友"];
    [titleLabel setFont:[UIFont systemFontOfSize:15]];
    [titleLabel setTextColor:[UIColor lightGrayColor]];
    [sectionView addSubview:titleLabel];
    return sectionView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0f + 44.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _indexPath = indexPath;
    VerificationViewController *verVC = [[VerificationViewController alloc]init];
    verVC.model = self.newFriendsArr[indexPath.row];
    verVC.delegate = self;
    NewFriendModel *NFModel = self.newFriendsArr[indexPath.row];
    if ([NFModel.bulletinType isEqualToString:@"0"]) {//还不是好友
        [self.navigationController pushViewController:verVC animated:YES];
    }else if([NFModel.bulletinType isEqualToString:@"1"]){//已经是好友
        FriDetailViewController *sendMsgVC = [[FriDetailViewController alloc]init];
        sendMsgVC.Nmodel = NFModel;
        [self.navigationController pushViewController:sendMsgVC animated:YES];
        
    }else if ([NFModel.bulletinType isEqualToString:@"2"]) {
        [MMProgressHUD showHUD:@"对方已拒绝您的请求"];
        return;
    }
//    MMFriendAppViewController *fApp = [[MMFriendAppViewController alloc] init];
//    fApp.model = self.newFriendsArr[indexPath.row];
//    fApp.delegate = self;
    
}

- (void)clickSearch:(UIButton *)sender {
    SearchFriendsViewController *vc = [[SearchFriendsViewController alloc]init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - AddFriendAgreeDelegate
//同意加为好友
- (void)didAgreeWithCell:(NewFriendCell *)cell
{
    NSIndexPath *indexPath = [self.resultListView indexPathForCell:cell];
    NewFriendModel *model = self.newFriendsArr[indexPath.row];
    [self commonRequest:model cmd:@"acceptFriend" msg:@"对方接受你的好友请求"];
}
#pragma mark - AddFriendAgreeDelegate2

//同意加为好友
- (void)acceptRquestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock
{
    [self.mDic setObject:aComptionBlock forKey:@(type).description];
    NewFriendModel *model = self.newFriendsArr[_indexPath.row];
    [self commonRequest:model cmd:@"acceptFriend" msg:@"对方接受你的好友请求"];
}

//拒绝加为好友
- (void)rejectRequestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock
{
    [self.mDic setObject:aComptionBlock forKey:@(type).description];
    NewFriendModel *model = self.newFriendsArr[_indexPath.row];
    [self commonRequest:model cmd:@"rejectFriend" msg:@"对方拒绝你的好友请求"];
}


#pragma mark - Public

- (void)commonRequest:(NewFriendModel *)model cmd:(NSString *)cmd msg:(NSString *)msg
{
    
    WEAKSELF
    [MMRequestManager aNoticFriendsWithCmd:cmd tagUserId:model.fromID time:model.time msg:msg aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        
        MMLog(@"%@",dic);
        
        if (!error) {
            AddFStatusBlock statusBlock;
            if ([cmd isEqualToString:@"acceptFriend"]) {
                model.bulletinType = @(1).description;
                statusBlock = self.mDic[@(MMFAppAccept).description];
                if (statusBlock) {
                    statusBlock(dic, error);
                }
            }else if ([cmd isEqualToString:@"rejectFriend"]){
                model.bulletinType = @(2).description;
                statusBlock = self.mDic[@(MMFAppRes).description];
                if (statusBlock) {
                    statusBlock(dic, error);
                }
            }
            
//            if (self.changeStatusBlock) {l
//                self.changeStatusBlock(weakSelf.self.newFriendsArr);
//            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil userInfo:nil];
            [MMProgressHUD showHUD:dic[@"desc"]];
            [weakSelf.resultListView reloadData];
        }else{
            [MMProgressHUD showHUD: MMDescriptionForError(error)];
        }
    }];
}
- (NSMutableArray *)newFriendsArr {
    if (_newFriendsArr == nil) {
        _newFriendsArr = [[NSMutableArray alloc] init];
    }
    return _newFriendsArr;
}

- (NSMutableDictionary *)mDic
{
    if (!_mDic) {
        _mDic = [[NSMutableDictionary alloc] init];
    }
    return _mDic;
}
- (void)creatEmptyUI {
    EmptyView = [[UIView alloc]initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT - ZWStatusAndNavHeight)];
    EmptyView.backgroundColor = [UIColor whiteColor];
    EmptyView.tag = 10086;
    [self.view addSubview:EmptyView];
    UILabel *msgLb = [[UILabel alloc]init];
    msgLb.bounds = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    msgLb.centerX = self.view.centerX;
    msgLb.centerY = self.view.centerY-100;
    msgLb.textAlignment = NSTextAlignmentCenter;
    msgLb.font = [UIFont systemFontOfSize:14];
    msgLb.textColor = [UIColor colorWithHexString:@"#9DA1A7"];
    msgLb.numberOfLines = 0;
    msgLb.text = @"还木有好友申请~";
    [EmptyView addSubview:msgLb];
    EmptyView.hidden = YES;
}
@end
