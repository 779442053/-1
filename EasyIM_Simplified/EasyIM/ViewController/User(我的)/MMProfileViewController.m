//
//  MMProfileViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/23.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMProfileViewController.h"
#import "BaseUIView.h"
#import "ZWProfilViewModel.h"
#import "ZWProfileCell.h"
#import "ZWProfileEditerViewController.h"
//二维码
#import "QRCodeViewController.h"

static NSString *const identifier = @"ZWProfileCell";
@interface MMProfileViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSMutableArray *profiles;
@property(nonatomic,strong)ZWProfilViewModel *ViewModel;
@property(nonatomic,copy)NSString *HeadImageUrl;
@property(nonatomic,copy)NSString *sexstring;
@end

@implementation MMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"个人资料"];
    [self showLeftBackButton];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(KScreenWidth - 44 - 20, ZWStatusBarHeight, 44, 44);
//    [button setTitle:@"保存" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor colorWithHexString:@"#01A1EF"] forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont zwwNormalFont:13];
//    [button addTarget:self
//              action:@selector(rightAction)
//    forControlEvents:UIControlEventTouchUpInside];
//    [self.navigationView addSubview:button];
     [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
}
-(void)zw_bindViewModel{
    [[self.ViewModel.requestCommand execute:[ZWUserModel currentUser].userId] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [self.tableView reloadData];
        }
    }];
}
#pragma mark - 保存修改
- (void)rightAction
{
//    [self.view endEditing:YES];
//    if (!self.sexstring || self.sexstring.length == 0 || !self.HeadImageUrl || self.HeadImageUrl.length == 0) {
//        [YJProgressHUD showSuccess:@"用户信息修改成功"];
//    }else{
//        //NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
//        //parma[@""]
//    }
    
}
#pragma mark - UITableViewDelegate UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.profiles.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.profiles[section];
    return arr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZWProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[ZWProfileCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    NSString *headImage = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].photoUrl)?@"空":[ZWUserModel currentUser].photoUrl ;
    NSString *phone = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].mobile)?@"请设置手机号":[ZWUserModel currentUser].mobile;
    NSString *nickname = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].nickName)?@"请设置昵称":[ZWUserModel currentUser].nickName;
    NSString *zhanghao = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].userId)?@"你的账号是?":[NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    NSString *qrcode = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].mobile)?@"空":[ZWUserModel currentUser].mobile;
    NSString *sex = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].sex)?@"请设置性别":[[ZWUserModel currentUser].sex intValue] == 1 ?@"男":@"女";//1 男  2 女
    NSString *email = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].email)?@"请设置邮箱":[ZWUserModel currentUser].email;
    NSString *remark = ZWWOBJECT_IS_EMPYT([ZWUserModel currentUser].userSig)?@"请设置您的签名":[ZWUserModel currentUser].userSig;
    NSArray *subARR = @[@[headImage,phone,nickname,zhanghao,qrcode],@[sex,email,remark]];
    [cell updateWithTitle:self.profiles[indexPath.section][indexPath.row] subTitle:subARR[indexPath.section][indexPath.row] indexPath:indexPath];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            return 76.0f;
        }
        return 45.0f;
    }
    return 45;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headView = [[UIView alloc]init];
    headView.backgroundColor = [UIColor colorWithHexString:@"#EAEBEA"];
    return headView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 8;
    }else{
        return 17;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                __block typeof(self) weakSelf = self;
                [BaseUIView createPhotosAndCameraPickerForMessage:@"图片信息来源"
                                               andAlertController:^(UIAlertController * _Nullable _alertVC) {
                                                   [weakSelf presentViewController:_alertVC animated:YES completion:nil];
                                               }
                                    withImagePickerController:^(UIImagePickerController * _Nullable _imgPickerVC) {
                                            _imgPickerVC.delegate = self;
                                            [weakSelf presentViewController:_imgPickerVC animated:YES completion:nil];
                                        }];

            }
                break;
            case 1:
            {
                ZWProfileEditerViewController *mUser = [[ZWProfileEditerViewController alloc] init];
                mUser.Type = @"请设置手机号";
                mUser.confirmIdentity = ^(NSString * _Nonnull Vuale) {
                    [ZWUserModel currentUser].mobile = Vuale;
                    [ZWDataManager saveUserData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                };
                [self.navigationController pushViewController:mUser animated:YES];
            }
                break;
            case 2:
            {
                ZWProfileEditerViewController *mUser = [[ZWProfileEditerViewController alloc] init];
                mUser.Type = @"请设置昵称";
                mUser.confirmIdentity = ^(NSString * _Nonnull Vuale) {
                    [ZWUserModel currentUser].nickName = Vuale;
                    [ZWDataManager saveUserData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                };
                [self.navigationController pushViewController:mUser animated:YES];
            }
                break;
            case 4:
            {
                QRCodeViewController *mUser  = [[QRCodeViewController alloc]initWithType:0 AndFromId:[ZWUserModel currentUser].userId AndFromName:[ZWUserModel currentUser].nickName WithFromPic:[ZWUserModel currentUser].photoUrl];
                [self.navigationController pushViewController:mUser animated:YES];
            }
                break;
            default:
                break;
        }
    }else{
        switch (indexPath.row) {
            case 0:
            {
                [self alterSexPortrait];
            }
                break;
            case 1:
            {
                ZWProfileEditerViewController *mUser = [[ZWProfileEditerViewController alloc] init];
                mUser.Type = @"请设置邮箱";
                mUser.confirmIdentity = ^(NSString * _Nonnull Vuale) {
                    [ZWUserModel currentUser].email = Vuale;
                    [ZWDataManager saveUserData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                };
                [self.navigationController pushViewController:mUser animated:YES];
            }
            break;
            case 2:
            {
                ZWProfileEditerViewController *mUser = [[ZWProfileEditerViewController alloc] init];
                mUser.Type = @"请设置您的签名";
                mUser.confirmIdentity = ^(NSString * _Nonnull Vuale) {
                    [ZWUserModel currentUser].userSig = Vuale;
                    [ZWDataManager saveUserData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                };
                [self.navigationController pushViewController:mUser animated:YES];
            }
            break;
            default:
                break;
        }
    }
    
}
-(void)alterSexPortrait{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择性别" preferredStyle:UIAlertControllerStyleActionSheet];
    //按钮：男
    [alert addAction:[UIAlertAction actionWithTitle:@"男" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.sexstring = @"男";
        [[self.ViewModel.updateUserInfoCommand execute:@{@"code":@"3",@"sex":@"1"}] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [ZWUserModel currentUser].sex = @"1";
                [ZWDataManager saveUserData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        
    }]];
    //按钮：女
    [alert addAction:[UIAlertAction actionWithTitle:@"女" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        self.sexstring = @"女";
        [[self.ViewModel.updateUserInfoCommand execute:@{@"code":@"3",@"sex":@"2"}] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [ZWUserModel currentUser].sex = @"2";
                [ZWDataManager saveUserData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 图片压缩后再上传服务器
    // 保存路径
    UIImage *simpleImg = [UIImage simpleImage:orgImage];
    self.filePath = [[MMMediaManager sharedManager] saveImage:simpleImg];
    [self sendFileWithFilePath:simpleImg];
}
#pragma mark - Private
- (void)sendFileWithFilePath:(UIImage *)filePath
{
    [YJProgressHUD showLoading:@"照片上传中..."];
    NSData *data = UIImageJPEGRepresentation(filePath, 0.8);
    //UIImage *Image = [UIImage imageWithData:data];
    [[self.ViewModel.uploadUserImageCommand execute:data] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            self.HeadImageUrl = x[@"res"];
            [ZWUserModel currentUser].photoUrl = x[@"res"];
            [ZWDataManager saveUserData];
            [YJProgressHUD showSuccess:@"图片上传成功"];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
    }];
}
-(ZWProfilViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWProfilViewModel alloc]init];
    }
    return _ViewModel;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT - ZWStatusAndNavHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ZWProfileCell class] forCellReuseIdentifier:identifier];
    }
    return _tableView;
}
- (UIImagePickerController *)imagePicker
{
    if (nil == _imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.modalPresentationStyle = UIModalPresentationCustom;
        _imagePicker.view.backgroundColor = [UIColor grayColor];
        _imagePicker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    }
    return _imagePicker;
}
- (NSMutableArray *)profiles
{
    if(!_profiles){
        _profiles = [[NSMutableArray alloc] init];
        NSArray *sectionarr = @[@"头像",@"手机号",@"昵称",@"账号",@"我的二维码"];
        NSArray *sectionarr2 = @[@"性别",@"邮箱",@"个人签名"];
        [_profiles addObj:sectionarr];
        [_profiles addObj:sectionarr2];
    }
    return _profiles;
}


@end
