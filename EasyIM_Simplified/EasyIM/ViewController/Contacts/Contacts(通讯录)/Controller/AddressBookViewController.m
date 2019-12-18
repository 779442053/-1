//
//  AddressBookViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/24.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "AddressBookViewController.h"

#import "MMContactsViewController.h"

//索引切换动画
#import "JJTableViewIndexView.h"

static CGFloat const cell_height = 60;
static CGFloat const cell_section_height = 32;
static NSString *const cell_identify = @"addressbook_cell_identify";

#define kIndexArray @[@"A", @"B", @"C", @"D", @"E", @"F", @"G",@"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T",@"U", @"V", @"W", @"X", @"Y", @"Z",@"#"]

@interface AddressBookViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *listTableView;
@property(nonatomic,strong) NSMutableArray<NSString *> *muArrSectionData;
@property(nonatomic,strong) NSMutableDictionary *muDicListData;

/** 索引视图 */
@property(nonatomic,strong) JJTableViewIndexView *tabbleIndexView;

@end

@implementation AddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initFormatData];
    [self setTitle:@"手机通讯录"];
    [self showLeftBackButton];
}

//MARK: - initView
-(void)initView{
    [self.view addSubview:self.listTableView];
    [self.view addSubview:self.tabbleIndexView];
}

-(void)initFormatData{
    
    if (!_arrAddressData || [_arrAddressData count] <= 0) {
        NSLog(@"通讯录数据不存在");
        return;
    }
    
    for (NSDictionary *model in _arrAddressData) {
        NSString *strName = model[@"aName"];
        NSString *strKey = [YHUtils getFirstLetter:strName];
        if (![kIndexArray containsObject:strKey]) {
            strKey = @"#";
        }
        
        //添加索引
        if (!self.muArrSectionData) {
            self.muArrSectionData = [NSMutableArray<NSString *> array];
        }
        
        if (![self.muArrSectionData containsObject:strKey]) {
            [self.muArrSectionData addObject:strKey];
        }
        
        //添加列表数据
        if (!self.muDicListData) {
            self.muDicListData = [NSMutableDictionary dictionary];
        }
        
        NSMutableArray *muArrTemp = [NSMutableArray array];;
        if ([[self.muDicListData allKeys] containsObject:strKey]) {
            muArrTemp = [NSMutableArray arrayWithArray:self.muDicListData[strKey]];
        }
        
        [muArrTemp addObject:model];
        [self.muDicListData setValue:muArrTemp forKey:strKey];
    }
    
    //[S] 索引排序(升序)
    BOOL isExits = NO;
    if ([self.muArrSectionData containsObject:@"#"]) {
        isExits = YES;
        [self.muArrSectionData removeObject:@"#"];
    }

    self.muArrSectionData = [NSMutableArray<NSString *> arrayWithArray:[self.muArrSectionData sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    
    //追加到末尾
    if (isExits) {
        [self.muArrSectionData addObject:@"#"];
    }
    //[E] 索引排序(升序)
    
    [self.listTableView reloadData];
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


//MARK: - 添加好友
-(IBAction)btnAddFriendAction:(UIButton *)sender{
    NSInteger section = sender.superview.superview.tag;
    NSInteger index = sender.superview.tag;
    
    if (self.muArrSectionData && [self.muArrSectionData count] > section) {
        NSArray *arrTemp = [self getListCellForSection:section];
        if (arrTemp && [arrTemp count] > index){
            NSDictionary *dicTemp = arrTemp[index];
            NSLog(@"dicTemp:%@",dicTemp);
            
            if (self.addFriendFinishBack) {
                self.addFriendFinishBack();
            }
        
            //暂无通过手机号加好友接口,只有通过UserId加好友的接口...
            [MMProgressHUD showHUD:@"暂无通过手机号加好友接口"];
        }
    }
    
    NSLog(@"数据不存在,section:%ld,index:%ld",section,index);
}

//通讯录联系人是否已添加为好友(true 已添加)
-(BOOL)isAlreadyFriendForPhone:(NSString *_Nullable)strPhone{
    
    if (strPhone.checkTextEmpty) {
        
        NSArray *arrData = [[MMContactsViewController shareInstance].arrData copy];
        if (arrData && [arrData count] > 0) {
            
            for (id model in arrData) {
                if ([model isKindOfClass:[ContactsModel class]]) {
                    
                    ContactsModel *cmodel = (ContactsModel *)model;
                    if(cmodel.userName.checkTextEmpty && [strPhone containsString:cmodel.userName])
                       return YES;
                }
            }
            return NO;
        }
    }
    return NO;
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


//MARK: -  UITableViewDataSource、UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.muArrSectionData && [self.muArrSectionData count] > 0) {
        return [self.muArrSectionData count];
    }
    return 1;
}

//MARK:组头、组尾
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.muArrSectionData && [self.muArrSectionData count] > section) {
        return cell_section_height;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (self.muArrSectionData && [self.muArrSectionData count] > section) {
        NSString *strTtile = self.muArrSectionData[section];
        
        return [self createSectionHeadViewForTitle:strTtile];
    }
    
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

//MARK:表列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arrTemp = [self getListCellForSection:section];
    if (arrTemp) return [arrTemp count];
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_identify];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //MARK:图像
    NSInteger tag = 1234;
    UIImageView *imgPic = (UIImageView *)[cell.contentView viewWithTag:tag];
    if (!imgPic) {
        CGFloat w = 36;
        CGFloat h = 36;
        CGFloat y = (cell_height - h) * 0.5;
        imgPic = [BaseUIView createImage:CGRectMake(16, y, w, h)
                                AndImage:K_DEFAULT_USER_PIC
                      AndBackgroundColor:nil
                               AndRadius:YES
                             WithCorners:3];
        
        imgPic.tag = tag;
        [cell.contentView addSubview:imgPic];
    }
    
    //MARK:标题
    tag = 1235;
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:tag];
    if (!labTitle) {
        CGFloat h = 21;
        CGFloat x = imgPic.width + imgPic.x + 11;
        CGFloat y = (cell_height - h) * 0.5;
        labTitle = [BaseUIView createLable:CGRectMake(x, y, 150, h)
                                   AndText:nil
                              AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                AndTxtFont:FONT(13)
                        AndBackgroundColor:nil];
        labTitle.textAlignment = NSTextAlignmentLeft;
        
        labTitle.tag = tag;
        [cell.contentView addSubview:labTitle];
    }
    
    //MARK:添加
    tag = 1236;
    UIButton *btnAdd = (UIButton *)[cell.contentView viewWithTag:tag];
    if (!btnAdd) {
        CGFloat w = 80;
        CGFloat h = 30;
        CGFloat x = G_SCREEN_WIDTH - w - 26;
        CGFloat y = (cell_height - h) * 0.5;
        btnAdd = [BaseUIView createBtn:CGRectMake(x, y, w, h)
                              AndTitle:@"添加好友"
                         AndTitleColor:[UIColor whiteColor]
                            AndTxtFont:FONT(12)
                              AndImage:nil
                    AndbackgroundColor:[UIApplication sharedApplication].keyWindow.tintColor
                        AndBorderColor:nil
                       AndCornerRadius:h * 0.5
                          WithIsRadius:YES
                   WithBackgroundImage:nil
                       WithBorderWidth:0];
        
        btnAdd.showsTouchWhenHighlighted = YES;
        [btnAdd addTarget:self
                   action:@selector(btnAddFriendAction:)
         forControlEvents:UIControlEventTouchUpInside];
        
        btnAdd.tag = tag;
        [cell.contentView addSubview:btnAdd];
    }
    
    NSArray *arrTemp = [self getListCellForSection:indexPath.section];
    if (arrTemp && [arrTemp count] > indexPath.row){
        
        NSDictionary *cellData = arrTemp[indexPath.row];
        NSString *strName = [NSString stringWithFormat:@"%@",cellData[@"aName"]];
        NSString *strUrl = @"";//暂无
        NSString *strPhone = [NSString stringWithFormat:@"%@",cellData[@"cellphone"]];
        
        //图像赋值
        if (strUrl.checkTextEmpty) {
            if ([strUrl hasPrefix:@"http"]) {
                [imgPic sd_setImageWithURL:strUrl.mj_url placeholderImage:K_DEFAULT_USER_PIC];
            }
            else{
                imgPic.image = [UIImage imageNamed:strUrl];
            }
        }
        else{
            imgPic.image = K_DEFAULT_USER_PIC;
        }
        
        //标题
        labTitle.text = strName;
        
        //好友
        BOOL isAlreadyFriend = [self isAlreadyFriendForPhone:strPhone];
        if (isAlreadyFriend) {
            btnAdd.enabled = NO;
            [btnAdd setTitle:@"已添加" forState:UIControlStateNormal];
            [btnAdd setBackgroundColor:[UIColor lightGrayColor]];
        }
        else{
            btnAdd.enabled = YES;
            [btnAdd setTitle:@"添加好友" forState:UIControlStateNormal];
            [btnAdd setBackgroundColor:[UIApplication sharedApplication].keyWindow.tintColor];
        }
    }
    
    cell.tag = indexPath.section;
    cell.contentView.tag = indexPath.row;
    
    return cell;
}


//MARK: - lazy load
- (UITableView *)listTableView{
    if (!_listTableView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight;
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,ZWStatusAndNavHeight , G_SCREEN_WIDTH, h)
                                                      style:UITableViewStylePlain];
        _listTableView.backgroundColor = [UIColor clearColor];
        
        //分割线
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _listTableView.separatorColor = G_EEF0F3_COLOR;
        
        //是否允许选中
        _listTableView.allowsSelection = YES;
        _listTableView.allowsMultipleSelection = NO;
        
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        
        _listTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        //防止顶部出现未知空白
//        if (@available(iOS 11.0, *)) {
//            _listTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
//        else {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
        
        //注册
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cell_identify];
    }
    return _listTableView;
}

- (JJTableViewIndexView *)tabbleIndexView{
    if (!_tabbleIndexView) {
        CGFloat w = 40;
        CGFloat h = 331;
        CGFloat y = (G_SCREEN_HEIGHT - h) * 0.5;
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
@end
