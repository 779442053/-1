//
//  MMForwardViewController.m
//  EasyIM
//
//  Created by momo on 2019/7/10.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMForwardViewController.h"


//MARK: - View
#import "AppDelegate.h"

//MARK: - Controller
#import "MMForward_FriendViewController.h"
#import "MMForward_GroupViewController.h"
#import "MMPopoverViewController.h"

//MARK: - Vernders
#import "UIViewController+MMPopover.h"

#define ButtonHeight 44.0f
#define Padding 15.0f

@interface MMForwardViewController ()<UITableViewDelegate,UITableViewDataSource,MMForwardDelegate>

//MARK: - 数据源
@property (nonatomic, strong) NSMutableArray *localArr;
@property (nonatomic, strong) NSMutableArray *selectDataArr;


@property (nonatomic, assign) BOOL isReload;

@end

@implementation MMForwardViewController

//- (instancetype)initWithMessageFrame:(MMMessageFrame *)messageF
//{
//    self = [super init];
//    if (self) {
//
//    }
//
//    return self;
//}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if (self.isReload) {
        [self reloadData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //1.创建Nav
    [self setupNav];
    
    //2.创建UI
    [self setupUI];
    
    //3.加载数据
    [self loadLocalData];
}

- (void)setupNav
{
    
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, ZWStatusBarHeight, SCREEN_WIDTH, ButtonHeight)];
    [navView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:navView];
    
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(Padding, 0, ButtonHeight, ButtonHeight);
    [leftBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [leftBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [leftBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    leftBtn.tag = 10;
    [leftBtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [navView addSubview:leftBtn];
    
    self.leftBtn = leftBtn;
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(SCREEN_WIDTH-ButtonHeight-Padding-ButtonHeight/2, 7, ButtonHeight+ButtonHeight/2, 30);
    [rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    rightBtn.tag = 110;
    [rightBtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];

    [navView addSubview:rightBtn];
    [rightBtn.layer setCornerRadius:15];
    [rightBtn.layer setMasksToBounds:YES];
    
    
    self.rightBtn = rightBtn;//0,202,254
    
    UILabel *titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"发送给"];
    [titleLabel setFont:[UIFont systemFontOfSize:17]];
    [navView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.centerY.mas_equalTo(navView.mas_centerY);
        make.height.mas_equalTo(44);
    }];
    
}

#pragma mark - Private

- (void)setupUI
{
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

- (void)loadLocalData
{
    WEAKSELF
    //1.取出本地所有联系人消息
    [[MMChatDBManager shareManager] getAllConversations:^(NSArray<MMRecentContactsModel *> * _Nonnull conversations) {
        
        [conversations enumerateObjectsUsingBlock:^(MMRecentContactsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MMCommonModel *cModel = [[MMCommonModel alloc] init];
            cModel.userId = obj.userId;
            cModel.name =obj.latestnickname;
            cModel.photoUrl = obj.latestHeadImage;
            cModel.isSelect = NO;
            [weakSelf.localArr addObject:cModel];
        }];
        
        //1.1.刷新表格
        [self.tableView reloadData];
    }];
}

- (void)hintFullForward
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"最多同时选择9个聊天会话" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:OKAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)reloadData
{
    _isReload = NO;
    
    
    [self.selectDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMCommonModel *cModel = (MMCommonModel *)obj;
        [self.localArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            MMCommonModel *rModel = (MMCommonModel *)obj;
            if ([cModel.userId isEqualToString:rModel.userId]) {
                rModel.isSelect = cModel.isSelect;
            }
        }];
    }];
    [self.tableView reloadData];
}

#pragma mark - Action

- (void)leftAction:(UIButton *)sender
{
    if (self.rightBtn.tag == 110) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    [sender setTitle:@"关闭" forState:UIControlStateNormal];
    
    self.rightBtn.tag = 110;
    self.rightBtn.selected = !self.rightBtn.selected;
    [self.rightBtn setTitle:@"多选" forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.rightBtn setBackgroundColor:[UIColor whiteColor]];
    [self.rightBtn setUserInteractionEnabled:YES];
    
    [self.selectDataArr removeAllObjects];
    
    [self.localArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMCommonModel *model = (MMCommonModel *)obj;
        model.isSelect = NO;
    }];
    
    [self.tableView reloadData];
}

- (void)rightAction:(UIButton *)sender
{
    
    if (sender.tag == 120 && self.selectDataArr.count) {
        
        MMLog(@"已经选择了%zd个准备转发",self.selectDataArr.count);
        [self messageF:self.selectDataArr];
        return;
    }
    
    sender.selected = !sender.selected;
    if (sender.selected) {
        sender.tag = 120;
        [sender setTitle:@"发送" forState:UIControlStateNormal];
        [sender setBackgroundColor:RGBCOLOR(148, 240, 255)];
        [self.leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [self.rightBtn setUserInteractionEnabled:NO];
        
    }else{
        sender.tag = 110;
        [sender setTitle:@"多选" forState:UIControlStateNormal];
    }
    [self.tableView reloadData];
}


#pragma mark - Getter&Setter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView=[[UITableView alloc] initWithFrame:CGRectMake(0.0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT-ZWStatusAndNavHeight) style:UITableViewStylePlain];
        [_tableView setDelegate:self];
        [_tableView setDataSource:self];
        [_tableView setSectionIndexBackgroundColor:[UIColor clearColor]];
        [_tableView setSectionIndexColor:[UIColor darkGrayColor]];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        //cell无数据时，不显示间隔线
        UIView *foot = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView setTableFooterView:foot];
        
    }
    return _tableView;
}

- (NSMutableArray *)selectDataArr
{
    if (!_selectDataArr) {
        _selectDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _selectDataArr;
}

- (NSMutableArray *)localArr
{
    if (!_localArr) {
        _localArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _localArr;
}

#pragma mark - UITableViewDelegate&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.rightBtn.tag == 110) {
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    switch (self.rightBtn.tag) {
        case 110:
            return self.localArr.count;
            break;
        case 120:
        {
            switch (section) {
                case 0:
                    return 2;
                    break;
                case 1:
                    return self.localArr.count;
                    break;

                default:
                    return 0;
                    break;
            }
        }
            break;
        default:
            return 0;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return G_GET_SCALE_HEIGHT(50.0f);
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.rightBtn.tag == 120 && section==0) {
        return 10;
    }
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if (self.rightBtn.tag == 120 && section==0) {
        return nil;
    }
    
    UIView *header = [[UIView alloc] init];
    [header setBackgroundColor:[UIColor whiteColor]];
    
    if (section == 0) {
        [header setBackgroundColor:RGBCOLOR(240, 240, 240)];
    }
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 50, 40)];
    textLabel.text = @"最近";
    [header addSubview:textLabel];
    
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.rightBtn.tag == 120 && indexPath.section == 0) {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"ForwardCell1"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"我的好友";
                break;
            case 1:
                cell.textLabel.text = @"我的群组";
                break;
            default:
                break;
        }
        
        return cell;
    }else{
        
        static NSString *identifier = @"ForwardCell2";
        
        MMForwardCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[MMForwardCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if (self.rightBtn.tag != 120 ) {
            cell.isEdit = NO;
        }else{
            cell.isEdit = YES;
        }
        
        if (self.localArr.count ) {
            MMCommonModel *model = self.localArr[indexPath.row];
            cell.model = model;
            if(model.isSelect){
                //设置选中图片
                cell.identifierImage.image = [UIImage imageNamed:@"group_selected"];
            }else {
                //设置未选中图片
                cell.identifierImage.image = [UIImage imageNamed:@"group_unSelected"];
            }
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = [[UIView alloc] init];
    [footer setBackgroundColor:RGBCOLOR(240, 240, 240)];
    return footer;
}

//MARK: - 选中或跳转

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.rightBtn.tag) {
        case 110:
        {
            MMLog(@"当个转发请求到此处");
            MMCommonModel *model = self.localArr[indexPath.row];
            [self.selectDataArr addObject:model];
//            [self messageF:self.selectDataArr];
            
            MMPopoverViewController *popoverView = [[MMPopoverViewController alloc] initWithDataSource:self.selectDataArr];
            [self mm_PresentController:popoverView completeHandle:^(BOOL presented) {
                if (presented) {
                    NSLog(@"弹出了");
                }else{
                    NSLog(@"消失了");
                }
            }];

        }
            break;
        case 120:
        {
            switch (indexPath.section) {
                case 0:
                {
                    switch (indexPath.row) {
                        case 0:
                        {
                            //MARK: - 我的好友
                            MMForward_FriendViewController *f_friend = [[MMForward_FriendViewController alloc] initWithSelectDataArr:self.selectDataArr];
                            f_friend.delegate = (id <MMForwardDelegate>) self;
                            [self.navigationController pushViewController:f_friend animated:YES];
                        }
                            break;
                        case 1:
                        {
                            //MARK: - 我的群组
                            MMForward_GroupViewController *f_group = [[MMForward_GroupViewController alloc] initWithSelectDataArr:self.selectDataArr];
                            f_group.forwardDelegate = (id <MMForwardDelegate>) self;
                            [self.navigationController pushViewController:f_group animated:YES];
                        }
                            break;

                        default:
                            break;
                    }

                }
                    break;
                case 1:
                {
                    
                    MMForwardCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                    MMCommonModel *cModel = _localArr[indexPath.row];
                    
                    if(cModel.isSelect){
                        
                        cModel.isSelect = NO;
                        
                        cell.identifierImage.image = [UIImage imageNamed:@"group_unSelected"];
                        [self.selectDataArr removeObject:cModel];
                        
                    }else {
                        
                        if (self.selectDataArr.count == 9) {
                            //Show Selected Full
                            [self hintFullForward];
                            return;
                        }
                        
                        cModel.isSelect = YES;
                        
                        cell.identifierImage.image = [UIImage imageNamed:@"group_selected"];
                        [self.selectDataArr addObject:cModel];
                    
                    }
                    
                    if (self.selectDataArr.count > 0) {
                        
                        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送(%zd)",self.selectDataArr.count] forState:UIControlStateNormal];
                        [self.rightBtn setBackgroundColor:RGBCOLOR(0, 202, 254)];
                        [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                        [self.rightBtn setUserInteractionEnabled:YES];
                    }else{
                        
                        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送"] forState:UIControlStateNormal];
                        [self.rightBtn setBackgroundColor:RGBCOLOR(148, 240, 255)];
                        [self.rightBtn setUserInteractionEnabled:NO];
                    }
                }
                    break;
                default:
                    break;
            }
        }
        default:
            break;
    }
}

#pragma mark - MMForwardDelegate

- (void)didSelectArr:(NSMutableArray *)arr
{
    
    [_selectDataArr removeAllObjects];
    [_selectDataArr addObjectsFromArray:arr];
    
    self.isReload = YES;

    [self setRightButtonStatus];
}

- (void)setRightButtonStatus
{
    if (self.selectDataArr.count > 0) {
        
        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送(%zd)",self.selectDataArr.count] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:RGBCOLOR(0, 202, 254)];
        [self.rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightBtn setUserInteractionEnabled:YES];
    }else{
        
        [self.rightBtn setTitle:[NSString stringWithFormat:@"发送"] forState:UIControlStateNormal];
        [self.rightBtn setBackgroundColor:RGBCOLOR(148, 240, 255)];
        [self.rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.rightBtn setUserInteractionEnabled:NO];
    }
}


#pragma mark - 转发请求

- (void)messageF:(NSMutableArray *)messageArr
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(forwardMessageData:)]) {
        [self.delegate forwardMessageData:messageArr];
    }
}

@end
