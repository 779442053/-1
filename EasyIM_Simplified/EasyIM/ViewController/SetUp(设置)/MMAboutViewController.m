//
//  MMAboutViewController.m
//  EasyIM
//
//  Created by momo on 2019/7/25.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMAboutViewController.h"

#import "MMAboutCell.h"

@interface MMAboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArr;

@end

@implementation MMAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)zw_addSubviews{
    [self setTitle:@"关于"];
    [self showLeftBackButton];
    [self.view addSubview:self.tableView];
}
#pragma mark - Getter

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, G_SCREEN_HEIGHT-ZWStatusAndNavHeight) style:UITableViewStylePlain];
        _tableView.delegate        = self;
        _tableView.dataSource      = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;

    }
    return _tableView;
}

- (NSArray *)titleArr
{
    if (!_titleArr) {
        _titleArr = @[
                      @"版本更新",
                      @"意见反馈",
                      @"去评分"
                      ];
    }
    return _titleArr;
}


#pragma mark - UITableViewDelegate&&UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            MMAboutCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"MMAboutCell" owner:nil options:nil] lastObject];
            return cell;
        }
            break;
            
        default:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = FONT(15);
            cell.textLabel.text = self.titleArr[indexPath.row -1];
            return cell;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 248.0f;
            break;
            
        default:
            return 50.0f;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        //MARK:检查版本更新
        case 1:
            [self checkVersion];
            break;
            
        //MARK:意见反馈
        case 2:
        {
            [MMProgressHUD showHUD:@"意见反馈"];
        }
            break;
            
        //MARK:去评分
        case 3:
        {
             [MMProgressHUD showHUD:@"去评分"];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Request

#pragma mark - Request

- (void)checkVersion
{
    NSDictionary *dict = @{
                           @"api_token":K_APP_FIR_IM_TOKEN,
                           };
    [[MMApiClient sharedClient] GET:K_APP_FIR_IM_URL parameters:dict success:^(id  _Nonnull responseObject) {
        MMLog(@"FIR返回的请求数据:%@",responseObject);
        
        if (responseObject) {
            NSString *onlineBuild = [NSString stringWithFormat:@"%@",responseObject[@"build"]];
            
            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
            NSString *appBuild = [infoPlist objectForKey:@"CFBundleVersion"];
            
            NSString *message;
            UIAlertAction *preAction;
            UIAlertAction *sureAction;
            
            if ([appBuild floatValue] < [onlineBuild floatValue] ) {
                message = [NSString stringWithFormat:@"\n%@",responseObject[@"changelog"]];
                preAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    NSString *str = responseObject[@"installUrl"];
                    NSString *encodedString = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    
                    NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",encodedString];
                    
                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
                    }
                }];
            }
            else{
                message = @"当前已是最新版本";
                sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
            }
            
            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"发现新版本"
                                                                              message:@"" preferredStyle:UIAlertControllerStyleAlert];
            //样式调整
            NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
            paragraph.alignment = NSTextAlignmentLeft;
            [alertControllerMessageStr setAttributes:@{NSParagraphStyleAttributeName:paragraph} range:NSMakeRange(0, alertControllerMessageStr.length)];
            
            [alertCtr setValue:alertControllerMessageStr forKey:@"attributedMessage"];
            
            if (preAction) {
                [alertCtr addAction:preAction];
            }
            else if(sureAction){
                [alertCtr addAction:sureAction];
            }
            
            [self presentViewController:alertCtr animated:YES completion:nil];
        }
    } failure:^(NSError * _Nonnull error) {
        [MMProgressHUD showHUD:MMDescriptionForError(error)];
    }];
}


//- (void)checkVersion
//{
//
//    NSDictionary *dict = @{
//                           @"api_token":K_APP_FIR_IM_TOKEN,
//                           };
//
//    [[MMApiClient sharedClient] GET:K_APP_FIR_IM_URL parameters:dict success:^(id  _Nonnull responseObject) {
//        MMLog(@"FIR返回的请求数据:%@",responseObject);
//
//        if (responseObject) {
//            NSString *onlineBuild = [NSString stringWithFormat:@"%@",responseObject[@"build"]];
//
//            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
//            NSString *appBuild = [infoPlist objectForKey:@"CFBundleVersion"];
//
//            NSString *message;
//            UIAlertAction *preAction;
//            UIAlertAction *sureAction;
//
//            if ([appBuild floatValue] < [onlineBuild floatValue] ) {
//                message = [NSString stringWithFormat:@"\n%@",responseObject[@"changelog"]];
//                preAction = [UIAlertAction actionWithTitle:@"更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//                    NSString *str = responseObject[@"installUrl"];
//                    NSString *encodedString = [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//
//                    NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@",encodedString];
//
//                    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlStr]]) {
//                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
//                    }
//                }];
//            }
//            else{
//                message = @"\n当前已是最新版本";
//                sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//
//                }];
//            }
//
//            UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"版本检测"
//                                                                              message:@"" preferredStyle:UIAlertControllerStyleAlert];
//            //样式调整
//            NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
//            NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
//            paragraph.alignment = NSTextAlignmentLeft;
//            [alertControllerMessageStr setAttributes:@{NSParagraphStyleAttributeName:paragraph} range:NSMakeRange(0, alertControllerMessageStr.length)];
//
//            [alertCtr setValue:alertControllerMessageStr forKey:@"attributedMessage"];
//
//            if (preAction) {
//                [alertCtr addAction:preAction];
//            }
//            else if(sureAction){
//                [alertCtr addAction:sureAction];
//            }
//
//            [self presentViewController:alertCtr animated:YES completion:nil];
//        }
//    } failure:^(NSError * _Nonnull error) {
//        [MMProgressHUD showHUD:MMDescriptionForError(error)];
//    }];
//}


@end
