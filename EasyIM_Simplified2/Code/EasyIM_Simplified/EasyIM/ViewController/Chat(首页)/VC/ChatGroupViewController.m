//
//  ChatGroupViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/24.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ChatGroupViewController.h"
#import "ContactTableViewCell.h"


static NSString *const identifier = @"ContactTableViewCell";

@interface ChatGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *groupDataList;//群列表
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ChatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"我的群聊"];
    [self showLeftBackButton];
}
-(void)zw_addSubviews{
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
         [self fetchGroupList];
    }];
    // 马上进入刷新状态
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 网络请求
- (void)fetchGroupList
{
    //MARK: 获取群列表
    [MMRequestManager queryGroupCallBack:^(NSArray<MMGroupModel *> * _Nonnull groupList, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        if (!error) {
            self.groupDataList = groupList.mutableCopy;
            [self.tableView reloadData];
        }else{
            [MMProgressHUD showHUD: MMDescriptionForError(error)];
        }
    }];
    
}


#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupDataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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
        cell.groupModel = self.groupDataList[indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //MARK:群聊跳转
    if (self.groupDataList.count && [self.groupDataList count] > indexPath.row) {
        MMGroupModel *model = self.groupDataList[indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
    }
    else{
        [MMProgressHUD showHUD:@"数据不存在"];
    }
    
}
//MARK: - lazy load
- (NSMutableArray *)groupDataList
{
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
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        //注册
        [_tableView registerClass:[ContactTableViewCell class] forCellReuseIdentifier:identifier];
    }
    return _tableView;
}
@end
