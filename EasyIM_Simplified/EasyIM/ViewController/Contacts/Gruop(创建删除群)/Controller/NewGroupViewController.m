//
//  NewGroupViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/27.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "NewGroupViewController.h"
#import "ContactsModel.h"
#import "ListFriendModel.h"
#import "NewGroupViewCell.h"
#import "GroupCompleteViewController.h"
#import "MMContactsViewController.h"
#import "ZWIMSearchBar.h"
#import "ZWGroudDetailViewModel.h"
@interface NewGroupViewController () <UITableViewDelegate,UITableViewDataSource,ZWIMSearchBarDelegate,NewGroupViewCellDelegate>
{
    NSMutableArray *_searchResultArr;//搜索结果Arr
}
@property (nonatomic,strong) NSMutableArray *selectArray;//选中要添加的成员、
@property (nonatomic,strong) NSMutableArray *dataArr;//
@property (nonatomic,strong) NSMutableArray *userIDArr;//
@property (nonatomic, strong) UIButton *tickBtn;//
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;
@property (nonatomic, strong) ZWIMSearchBar *searchBar;
@property(nonatomic,strong)ZWGroudDetailViewModel *ViewModel;
@end
@implementation NewGroupViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"创建群聊"];
    [self showLeftBackButton];
    _searchResultArr = [NSMutableArray array];
    _selectArray = [NSMutableArray array];
    _dataArr = [NSMutableArray array];
    _userIDArr = [NSMutableArray array];
    _dataSource = [NSMutableArray array];
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.searchBar;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(completeEvent) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(KScreenWidth - 44 - 20, ZWStatusBarHeight, 44, 44);
    [button setTitle:@"确定" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#01A1EF"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont zwwNormalFont:13];
    [self.navigationView addSubview:button];
    self.tickBtn = button;
    [self.dataSource addObjectsFromArray:[MMContactsViewController shareInstance].arrData];
}
- (void)completeEvent
{
    GroupCompleteViewController *vc = [[GroupCompleteViewController alloc]init];
    vc.memberArray = self.dataArr;
    vc.userIdArr = self.userIDArr;
    [self.navigationController pushViewController:vc animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchBar.active) {
        return _searchResultArr.count;
    }else{
        return self.dataSource.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.searchBar.active) {
        return 0;
    }else{
        return 1.0;
    }
}
#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewGroupViewCell"];
    if (cell==nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NewGroupViewCell" forIndexPath:indexPath];
    }
    cell.delegate = (id<NewGroupViewCellDelegate>)self;
    cell.indexPath = indexPath;
    ContactsModel *model;
    if (self.searchBar.active) {
        model = _searchResultArr[indexPath.row];
    }else{
        model = self.dataSource[indexPath.row];
    }
    BOOL isSelect = NO;
    NSString *strName = @"";
    NSString *strPic = @"";
    if ([model isKindOfClass:[ContactsModel class]]) {
        strName = model.getName;
        strPic = model.photoUrl;
        isSelect = model.isSelect;
    }
    [cell.name setText:strName];
    if (strPic.checkTextEmpty) {
        [cell.logoImage sd_setImageWithURL:[NSURL URLWithString:strPic] placeholderImage:K_DEFAULT_USER_PIC];
    }
    else{
        cell.logoImage.image = K_DEFAULT_USER_PIC;
    }
    cell.selBtn.selected = model.isSelect;
    return cell;
}
- (void)updateSearchResultsForSearchBar:(ZWIMSearchBar *)searchBar {
    ZWWLog(@"===%@",searchBar.text)
//    [[self.ViewModel.SearchGroupCommand execute:searchBar.text] subscribeNext:^(id  _Nullable x) {
//        if ([x[@"code"] intValue] == 0) {
//
//        }
//    }] ;
    // 刷新数据
    [self filterContentForSearchText:searchBar.text scope:@""];
}
- (BOOL)searchBar:(ZWIMSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(ZWIMSearchBar *)searchBar {
    return YES;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ContactsModel *model;
    if (self.searchBar.active) {
        model = _searchResultArr[indexPath.row];
    }else{
        model = self.dataSource[indexPath.row];
    }
    if (!model.isSelect) {
        model.isSelect = YES;
        [self.dataArr addObject:model];
        [self.userIDArr addObject:model.userId];
    }else{
        model.isSelect = NO;
        [self.dataArr removeObject:model];
        [self.userIDArr removeObject:model.userId];
    }
    if (self.userIDArr.count >= 1) {
        self.tickBtn.hidden = NO;
    }else {
        self.tickBtn.hidden = YES;
    }
    if (self.searchBar.active) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
//cell代理实现
-(void)selectCellWithSelectText:(NSString *)selectText isSelect:(BOOL)isSelect indexPath:(NSIndexPath *)indexPath
{
    ZWWLog(@"===%@",selectText);
    ContactsModel *model;
    if (self.searchBar.active) {
        model = _searchResultArr[indexPath.row];
    }else{
        model = self.dataSource[indexPath.row];
    }
    if (!model.isSelect) {
        if (![self.selectArray containsObject:selectText]) {
            model.isSelect = YES;
            [self.selectArray addObject:selectText];
            [self.dataArr addObject:model];
            [self.userIDArr addObject:model.userId];
        }
    }else{
        if ([self.selectArray containsObject:selectText]) {
            model.isSelect = NO;
            [self.selectArray removeObject:selectText];
            [self.dataArr removeObject:model];
            [self.userIDArr removeObject:model.userId];
        }
    }
    if (self.selectArray.count >= 1) {
        self.tickBtn.hidden = NO;
    }else {
        self.tickBtn.hidden = YES;
    }
    if (self.searchBar.active) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
#pragma mark - 源字符串内容是否包含或等于要搜索的字符串内容
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSMutableArray *tempResults = [NSMutableArray array];
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    NSMutableArray *dataArr = self.dataSource;
    for (int i = 0; i < dataArr.count; i++) {
        if (![dataArr[i] isKindOfClass:[ContactsModel class]]) {
            continue;
        }
        NSString *storeString = [(ContactsModel *)dataArr[i] nickName];
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            ContactsModel *model = dataArr[i];
            [tempResults addObject:model];
        }
    }
    [_searchResultArr removeAllObjects];
    [_searchResultArr addObjectsFromArray:tempResults];
    [self.tableView reloadData];
}
-(UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, KScreenWidth, KScreenHeight - ZWStatusAndNavHeight - ZWTabbarSafeBottomMargin) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[NewGroupViewCell class] forCellReuseIdentifier:@"NewGroupViewCell"];
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag; // 拖动时隐藏键盘
        //_tableView.firstReload = YES;
    }
    return _tableView;
}
- (ZWIMSearchBar *)searchBar {
    if (!_searchBar) {
        ZWIMSearchBar *searchBar = [[ZWIMSearchBar alloc] init];
        searchBar.frame = CGRectMake(0, 0, KScreenWidth, 50);
        searchBar.placeholder = @"输入“用户名”或选取“联系人";
        searchBar.delegate = self;
        _searchBar = searchBar;
    }
    return _searchBar;
}
-(ZWGroudDetailViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWGroudDetailViewModel alloc]init];
    }
    return _ViewModel;
}
@end
