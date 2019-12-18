//
//  MMPwdModifyViewController.m
//  EasyIM
//
//  Created by momo on 2019/7/24.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMPwdModifyViewController.h"
#import "ZWSetUpViewModel.h"
#import "AppDelegate.h"
#import "LoginVC.h"

@interface MMPwdModifyViewController ()

@property (strong, nonatomic)  UITextField *oldField;
@property (strong, nonatomic)  UITextField *changeField;
@property (strong, nonatomic)  UITextField *sChangeField;
@property (strong, nonatomic)  ZWSetUpViewModel *ViewModel;
@end

@implementation MMPwdModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"密码修改"];
    [self showLeftBackButton];
}
-(void)zw_addSubviews{
    UILabel *toplb = [[UILabel alloc]initWithFrame:CGRectMake(13, ZWStatusAndNavHeight +17, 200, 12)];
    toplb.text = @"原密码";
    toplb.textColor = [UIColor colorWithHexString:@"#666666"];
    toplb.font = [UIFont zwwNormalFont:12];
    [self.view addSubview:toplb];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(toplb.frame) + 11, KScreenWidth, 46)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    self.oldField.frame = CGRectMake(14, 0, KScreenWidth - 28, 46);
    [topView addSubview:self.oldField];
    
    UILabel *toplb1 = [[UILabel alloc]initWithFrame:CGRectMake(13, CGRectGetMaxY(topView.frame) + 23, 200, 12)];
    toplb1.text = @"新密码";
    toplb1.textColor = [UIColor colorWithHexString:@"#666666"];
    toplb1.font = [UIFont zwwNormalFont:12];
    [self.view addSubview:toplb1];
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(toplb1.frame) + 11, KScreenWidth, 100)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    self.changeField.frame = CGRectMake(14, 0, KScreenWidth - 28, 46);
    [bottomView addSubview:self.changeField];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(11, 47, KScreenWidth - 11, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
    [bottomView addSubview:lineView];
    
    self.sChangeField.frame = CGRectMake(14, CGRectGetMaxY(lineView.frame), KScreenWidth - 28, 46);
    [bottomView addSubview:self.changeField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(11, CGRectGetMaxY(bottomView.frame) + 33, KScreenWidth - 22, 44);
    [button setTitle:@"确认" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont zwwNormalFont:13];
    [button addTarget:self
              action:@selector(rightAction)
    forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor colorWithHexString:@"#01A1EF"];
    button.layer.cornerRadius = 5;
    button.layer.masksToBounds = YES;
    [self.view addSubview:button];
}
//MARK: - Action 保存

- (void)rightAction
{
    [self.view endEditing:YES];
    
    NSString *msg = @"";
    if (self.oldField.text.length == 0) {
        msg = @"请输入旧密码";
        [MMProgressHUD showHUD:msg];
        return;
    }else if(![self.changeField.text checkUsername:16]){
        [MMProgressHUD showHUD:@"旧密码为6-16为长度字母或数字组成"];
        return;
    }else if (self.changeField.text.length < 6 || self.changeField.text.length >16) {
        msg = @"请输入正确的长度";
        [MMProgressHUD showHUD:msg];
        return;
    }else if (self.sChangeField.text.length == 0) {
        msg = @"请确认新密码";
        [MMProgressHUD showHUD:msg];
        return;
    } else if (![self.changeField.text isEqualToString:self.sChangeField.text]) {
        msg = @"两次输入的密码不一致请重新输入";
        [MMProgressHUD showHUD:msg];
        return;
    }
    [[self.ViewModel.changePswCommand execute:self.changeField.text] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [self delayAction];
        }
    }];
    
}
- (void)delayAction
{
    AppDelegate *appDelegate =  [AppDelegate shareAppDelegate];
    appDelegate.window.rootViewController = [LoginVC new];
}
-(UITextField *)oldField{
    if (_oldField == nil) {
        _oldField = [[UITextField alloc]init];
        _oldField.placeholder = @"请输入原密码";
        _oldField.font = [UIFont zwwNormalFont:13];
    }
    return _oldField;
}
-(UITextField *)changeField{
    if (_changeField == nil) {
        _changeField = [[UITextField alloc]init];
        _changeField.placeholder = @"请输入新密码";
        _changeField.font = [UIFont zwwNormalFont:13];
    }
    return _changeField;
}
-(UITextField *)sChangeField{
    if (_sChangeField == nil) {
        _sChangeField = [[UITextField alloc]init];
        _sChangeField.placeholder = @"请再次输入新密码";
        _sChangeField.font = [UIFont zwwNormalFont:13];
    }
    return _sChangeField;
}
-(ZWSetUpViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWSetUpViewModel alloc]init];
    }
    return _ViewModel;
}
@end
