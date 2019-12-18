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

#import "ZWSearchBar.h"

@interface NewGroupViewController () <ZWSearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray *_searchResultArr;//搜索结果Arr
}

@property (nonatomic, strong) UISearchBar *searchBar;//搜索框
@property (nonatomic, strong) UISearchDisplayController *searchDisplayController;//搜索VC
@property (nonatomic,strong) NSMutableArray *selectArray;//选中要添加的成员、
@property (nonatomic,strong) NSMutableArray *dataArr;//
@property (nonatomic,strong) NSMutableArray *userIDArr;//
@property (nonatomic, strong) UIButton *tickBtn;//
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UITableView *tempTableView;
@property (strong, nonatomic) UITableView *tableView;
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
    self.tableView.tableHeaderView = self.searchBar;
//   _searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
//   [_searchDisplayController setDelegate:self];
//   [_searchDisplayController setSearchResultsDataSource:self];
//   [_searchDisplayController setSearchResultsDelegate:self];
//   [self.dataSource addObjectsFromArray:[MMContactsViewController shareInstance].arrData];
    [self addRightBtn];
}
// 添加按钮
- (void)addRightBtn
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"newGroup_tick"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(completeEvent) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(KScreenWidth - 44*2, ZWStatusBarHeight, 44, 44);
    [self.navigationView addSubview:button];
    self.tickBtn = button;
}
- (void)completeEvent
{
    GroupCompleteViewController *vc = [[GroupCompleteViewController alloc]init];
    vc.memberArray = self.dataArr;
    vc.userIdArr = self.userIDArr;
    [self.navigationController pushViewController:vc animated:YES];
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [_searchBar sizeToFit];
        [_searchBar setPlaceholder:@"输入“用户名”或选取“联系人"];
        [_searchBar setDelegate:self];
        self.searchBar.barTintColor = [UIColor whiteColor];
        UITextField *searchField = [self.searchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.layer.cornerRadius = 14.0f;
            [searchField setTintColor:[UIColor blackColor]];
        }
        [_searchBar setKeyboardType:UIKeyboardTypeDefault];
        [self fm_setCancelButtonTitle:@"取消"];
        [self fm_setTextColor:[UIColor blackColor]];
    }
    return _searchBar;
}

- (void)fm_setTextColor:(UIColor *)textColor
{
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]].textColor = textColor;
}

- (void)fm_setCancelButtonTitle:(NSString *)title
{
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[ UIColor blackColor],NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
}


#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //section
    if (tableView==_searchDisplayController.searchResultsTableView) {
        return 1;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //row
    if (tableView==_searchDisplayController.searchResultsTableView) {
        return _searchResultArr.count;
    }else{
        return self.dataSource.count;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0f;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView==_searchDisplayController.searchResultsTableView) {
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
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NewGroupViewCell" owner:self options:nil] lastObject];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.delegate = (id<NewGroupViewCellDelegate>)self;
    cell.indexPath = indexPath;
    ContactsModel *model;
    if (tableView ==_searchDisplayController.searchResultsTableView) {
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
    cell.selImage.image = isSelect ? [UIImage imageNamed:@"group_selected"]:[UIImage imageNamed:@"group_unSelected"];
    return cell;
}

#pragma mark -- NewGroupViewCellDelegate
// 选中成员
-(void)selectCellWithSelectText:(NSString *)selectText isSelect:(BOOL)isSelect indexPath:(NSIndexPath *)indexPath
{
    MMLog(@"%@",selectText);
    ContactsModel *model;
    if (self.tempTableView ==_searchDisplayController.searchResultsTableView) {
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
        [self addRightBtn];
        self.tickBtn.hidden = NO;
    }else {
        self.tickBtn.hidden = YES;
    }
    
    if (self.tempTableView ==_searchDisplayController.searchResultsTableView) {
        [_searchDisplayController.searchResultsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }

}
#pragma mark SearchBarDelegate
//searchBar开始编辑时改变取消按钮的文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    self.tempTableView = _searchDisplayController.searchResultsTableView;
    searchBar.showsCancelButton = YES;
    NSArray *subViews;
    subViews = [(searchBar.subviews[0]) subviews];
    for (id view in subViews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton* cancelbutton = (UIButton* )view;
            NSString *canceStr = @"取消";
            [cancelbutton setTitle:canceStr forState:UIControlStateNormal];
            break;
        }
    }
}
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.tempTableView = self.tableView;
    [self.tableView reloadData];
    //取消
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}
#pragma mark searchDisplayControllerdelegate
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    //cell无数据时，不显示间隔线
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [tableView setTableFooterView:v];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[self.searchBar scopeButtonTitles][self.searchBar.selectedScopeButtonIndex]];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:self.searchBar.text
                               scope:self.searchBar.scopeButtonTitles[searchOption]];
    return YES;
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
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    self.tempTableView = self.tableView;
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
//        _tableView.estimatedSectionHeaderHeight = 0;
//        _tableView.estimatedSectionFooterHeight = 0;
    }
    return _tableView;
}
@end