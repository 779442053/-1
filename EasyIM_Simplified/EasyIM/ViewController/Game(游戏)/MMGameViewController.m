//
//  MMGameViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMGameViewController.h"
#import "ZWDataManager.h"
//Views
#import "MMGameCell.h"


//Model
#import "MMGameModel.h"
#import "MMGameLoginModel.h"

//Venders
#import <DGSDK/DGSDKHandle.h>
#import <DGSDK/DGGameId.h>


#define TABLEVIEWCOLOR RGBCOLOR(239, 239, 244)

static NSString *const identifier = @"gameCell";


@interface MMGameViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) BOOL isRender;
@property (nonatomic, assign) BOOL isLogout;

@end

@implementation MMGameViewController

#pragma mark - Init

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self interfaceOrientation:UIInterfaceOrientationPortrait];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"游戏"];
    //1.初始化UI
    [self setupUI];
    
    //2.监听推送
    [self addObserverAction];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_isRender) {
        _isRender = YES;
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.mas_equalTo(self.view);
            make.top.mas_equalTo(self.view.mas_top).with.mas_offset(ZWStatusAndNavHeight);
        }];
    }
}


#pragma mark - Private

- (void)setupUI
{
    self.isLogout = YES;
    [self.view addSubview:self.tableView];
}

- (void)addObserverAction
{
    //监听SDK推送=----- 可选择
    //准备进入SDK
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DGSDKWillEnterGame) name:@"DGSDKWILLENTERGAME" object:nil];
    //进入SDK -- token登录成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DGSDKEnteredGame) name:@"DGSDKENTEREDGAME" object:nil];
    //已经退出SDK
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DGSDKExitedGame) name:@"DGSDKEXITEDGAME" object:nil];
    
    //进入SDK失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(DGSDKEnterGameFail:) name:@"DGSDKENTEREDGAMEFAIL" object:nil];
}

//强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark - Getter

-(UITableView *)tableView
{
    if (! _tableView) {
        _tableView = [[UITableView alloc]
                      initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, KScreenWidth, KScreenHeight - ZWStatusAndNavHeight - ZWTabbarHeight)
                      style:UITableViewStylePlain];
        _tableView.delegate = (id<UITableViewDelegate>)self;
        _tableView.dataSource = (id<UITableViewDataSource>)self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.backgroundColor = TABLEVIEWCOLOR;
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [_tableView registerClass:[MMGameCell class] forCellReuseIdentifier:identifier];
        
    }
    return _tableView;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
        
        /** 测试数据*/
        NSArray *nameArr = @[@"进入百家乐",@"进入龙虎斗",@"进入牛牛"];
        NSArray *imageArr = @[@"game_bjl",@"game_fight",@"game_nn"];
        for (int i = 0; i< nameArr.count; i++) {
            MMGameModel *model = [[MMGameModel alloc] init];
            model.iconImageStr = imageArr[i];
            model.name = nameArr[i];
            [_dataSource addObject:model];
        }
    }
    return _dataSource;
}

#pragma mark - UITableViewDataSource && UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMGameCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (self.dataSource && [self.dataSource count] > indexPath.row) {
        cell.gameModel = self.dataSource[indexPath.row];
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 167.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 如果没有退钱成功 则让其返回重新登录
    if (!_isLogout) {
        [MMProgressHUD showHUD:@"游戏异常,请重新登录!" withDelay:0.38];
        return;
    }
    int lobbyType = DGBACCARAT;
    switch (indexPath.row) {
        case 0:
            // 百家乐
            lobbyType = DGBACCARAT;
            break;
        case 1:
            // 龙虎斗
            lobbyType = DGDRAGON;
            break;
        case 2:
            // 牛牛
            lobbyType = DGBULL;
            break;
            
        default:
            break;
    }
    
    NSString *url = @"https://www.game001.club/api/app/registerOrLoginDG";
    NSDictionary *dic = @{
                          @"username":[[NSUserDefaults standardUserDefaults] stringForKey:K_APP_LOGIN_USER],
                          @"password":[YHUtils md5HexDigest:[[NSUserDefaults standardUserDefaults] stringForKey:K_APP_LOGIN_PWD]],
                          @"amount":@([ZWUserModel currentUser].money).description,
                          @"winLimit":@"0",
                          @"data":@"A"
                          };
    
    [MMProgressHUD showHUD];
    [[MMApiClient sharedClient] POSTFormData:url parameters:dic success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MMProgressHUD hideHUD];
            });
            MMGameLoginModel *model = [MMGameLoginModel mj_objectWithKeyValues:responseObject[@"data"]];
            [DGSDKHANDLE DGSDKLoginWithToken:model.dgLogin.token withViewController:self withGameID:lobbyType withLoadDGGameLoading:NO withMinBet:0];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [MMProgressHUD hideHUD];
                [MMProgressHUD showHUD:responseObject[@"msg"] withDelay:1.5];
            });
            NSLog(@"获取TOKEN失败!");
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"请求TOKEN失败!");
        dispatch_async(dispatch_get_main_queue(), ^{
            [MMProgressHUD hideHUD];
            [MMProgressHUD showHUD:error.localizedDescription withDelay:1.5];
        });
    }];
}
#pragma mark - 游戏部分
#pragma mark - 监听SDK推送
- (void)DGSDKWillEnterGame
{
    NSLog(@"即将进入SDK");
}

- (void)DGSDKEnteredGame
{
    NSLog(@"已经进入SDK ");
}

//失败回调
/*
 
 key:DGError
 
 数据加载失败的回调，i 有三个类型
 SocketNetError = 0;    socket链接失败
 MemberInitError = 1;   会员初始化失败
 MemberStop = 2;        会员账号暂停
 */
- (void)DGSDKEnterGameFail:(NSNotification *)notifier
{
    NSDictionary *dicError = notifier.object;
    int code = [dicError[@"DGError"] intValue];
    NSLog(@"SDK失败状态码。。。。 %d",code);
}

- (void)DGSDKExitedGame
{
    NSLog(@"已经退出SDK");
//    [self logoutSDK];
    [self accountOut];
}


- (void)logoutSDK{
    [DGSDKHANDLE DGSDKAccountLogout];
}

- (void)accountOut
{
    NSString *url = @"https://www.game001.club/api/app/registerOrLoginDG";
    NSDictionary *dic = @{
                          @"username":[[NSUserDefaults standardUserDefaults] stringForKey:K_APP_LOGIN_USER],
                          @"password":[YHUtils md5HexDigest:[[NSUserDefaults standardUserDefaults] stringForKey:K_APP_LOGIN_PWD]],
                          @"winLimit":@"0",
                          };
    [MMProgressHUD showHUD];
    [[MMApiClient sharedClient] POSTFormData:url parameters:dic success:^(id  _Nonnull responseObject) {
        if ([responseObject[@"code"] integerValue] == 1) {


            dispatch_async(dispatch_get_main_queue(), ^{
                [MMProgressHUD hideHUD];
            });

            NSString *blance = responseObject[@"blance"];

            ZWUserModel *info = [ZWUserModel currentUser];
            info.money = [blance doubleValue];
            [ZWDataManager saveUserData];

            self.isLogout = YES;

        }else{

            self.isLogout = NO;

            dispatch_async(dispatch_get_main_queue(), ^{
                [MMProgressHUD showHUD:responseObject[@"msg"] withDelay:0.38];
            });
        }

    } failure:^(NSError * _Nonnull error) {
        self.isLogout = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [MMProgressHUD showHUD:error.userInfo.description withDelay:0.38];
        });
    }];

}


@end
