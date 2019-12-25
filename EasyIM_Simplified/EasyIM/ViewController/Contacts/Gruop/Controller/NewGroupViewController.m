//
//  NewGroupViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/27.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "NewGroupViewController.h"
#import "ContactTableViewCell.h"
#import "ContactsModel.h"
#import "ListFriendModel.h"
#import "NewGroupViewCell.h"
#import "GroupCompleteViewController.h"
#import "MMContactsViewController.h"

#import "ZWSearch.h"
@interface NewGroupViewController () <UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_searchResultArr;//搜索结果Arr
}
@property (nonatomic,strong) NSMutableArray *selectArray;//选中要添加的成员、
@property (nonatomic,strong) NSMutableArray *dataArr;//
@property (nonatomic,strong) NSMutableArray *userIDArr;//
@property (nonatomic, strong) UIButton *tickBtn;//
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) ZWSearch *searchView;
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
    ZWSearch * searchView = [[ZWSearch alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    searchView.isFirstResponser = NO;
    self.searchView = searchView;
    searchView.iconName = @"contacts_search_icon";
    searchView.iconSize = CGSizeMake(18, 18);
    //    searchView.insetsIcon = UIEdgeInsetsMake(0, 30, 0, 0);
    searchView.titleBtn = @"取消";
    searchView.placeHolder = @"输入“用户名”或选取“联系人";
    searchView.colorSearchBg = [UIColor whiteColor];
    searchView.insetsTxtfield = UIEdgeInsetsMake(0, 10, 0, 20);
    searchView.cusFontTxt = 13;
    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.searchView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"newGroup_tick"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(completeEvent) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(KScreenWidth - 44 - 20, ZWStatusBarHeight, 44, 44);
    [self.navigationView addSubview:button];
    self.tickBtn = button;
    [self.dataSource addObjectsFromArray:[MMContactsViewController shareInstance].arrData];
    [searchView setTxtfieldEditingCallback:^(NSString *text) {
        ZWWLog(@"======%@",text)
        //在这里,进行界面替换.改变bool值.将原有数据源替换成检索之后的数据
    }];
    [searchView setClickSearchCallback:^(NSString *keyword) {
        [self.view endEditing:YES];
    }];
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
//    if (_searchDisplayController.active) {
//        return _searchResultArr.count;
//    }else{
        return self.dataSource.count;
    //}
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (_searchDisplayController.active) {
//        return 0;
//    }else{
        return 1.0;
   // }
}
#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewGroupViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewGroupViewCell"];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NewGroupViewCell" owner:self options:nil] lastObject];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = (id<NewGroupViewCellDelegate>)self;
    cell.indexPath = indexPath;
    ContactsModel *model;
//    if (_searchDisplayController.active) {
//        model = _searchResultArr[indexPath.row];
//    }else{
        model = self.dataSource[indexPath.row];
    //}
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
    cell.selImage.image = isSelect ? [UIImage imageNamed:@"group_selected"]:[UIImage imageNamed:@"group_unSelected"];
    return cell;
}
//cell  代理
-(void)selectCellWithSelectText:(NSString *)selectText isSelect:(BOOL)isSelect indexPath:(NSIndexPath *)indexPath
{
    ZWWLog(@"%@",selectText);
    ContactsModel *model;
//    if (_searchDisplayController.active) {
//        model = _searchResultArr[indexPath.row];
//    }else{
        model = self.dataSource[indexPath.row];
    //}
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
//    if (_searchDisplayController.active) {
////        [_searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }else{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //}
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
        _tableView.firstReload = YES;
    }
    return _tableView;
}
@end
