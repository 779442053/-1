//
//  MMContactsViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//
#import "MMContactsViewController.h"

/** 通讯录 */
#import <Contacts/Contacts.h>

//索引切换动画
#import "JJTableViewIndexView.h"

//搜索好友
#import "SearchFriendsViewController.h"

//下拉刷新、上拉加载更多
#import "MJRefresh.h"

//手机通讯录
#import "AddressBookViewController.h"

//工具栏
#import "MMTools.h"

//列
#import "ContactsTableViewCell.h"

//新朋友
#import "AddFriendStatusViewController.h"

#import "KinTabBarController.h"

#import "ZWContactsViewModel.h"
static CGFloat   const cell_section_height = 32;
static CGFloat   const foot_view_empty_h = 200;

static NSString *const k_data_pic = @"pic";
static NSString *const k_data_name = @"name";
static NSString *const kdefault_section_title = @"默认组头";

static MMContactsViewController *_shareInstance = nil;

#define kIndexArray @[@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T",@"U", @"V", @"W", @"X", @"Y", @"Z",@"#"]

@interface MMContactsViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong) UITableView *listTableView;
@property(nonatomic,strong) NSMutableArray<NSString *> *muArrSectionData;
@property(nonatomic,strong) NSMutableDictionary *muDicListData;
@property(nonatomic,strong) JJTableViewIndexView *tabbleIndexView;
@property(nonatomic,strong) NSMutableArray *dataScoure;
@property(nonatomic,strong) NSMutableArray *PushARR;
@property(nonatomic,strong) UIView *emptyView;
@property (nonatomic, assign) NSInteger unReadCount;
@property (nonatomic, strong) ZWContactsViewModel *ViewModel;
@end

@implementation MMContactsViewController
-(ZWContactsViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWContactsViewModel alloc]init];
    }
    return _ViewModel;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        //加载联系人
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self loadContactDataForRefresh:YES andAnimation:YES];
        });
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PushDataNotionfion:) name:IMPushData object:nil];
    //MARK:下拉刷新
    WEAKSELF
    self.listTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadContactDataForRefresh:YES andAnimation:YES];
    }];
    [self.listTableView.mj_header beginRefreshing];
    //MARK:上拉加载更多
    self.listTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        [self loadMoreData];
    }];
    //好友通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAddFriend:) name:FriendChangeNotifion object:nil];
    [self setTitle: @"通讯录"];
    //搜索
    UIButton *rightSearch = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth - 44 - 10, ZWStatusBarHeight, 44, 44)];
    [rightSearch addTarget:self action:@selector(rightAction)forControlEvents:UIControlEventTouchUpInside];
    [rightSearch setImage:[UIImage imageNamed:@"contact_search"] forState:UIControlStateNormal];
    [self.navigationBgView addSubview:rightSearch];
    [[self.ViewModel.GetPushdataCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            self.PushARR = x[@"res"];
            if (self.PushARR.count) {
                _unReadCount = self.PushARR.count;
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                    ContactsTableViewCell *cell = [self.listTableView cellForRowAtIndexPath:indexPath];
                    if (cell) {
                        [cell setRightBadgeForNO:_unReadCount];
                    }
                    KinTabBarController *tabbar = (KinTabBarController *)self.tabBarController;
                    if (tabbar) {
                        if (_unReadCount > 0) {
                            [tabbar showBadgeOnItemIndex:1 withValue:_unReadCount];
                        }
                        else{
                            [tabbar hideBadgeOnItemIndex:1];
                        }
                    }
                });
            }
        }
    }];
}
-(void)PushDataNotionfion:(NSNotification*)info{
    ZWWLog(@"受到的通知=%@",info)
}
//MARK: - initView
-(void)initView{
    [self.view addSubview:self.listTableView];
    [self.view addSubview:self.tabbleIndexView];
}
//获取列数据
-(NSArray *_Nullable)getListCellForSection:(NSInteger)section{
    if (self.muArrSectionData && [self.muArrSectionData count] > section) {
        NSString *strKey = [NSString stringWithFormat:@"%@",self.muArrSectionData[section]];
        if (strKey.checkTextEmpty && self.muDicListData && [[self.muDicListData allKeys] containsObject:strKey]) {
            NSArray *arrTemp = (NSArray *)[self.muDicListData valueForKey:strKey];
            return arrTemp;
        }
    }
    
    return nil;
}
- (void)rightAction{
    SearchFriendsViewController *searchVC = [[SearchFriendsViewController alloc] init];
    searchVC.item = MMConGroup_Friend;
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)handleAddFriend:(NSNotification *_Nullable)notic{
    //1.如果通知没有object 直接返回
    if (!notic.object) {
        return;
    }
    _unReadCount++;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        ContactsTableViewCell *cell = [self.listTableView cellForRowAtIndexPath:indexPath];
        if (cell) {
            [cell setRightBadgeForNO:_unReadCount];
        }
        KinTabBarController *tabbar = (KinTabBarController *)self.tabBarController;
        if (tabbar) {
            if (_unReadCount > 0) {
                [tabbar showBadgeOnItemIndex:1 withValue:_unReadCount];
            }
            else{
                [tabbar hideBadgeOnItemIndex:1];
            }
        }
    });
}
-(void)loadMoreData{
    WEAKSELF
    BLOCKSELF
    [[self.ViewModel.requestMoreCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            NSArray *friendList = x[@"res"];
            BOOL isMore = [x[@"isMore"] boolValue];
            ZWWLog(@"============isMore=%d",isMore)
            //赋值
            NSMutableArray *muArr = [NSMutableArray array];
            if ([_arrData count] > 0) {
                [muArr addObjectsFromArray:_arrData];
            }
            if(friendList){
               [muArr addObjectsFromArray:friendList];
            }
            _arrData = [muArr copy];
            if (friendList && [friendList count]){
                for (ContactsModel *model in friendList) {
                    NSString *strName = model.getName;
                    NSString *strKey = [YHUtils getFirstLetter:strName];
                    if (![kIndexArray containsObject:strKey]) {
                        strKey = @"#";
                    }
                    //添加索引
                    if (![blockSelf.muArrSectionData containsObject:strKey]) {
                        [blockSelf.muArrSectionData addObject:strKey];
                    }
                    //添加列表数据
                    NSMutableArray *muArrTemp = [NSMutableArray array];;
                    if ([[weakSelf.muDicListData allKeys] containsObject:strKey]) {
                        muArrTemp = [NSMutableArray arrayWithArray:blockSelf.muDicListData[strKey]];
                    }
                    [muArrTemp addObject:model];
                    [blockSelf.muDicListData setValue:muArrTemp forKey:strKey];
                }
                
                //[S] 索引排序(升序)
                [blockSelf.muArrSectionData removeObject:kdefault_section_title];
                
                BOOL isExits = NO;
                if ([blockSelf.muArrSectionData containsObject:@"#"]) {
                    isExits = YES;
                    [blockSelf.muArrSectionData removeObject:@"#"];
                }
                self.muArrSectionData = [NSMutableArray<NSString *> arrayWithArray:[self.muArrSectionData sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
                //追加到末尾
                if (isExits) {
                    [blockSelf.muArrSectionData addObject:@"#"];
                }
                //追加到第一位
                [blockSelf.muArrSectionData insertObject:kdefault_section_title atIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isMore) {
                    [self.listTableView.mj_footer endRefreshing];
                }
                else{
                    [self.listTableView.mj_footer endRefreshingWithNoMoreData];
                }
                [self.listTableView reloadData];
                [MMProgressHUD hideHUD];
            });
        }
    }];
}

//MARK: - 获取联系人
-(void)loadContactDataForRefresh:(BOOL)isRefresh
                    andAnimation:(BOOL)isAnimation{
    if (isRefresh) {
        _arrData = [NSArray<ContactsModel *> new];
        NSDictionary *dicTemp = @{
                                  kdefault_section_title:@[
                                        @{k_data_pic:@"contact_new",k_data_name:@"新的朋友"},
                                          @{k_data_pic:@"contact_plus",k_data_name:@"添加好友"},
                                          @{k_data_pic:@"contact_people",k_data_name:@"手机通讯录匹配"}
                                          ]
                                  };
        _muDicListData = [NSMutableDictionary dictionaryWithDictionary:dicTemp];
        _muArrSectionData = [NSMutableArray arrayWithObjects:kdefault_section_title, nil];
    }
    WEAKSELF
    BLOCKSELF
    [[self.ViewModel.requestCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            NSArray *friendList = x[@"res"];
            BOOL isMore = [x[@"isMore"] boolValue];
           // ZWWLog(@"============isMore=%d",isMore)
            //赋值
            NSMutableArray *muArr = [NSMutableArray array];
            if ([_arrData count] > 0) {
                [muArr addObjectsFromArray:_arrData];
            }
            if(friendList){
               [muArr addObjectsFromArray:friendList];
            }
            _arrData = [muArr copy];
            if (friendList && [friendList count]){
                for (ContactsModel *model in friendList) {
                    NSString *strName = model.getName;
                    NSString *strKey = [YHUtils getFirstLetter:strName];
                    if (![kIndexArray containsObject:strKey]) {
                        strKey = @"#";
                    }
                    //添加索引
                    if (![blockSelf.muArrSectionData containsObject:strKey]) {
                        [blockSelf.muArrSectionData addObject:strKey];
                    }
                    //添加列表数据
                    NSMutableArray *muArrTemp = [NSMutableArray array];;
                    if ([[weakSelf.muDicListData allKeys] containsObject:strKey]) {
                        muArrTemp = [NSMutableArray arrayWithArray:blockSelf.muDicListData[strKey]];
                    }
                    [muArrTemp addObject:model];
                    [blockSelf.muDicListData setValue:muArrTemp forKey:strKey];
                }
                //[S] 索引排序(升序)
                [blockSelf.muArrSectionData removeObject:kdefault_section_title];
                BOOL isExits = NO;
                if ([blockSelf.muArrSectionData containsObject:@"#"]) {
                    isExits = YES;
                    [blockSelf.muArrSectionData removeObject:@"#"];
                }
                self.muArrSectionData = [NSMutableArray<NSString *> arrayWithArray:[self.muArrSectionData sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
                //追加到末尾
                if (isExits) {
                    [blockSelf.muArrSectionData addObject:@"#"];
                }
                //追加到第一位
                [blockSelf.muArrSectionData insertObject:kdefault_section_title atIndex:0];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listTableView.mj_header endRefreshing];
                if (isMore) {
                    [self.listTableView.mj_footer endRefreshing];
                }
                else{
                    [self.listTableView.mj_footer endRefreshingWithNoMoreData];
                }
                [self.listTableView reloadData];
                [MMProgressHUD hideHUD];
            });
        }
    }];
}
//MARK: - 创建组视图
- (UIView *)createSectionHeadViewForTitle:(NSString *_Nonnull)strTitle{
    UIView *_sectionHeadView = [BaseUIView createView:CGRectMake(0, 0, G_SCREEN_WIDTH, cell_section_height)
                                   AndBackgroundColor:[UIColor colorWithHexString:@"#EFEFF4"]
                                          AndisRadius:NO
                                            AndRadiuc:0
                                       AndBorderWidth:0
                                       AndBorderColor:nil];
    //标题
    CGFloat w = 50;
    CGFloat h = 21;
    CGFloat y = (cell_section_height - h) * 0.5;
    UILabel *labTitle = [BaseUIView createLable:CGRectMake(17, y, w, h)
                                        AndText:strTitle
                                   AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                     AndTxtFont:FONT(13)
                             AndBackgroundColor:nil];
    labTitle.textAlignment = NSTextAlignmentLeft;
    [_sectionHeadView addSubview:labTitle];
    return _sectionHeadView;
}
-(void)getAddressData{
    //防止重复操作
    if (!self.dataScoure || [self.dataScoure count] <= 0) {
        //获取指定的字段,并不是要获取所有字段，需要指定具体的字段
        NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
            NSString *givenName = contact.givenName;
            NSString *familyName = contact.familyName;
            NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
            NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
            if (!nameStr) { nameStr = @"";}
            NSArray *phoneNumbers = contact.phoneNumbers;
            [myDict setObject:nameStr forKey:@"aName"];
            BOOL isTel = NO;
            for (CNLabeledValue *labelValue in phoneNumbers) {
                NSString *label = labelValue.label;
                phoneNumbers = labelValue.value;
                CNPhoneNumber *phoneNumber = labelValue.value;
                NSLog(@"label=%@ 电话:%@\n", label,phoneNumber.stringValue);
                
                [myDict setObject:phoneNumber.stringValue forKey:@"cellphone"];
                
                isTel = YES;
            }
            if (isTel == NO) {[myDict setObject:@"" forKey:@"cellphone"];}
            
            if (!self.dataScoure) {
                self.dataScoure = [NSMutableArray array];
            }
            [self.dataScoure addObject:myDict];
        }];
    }
    //电话去重
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *,id> * bindings) {
        NSInteger i = 0;
        NSString *strPhone = [NSString stringWithFormat:@"%@",[evaluatedObject valueForKey:@"cellphone"]];
        if (self.dataScoure && [self.dataScoure count] > 0) {
            i = 0;
            for (NSDictionary *object in self.dataScoure) {
                if([[object valueForKey:@"cellphone"] isEqualToString:strPhone]){
                    i++;
                }
            }
            return i > 1?NO:YES;
        }
        else{
            return NO;
        }
        return YES;
    }];
    NSArray *arrTemp = [self.dataScoure filteredArrayUsingPredicate:predicate];
    self.dataScoure = [NSMutableArray arrayWithArray:arrTemp];
}
//MARK: - 修改备注
- (void)remarkFriend:(NSIndexPath *)indexPath
{
    //MARK: 备注好友
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"修改备注" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"备注";
    }];
    
    UIAlertAction *confimAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *remarkField = alert.textFields.firstObject;
        if (!remarkField.text.length) {
            [MMProgressHUD showHUD:@"备注内容不能为空"];
            return ;
        }
        if (self.muArrSectionData && [self.muArrSectionData count] > indexPath.section) {
            NSArray *arrTemp = [self getListCellForSection:indexPath.section];
            if (arrTemp && [arrTemp count] > indexPath.row){
                ContactsModel *model = arrTemp[indexPath.row];
                remarkField.placeholder = [model getName];
                if ([model isKindOfClass:[ContactsModel class]]) {
                    WEAKSELF
                    [[self.ViewModel.restUserNameCommand execute:@{@"muserid":model.userId,@"musername":remarkField.text}] subscribeNext:^(id  _Nullable x) {
                        if ([x[@"code"] intValue] == 1) {
                            model.remarkName = remarkField.text;
                            [weakSelf.listTableView reloadRowsAtIndexPaths:@[indexPath]
                                                            withRowAnimation:UITableViewRowAnimationAutomatic];
                        }
                    }];
                }
            }
        }
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:confimAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}
//MARK: - 删除好友
-(void)deleteFriendForIndex:(NSIndexPath *_Nonnull)indexPath{
    if (self.muArrSectionData && [self.muArrSectionData count] > indexPath.section) {
        NSArray *arrTemp = [self getListCellForSection:indexPath.section];
        if (arrTemp && [arrTemp count] > indexPath.row){
            ContactsModel *model = arrTemp[indexPath.row];
            if ([model isKindOfClass:[ContactsModel class]]) {
                WEAKSELF
                [[self.ViewModel.deleteUserCommand execute:model.userId] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        [MMProgressHUD showHUD:@"删除成功"];
                        [weakSelf.listTableView beginUpdates];
                    }
                }];
            }
        }
    }
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.muArrSectionData && [self.muArrSectionData count] > 0) {
        return [self.muArrSectionData count];
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.muArrSectionData && [self.muArrSectionData count] > section && section > 0) {
        return cell_section_height;
    }
    return CGFLOAT_MIN;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0 && (!self.muArrSectionData || [self.muArrSectionData count] <= 1)) {
        return foot_view_empty_h;
    }
    return CGFLOAT_MIN;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (self.muArrSectionData && [self.muArrSectionData count] > 0 && section > 0) {
        NSString *strTtile = self.muArrSectionData[section];
        return [self createSectionHeadViewForTitle:strTtile];
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 0 && (!self.muArrSectionData || [self.muArrSectionData count] <= 1)) {
        return self.emptyView;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

//MARK:表列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrTemp = [self getListCellForSection:section];
    if (arrTemp) return [arrTemp count];
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ContactsTableViewCell getCellIdentify]];
    if (cell == nil) {
        cell = [[ContactsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ContactsTableViewCell getCellIdentify]];
    }
    
    NSArray *arrTemp = [self getListCellForSection:indexPath.section];
    if (arrTemp && [arrTemp count] > indexPath.row){
        NSString *strName;
        NSString *strUrl;
        id cellData = arrTemp[indexPath.row];
        if ([cellData isKindOfClass:[ContactsModel class]]) {
            ContactsModel *model = (ContactsModel *)cellData;
            strName = model.getName;
            strUrl = model.photoUrl;
        }
        else if([cellData isKindOfClass:[NSDictionary class]]){
            strName = cellData[k_data_name];
            strUrl = [NSString stringWithFormat:@"%@",cellData[k_data_pic]];
        }
        [cell cellInitDataForName:strName
                           AndPic:strUrl];
    }
    if (indexPath.section == 0 && indexPath.row == 0 && _unReadCount > 0) {
        [cell setRightBadgeForNO:_unReadCount];
    }
    else{
        [cell setRightBadgeForNO:0];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [ContactsTableViewCell getCellHeight];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.muArrSectionData && [self.muArrSectionData count] > indexPath.section) {
        if (indexPath.section == 0) {
            switch (indexPath.row) {
                //MARK:新朋友
                case 0:
                {
                    _unReadCount = 0;
                    KinTabBarController *tabbar = (KinTabBarController *)self.tabBarController;
                    if (tabbar) {
                        [tabbar hideBadgeOnItemIndex:1];
                    }
                    AddFriendStatusViewController *vc = [[AddFriendStatusViewController alloc] init];
                    if (self.PushARR.count) {
                        vc.newFriendsArr = self.PushARR;
                    }
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                    
                //MARK:添加好友
                case 1:
                {
                    [self rightAction];
                }
                    break;
                 
                //MARK:手机通讯录
                case 2:
                {
                    //获取权限
                    if([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusRestricted || [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusDenied){
                        [MMProgressHUD showHUD:@"请开启通讯录访问权限"];
                        [MMTools openSetting];
                    }
                    else{

                        //获取通讯录数据
                        [self getAddressData];
                        
                        AddressBookViewController *vc = [[AddressBookViewController alloc] init];
                        vc.arrAddressData = self.dataScoure;
                        vc.addFriendFinishBack = ^{
                            //添加好友后的回调，可以刷新当前列表...
                        };
                        [self.navigationController pushViewController:vc animated:YES];
                    }
                }
                    break;
                default:
                    break;
            }
        }
        else{
            //单聊
            NSArray *arrTemp = [self getListCellForSection:indexPath.section];
            if (arrTemp && [arrTemp count] > indexPath.row){
                
                if ([arrTemp[indexPath.row] isKindOfClass:[ContactsModel class]]) {
                    ContactsModel *model = arrTemp[indexPath.row];
                    model.cmd = @"sendMsg";
                    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
                }
            }
        }
    }
}
//MARK: - 侧滑
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section >= 1) {
        
        //MARK:删除
        UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"是否确定删除该好友？" preferredStyle:UIAlertControllerStyleActionSheet];
            
            [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [self deleteFriendForIndex:indexPath];
            }]];
            
            [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            
            [self presentViewController:alertVC animated:YES completion:nil];
        }];
        deleteRowAction.backgroundColor = [UIColor colorWithHexString:@"#ff544b"];
        
        //MARK:备注
        UITableViewRowAction * topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"备注" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self remarkFriend:indexPath];
        }];
        topRowAction.backgroundColor = [UIApplication sharedApplication].keyWindow.tintColor;
        
        NSMutableArray *rowActionArr = [[NSMutableArray alloc] init];
        [rowActionArr addObject:deleteRowAction];
        [rowActionArr addObject:topRowAction];
        return  rowActionArr;
    }
    return nil;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
        return NO;
    return YES;
}
//MARK: - lazy load
- (UITableView *)listTableView{
    if (!_listTableView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight - ZWTabbarHeight;
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, h)
                                                      style:UITableViewStylePlain];
        _listTableView.backgroundColor = [UIColor clearColor];
        
        //分割线
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _listTableView.separatorColor = G_EEF0F3_COLOR;
        
        //是否允许选中
        //_listTableView.allowsSelection = YES;
        //_listTableView.allowsMultipleSelection = NO;
        
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, 11)];
        headView.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
        _listTableView.tableHeaderView = headView;
        _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        //注册
        [_listTableView registerClass:[ContactsTableViewCell class]
               forCellReuseIdentifier:[ContactsTableViewCell getCellIdentify]];
    }
    return _listTableView;
}

- (NSMutableArray<NSString *> *)muArrSectionData{
    if (!_muArrSectionData) {
        _muArrSectionData = [NSMutableArray arrayWithObjects:kdefault_section_title, nil];
    }
    return _muArrSectionData;
}

- (NSMutableDictionary *)muDicListData{
    if (!_muDicListData) {
        _muDicListData = [NSMutableDictionary dictionary];
    }
    return _muDicListData;
}

- (JJTableViewIndexView *)tabbleIndexView{
    if (!_tabbleIndexView) {
        CGFloat w = 40;
        CGFloat h = 331;
        CGFloat y = (G_SCREEN_HEIGHT  - h) * 0.5;
        _tabbleIndexView = [[JJTableViewIndexView alloc] initWithFrame:CGRectMake(G_SCREEN_WIDTH - w, y, w, h)
                                                       stringNameArray:kIndexArray];
        _tabbleIndexView.backgroundColor = [UIColor clearColor];
        
        //索引切换
        WEAKSELF
        _tabbleIndexView.selectedBlock = ^(NSInteger section) {
            //滚动到顶部
            if (section == 0) {
                [weakSelf.listTableView setContentOffset:CGPointZero animated:YES];
            }
            //列表滑动
            else{
                if ([kIndexArray count] > section) {
                    NSString *strKey = kIndexArray[section];
                    
                    if (weakSelf.muArrSectionData && [weakSelf.muArrSectionData containsObject:strKey]) {
                        NSInteger nSection = [weakSelf.muArrSectionData indexOfObject:strKey];
                        
                        NSArray *arrTemp = [weakSelf getListCellForSection:nSection];
                        if (!arrTemp && [arrTemp count] <= 0) return;
                        
                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:nSection];
                        [weakSelf.listTableView selectRowAtIndexPath:indexPath
                                                            animated:YES
                                                      scrollPosition:UITableViewScrollPositionTop];
                    }
                }
            }
        };
    }
    return _tabbleIndexView;
}

-(UIView *)emptyView{
    if (!_emptyView) {
        CGFloat w = G_SCREEN_WIDTH;
        CGFloat x = 0;
        CGFloat y = 0;
        _emptyView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, foot_view_empty_h)];
        _emptyView.backgroundColor = [UIColor clearColor];
        
        //MARK:图片
        w = 85;
        CGFloat h = 103;
        x = (_emptyView.frame.size.width - w) * 0.5;
        CGRect rect = CGRectMake(x, 50, w, h);
        UIImageView *imgBg = [BaseUIView createImage:rect
                                            AndImage:[UIImage imageNamed:@"search_empty_img"] AndBackgroundColor:nil WithisRadius:NO];
        [_emptyView addSubview:imgBg];
        
        //MARK:标题
        h = 21;
        w = _emptyView.frame.size.width;
        x = 0;
        y = imgBg.y + imgBg.height + 10;
        UILabel *labInfo = [BaseUIView createLable:CGRectMake(x, y, w, h)
                                           AndText:@"暂无通讯录好友哦"
                                      AndTextColor:[UIColor grayColor]
                                        AndTxtFont:[UIFont systemFontOfSize:16]
                                AndBackgroundColor:nil];
        labInfo.textAlignment = NSTextAlignmentCenter;
        [_emptyView addSubview:labInfo];
    }
    return _emptyView;
}
//MARK：- 单利
+(MMContactsViewController *__weak)shareInstance;{
    if(_shareInstance != nil){
        return _shareInstance;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_shareInstance == nil){
            _shareInstance = [[self alloc] init];
        }
    });
    return _shareInstance;
}
-(id)copyWithZone:(NSZone *)zone{
    return _shareInstance;
}
+(id)allocWithZone:(struct _NSZone *)zone{
    if(_shareInstance != nil){
        return _shareInstance;
    }
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(_shareInstance == nil){
            _shareInstance = [super allocWithZone:zone];
        }
    });
    return _shareInstance;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:FriendChangeNotifion object:nil];
}
-(NSMutableArray *)PushARR{
    if (_PushARR == nil) {
        _PushARR = [[NSMutableArray alloc]init];
    }
    return _PushARR;
}
@end
