//
//  SearchFriendsViewController.m
//  EasyIM
//
//  Created by momo on 2019/4/10.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "SearchFriendsViewController.h"
#import "MJRefresh.h"
//Cell
#import "ContactTableViewCell.h"
#import "SearchFriendCell.h"
//Model
#import "SearchFriendModel.h"
#import "FriendInfoViewController.h"
//通讯录
#import "MMContactsViewController.h"

//添加好友
#import "AddFriViewController.h"
#import "ZWSearchBar.h"
#import "ZWAddFriendViewModel.h"

static NSString *const cellIde = @"cellIde";
static NSString *const page_size = @"10";
@interface SearchFriendsViewController ()<UITableViewDelegate,UITableViewDataSource,ZWSearchBarDelegate>
{
    NSInteger _currentRequestPage;
    NSInteger _pageIndex;
}
@property(nonatomic,strong)ZWSearchBar *searchBar;
@property (nonatomic, strong) NSString *key;
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;//数据源
/**
 * 用于比较对方是不是好友
 */
@property (nonatomic, strong) NSMutableArray *frdList;
@property(nonatomic,strong)ZWAddFriendViewModel *ViewModel;

@end
@implementation SearchFriendsViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_item == MMConGroup_Group) {
        [self setTitle:@"搜索群"];
        self.searchBar.placeholderLabel.text = @"请输入群号/群名称";
    }
    else{
        [self setTitle:@"搜索好友"];
        self.searchBar.placeholderLabel.text = @"请输入好友账号/手机号";
    }
    [self showLeftBackButton];
    self.frdList = [NSMutableArray arrayWithArray:[MMContactsViewController shareInstance].arrData];
}
-(void)zw_addSubviews{
    [self.view addSubview:self.tableView];
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 50)];
    [headView addSubview:self.searchBar];
    self.tableView.tableHeaderView = headView;
    //MARK:上拉加载更多
    //WEAKSELF
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if ([self.key checkTextEmpty]){
            if (self.item == MMConGroup_Group) {
                [[self.ViewModel.searchMoreGroupCommand execute:self.key] subscribeNext:^(id  _Nullable x) {
                    NSArray *arr = x[@"res"];
                    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        MMGroupModel *groupModel =(MMGroupModel *)obj;
                        NSString *creatID = [NSString stringWithFormat:@"%@",groupModel.creatorID];
                        NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                        if ([groupModel isKindOfClass:[MMGroupModel class]] && [creatID isEqualToString:userID]) {
                            groupModel.IsMyGroup = YES;
                            return ;
                        }
                    }];
                    [self.dataSource addObjectsFromArray:arr];
                    [self.tableView reloadData];
                    if (arr.count == 0) {
                        [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        [self.tableView.mj_footer endRefreshing];
                    }
                }completed:^{
                    //[self.tableView.mj_footer endRefreshing];
                }];
            }else{
                [[self.ViewModel.searchMoreFriendCommand execute:self.key] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        NSArray *arr = x[@"res"];
                        if (arr.count == 0) {
                            [self.tableView.mj_footer endRefreshingWithNoMoreData];
                        }else{
                            [self.tableView.mj_footer endRefreshing];
                            [self.dataSource addObjectsFromArray:arr];
                            [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                SearchFriendModel *searchModel = (SearchFriendModel *)obj;
                                [self.frdList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                    ContactsModel *contactsModel = (ContactsModel *)obj;
                                    NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                                    if (([contactsModel isKindOfClass:[ContactsModel class]] && [searchModel.userid isEqualToString:contactsModel.userId]) || [searchModel.userid isEqualToString:userID] ) {
                                        searchModel.isFriend = YES;
                                        return ;
                                    }
                                }];
                            }];
                            [self.tableView reloadData];
                        }
                    }
                }completed:^{
                }];
            }
        }
    }];
}
-(void)cancleWithStr{
  ZWWLog(@"取消搜索")
}
- (void)searchWithStr:(NSString *)text{
    self.key = text;
    if ([text checkTextEmpty]) {
        if (self.item == MMConGroup_Group) {
            [[self.ViewModel.searchGroupCommand execute:text] subscribeNext:^(id  _Nullable x) {
                if ([x[@"code"] intValue] == 0) {
                    self.dataSource = x[@"res"];
                    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        MMGroupModel *groupModel =(MMGroupModel *)obj;
                        NSString *creatID = [NSString stringWithFormat:@"%@",groupModel.creatorID];
                        NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                        if ([groupModel isKindOfClass:[MMGroupModel class]] && [creatID isEqualToString:userID]) {
                            groupModel.IsMyGroup = YES;
                            return ;
                        }
                    }];
                    [self.tableView reloadData];
                }
            }];
        }else{
            [[self.ViewModel.searchFriendCommand execute:text] subscribeNext:^(id  _Nullable x) {
                if ([x[@"code"] intValue] == 0) {
                    self.dataSource = x[@"res"];
                    //遍历处自己已经成为自己的好友
                    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        SearchFriendModel *searchModel = (SearchFriendModel *)obj;
                        [self.frdList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            ContactsModel *contactsModel = (ContactsModel *)obj;
                            if ([contactsModel isKindOfClass:[ContactsModel class]] && [searchModel.userid isEqualToString:contactsModel.userId]) {
                                searchModel.isFriend = YES;
                                return ;
                            }
                        }];
                    }];
                    ZWWLog(@"========%@",self.dataSource)
                    [self.tableView reloadData];
                }
            }];
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (!cell) {
        cell=[[SearchFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if (self.dataSource && [self.dataSource count] > indexPath.row) {
        id cellData = self.dataSource[indexPath.row];
        if ([cellData isKindOfClass:[SearchFriendModel class]]) {
            cell.model = self.dataSource[indexPath.row];
        }
        else{
            MMGroupModel *model = (MMGroupModel *)cellData;
            [cell cellInitGroupData:model];
        }
    }
    cell.button.tag = indexPath.row;
    [cell.button addTarget:self action:@selector(checkButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //群
    if (self.item == MMConGroup_Group) return;
    SearchFriendModel *searchModel = self.dataSource[indexPath.row];
    if (!searchModel.isFriend) {
        AddFriViewController *vc = [[AddFriViewController alloc]init];
        vc.model = searchModel;
        vc.FromType = @"搜索";
        vc.userID = searchModel.userid;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else{
        //用户
        if ([self.dataSource count] && [self.dataSource count] > indexPath.row) {
            FriendInfoViewController *friend = [[FriendInfoViewController alloc] init];
            friend.userId = searchModel.userid;
            friend.isFriend = searchModel.isFriend;
            [self.navigationController pushViewController:friend animated:YES];
        }
    }
}
//MARK: - 添加好友/群
- (void)checkButtonTapped:(UIButton *)sender
{
    NSInteger index = sender.tag;
    if (self.dataSource && [self.dataSource count] > index) {
        if (self.item == MMConGroup_Group) {
            MMGroupModel *model = (MMGroupModel *)self.dataSource[index];
            if (model.IsMyGroup) {
                [YJProgressHUD showMessage:@"您已经是群成员啦"];
            }else{
                if (model && [ZWUserModel currentUser]) {
                    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
                    parma[@"groupID"] = model.groupID;
                    parma[@"creatorID"] = model.creatorID;
                    [[self.ViewModel.addGroupCommand execute:parma] subscribeNext:^(id  _Nullable x) {
                        if ([x[@"code"] intValue] == 0) {
                            [YJProgressHUD showSuccess:@"请求发送成功,等待群主确认"];
                        }
                    }];
                }
                else{
                    [MMProgressHUD showHUD:@"群组数据不存在"];
                }
            }
            
        }else{
            SearchFriendModel *searchModel = self.dataSource[index];
            if (!searchModel.isFriend) {
                NSString *myName = [ZWUserModel currentUser].userName;
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                NSString *FriendID = [NSString stringWithFormat:@"%@",searchModel.userid];
                if ([userID isEqualToString:FriendID]) {
                    [YJProgressHUD showMessage:@"自己不能添加自己为h好友"];
                }else{
                    [self addFriendrequest:searchModel.userid
                    msg:[NSString stringWithFormat:@"你好,我是%@,请求加您好友",myName]];
                }
            }
            else{
                [MMProgressHUD showHUD:@"对方已经是你的好友"];
            }
        }
    }
}

#pragma mark - 添加好友网络请求
- (void)addFriendrequest:(NSString *)tagUserid msg:(NSString *)msg
{
    NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    if ([tagUserid isEqualToString:userID]) {
        [MMProgressHUD showHUD:@"不能添加自己为好友"];
        return;
    }
    //添加好友,走tcp 请求
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"type"] = @"req";
    parma[@"cmd"] = @"addFriend";
    parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    parma[@"toID"] = tagUserid;
    parma[@"msg"] = [NSString stringWithFormat:@"你好!我是%@，请求加您为好友",[ZWUserModel currentUser].nickName];
    ZWWLog(@"添加朋友=%@",parma)
    [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
    }];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT-ZWStatusAndNavHeight) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        [_tableView setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        //cell无数据时，不显示间隔线
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:view];
        //_tableView.firstReload = YES;
        //分隔线
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = G_EEF0F3_COLOR;
        //注册
        [_tableView registerClass:[SearchFriendCell class] forCellReuseIdentifier:cellIde];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(ZWSearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[ZWSearchBar alloc]initWithFrame:CGRectMake(10, 5, KScreenWidth-40, 40)];
        _searchBar.SearchDelegate = self;
    }
    return _searchBar;
}
-(ZWAddFriendViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWAddFriendViewModel alloc]init];
    }
    return _ViewModel;
}


@end
