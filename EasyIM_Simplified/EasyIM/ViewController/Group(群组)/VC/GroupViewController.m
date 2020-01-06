//
//  GroupViewController.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/19.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "GroupViewController.h"
#import "ContactTableViewCell.h"
#import "ZWGroupViewModel.h"
#import "ZWGroupModel.h"
#import "SearchFriendsViewController.h"
#import "ZWAddFriendViewController.h"
#import "MMTools.h"
#import "NewGroupViewController.h"
//相册
#import <Photos/Photos.h>
//下拉菜单列表
#import <YBPopupMenu.h>
//扫一扫
#import "SweepViewController.h"
static NSString *const identifier = @"ContactTableViewCell";
@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource,MMFriendCellDelegate,YBPopupMenuDelegate,SweepViewControllerDelegate>
@property (nonatomic, strong) NSMutableArray <ZWGroupModel *>*groupDataList;//群列表
@property (nonatomic, strong) UITableView *tableView;
@property(nonatomic,strong) ZWGroupViewModel*ViewModel;
@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"群组"];
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
-(void)rightAction{
     SearchFriendsViewController *searchVC = [[SearchFriendsViewController alloc] init];
     searchVC.item = MMConGroup_Group;
     [self.navigationController pushViewController:searchVC animated:YES];
}
-(void)rightBarButtonClicked:(UIButton *)sender{
     //MARK: 下拉
       NSArray *titles = @[
                           @"发起群聊",
                           @"加群",
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
            [YJProgressHUD showMessage:@"不能添加自己为好友"];
            return;
        }
        [[self.ViewModel.addFriendCommand execute:strId] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [YJProgressHUD showSuccess: @"请求成功"];
            }
        }];
    }
    else if([strInfo containsString:K_APP_QRCODE_GROUP]){
        [YJProgressHUD showMessage:@"扫码加入群聊"];
    }
}

-(void)sweepViewDidFinishError
{
    MMLog(@"扫描失败");
}
-(void)zw_addSubviews{
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
         [self fetchGroupList];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
         [self getMoreData];
    }];
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark 获取我的群聊
- (void)fetchGroupList
{
    [[self.ViewModel.requestCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        [self.tableView.mj_header endRefreshing];
        if ([x[@"code"] intValue] == 0) {
            BOOL IsMore = [x[@"isMore"] boolValue];
            self.groupDataList = x[@"res"];
            if (!IsMore) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.tableView reloadData];
        }
    }];
}
-(void)getMoreData{
    [[self.ViewModel.requestMoreCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        [self.tableView.mj_footer endRefreshing];
        if ([x[@"code"] intValue] == 0) {
            NSArray *arr = x[@"res"];
            if (arr.count) {
                [self.groupDataList addObjectsFromArray:arr];
                [self.tableView reloadData];
                [self.tableView.mj_footer endRefreshing];
            }else{
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
    }];
}
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
            
        //MARK:加好友/群
        case 1:
        {
            ZWAddFriendViewController *search = [[ZWAddFriendViewController alloc] init];
            search.item = MMConGroup_Group;
            [self.navigationController pushViewController:search animated:YES];
        }
            break;
            
        //MARK:扫一扫
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
            
        //MARK:帮助
        case 3:{
            [YJProgressHUD showMessage:@"帮助"];
        }
            break;
        default:
            break;
    }
}
#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupDataList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 67;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[ContactTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.delegate = (id<MMFriendCellDelegate>)self;
    }
    if ([self.groupDataList count] && [self.groupDataList count] > indexPath.row) {
        cell.ZWgroupModel = self.groupDataList[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //MARK:群聊跳转
    if (self.groupDataList.count && [self.groupDataList count] > indexPath.row) {
        ZWGroupModel *model = self.groupDataList[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
    }
    else{
        [MMProgressHUD showHUD:@"数据不存在"];
    }
}
- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer{
    ZWWLog(@"长按")
}
//MARK: - lazy load
-(NSMutableArray<ZWGroupModel *> *)groupDataList{
    if (!_groupDataList) {
        _groupDataList = [NSMutableArray new];
    }
    return _groupDataList;
}
- (UITableView *)tableView{
    if (!_tableView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight - ZWTabbarHeight;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, h)
                                                  style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:identifier];
    }
    return _tableView;
}
-(ZWGroupViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWGroupViewModel alloc]init];
    }
    return _ViewModel;
}


@end
