//
//  ZWProfileEditerViewController.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWProfileEditerViewController.h"
#import "ZWWTextView.h"
#import "ZWProfilViewModel.h"
@interface ZWProfileEditerViewController ()
@property(nonatomic,strong)ZWWTextView *messageTFView;
@property (nonatomic ,strong) UIButton *button;
@property(nonatomic,strong)ZWProfilViewModel *ViewModel;
@end

@implementation ZWProfileEditerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:self.Type];
    [self showLeftBackButton];
    if ([self.Type isEqualToString:@"请设置昵称"]) {
        self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 50);
    }else if ([self.Type isEqualToString:@"请设置邮箱"]){
        self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 50);
        self.messageTFView.keyboardType = UIKeyboardTypeEmailAddress;
    }else if ([self.Type isEqualToString:@"请设置您的签名"]){
        self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 110);
    }else if ([self.Type isEqualToString:@"请设置手机号"]){
        self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 50);
        self.messageTFView.keyboardType = UIKeyboardTypeNamePhonePad;
    }else if ([self.Type isEqualToString:@"请设置群名称"]){
        self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 50);//请编辑群公告
        self.messageTFView.keyboardType = UIKeyboardTypeDefault;
    }else if ([self.Type isEqualToString:@"请编辑群公告"]){
       self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 110);
        self.messageTFView.keyboardType = UIKeyboardTypeDefault;
    }else{
        self.messageTFView.frame = CGRectMake(12, ZWStatusAndNavHeight +15, KScreenWidth - 36, 110);
    }
    [self.view addSubview:self.messageTFView];
    [self.messageTFView wyh_CornerRadius:3 RectCornerType:UIRectCornerAllCorners];
    
    self.button.frame = CGRectMake(12, CGRectGetMaxY(self.messageTFView.frame) + 40, KScreenWidth - 24, 50);
    [self.view addSubview:self.button];
    self.button.layer.cornerRadius = 3;
    self.button.layer.masksToBounds = YES;
    
}
-(void)zw_bindViewModel{
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if ([self.Type isEqualToString:@"请设置昵称"]) {
            if (self.messageTFView.text.length) {
                [[self.ViewModel.updateUserInfoCommand execute:@{@"nickname":self.messageTFView.text,@"code":@"0"}] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        if (self.confirmIdentity) {
                            self.confirmIdentity(self.messageTFView.text);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [YJProgressHUD showError:@"昵称不能为空"];
            }
        }else if ([self.Type isEqualToString:@"请设置邮箱"]){
            if (self.messageTFView.text.length && [self.messageTFView.text checkTextEmpty]) {
                [[self.ViewModel.updateUserInfoCommand execute:@{@"email":self.messageTFView.text,@"code":@"1"}] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        if (self.confirmIdentity) {
                            self.confirmIdentity(self.messageTFView.text);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [YJProgressHUD showError:@"请输入正确邮箱地址"];
            }
        }else if ([self.Type isEqualToString:@"请设置您的签名"]){
            if (self.messageTFView.text.length) {
                [[self.ViewModel.updateUserInfoCommand execute:@{@"usersig":self.messageTFView.text,@"code":@"2"}] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        if (self.confirmIdentity) {
                            self.confirmIdentity(self.messageTFView.text);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [YJProgressHUD showError:@"请输入您的签名"];
            }
        }else if ([self.Type isEqualToString:@"请设置手机号"]){
            if (self.messageTFView.text.length) {
                [[self.ViewModel.updateUserInfoCommand execute:@{@"mobile":self.messageTFView.text,@"code":@"4"}] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        if (self.confirmIdentity) {
                            self.confirmIdentity(self.messageTFView.text);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [YJProgressHUD showError:@"请输入您的手机号"];
            }
        }else if ([self.Type isEqualToString:@"请设置群名称"]){
           if (self.messageTFView.text.length) {
               [[self.ViewModel.UpdateGroupNameCommand execute:@{@"groupname":self.messageTFView.text,@"code":@"name",@"groupid":self.GroupID}] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        if (self.confirmIdentity) {
                            self.confirmIdentity(self.messageTFView.text);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [YJProgressHUD showError:@"请设置群名称"];
            }
        }else if ([self.Type isEqualToString:@"请编辑群公告"]){
            if (self.messageTFView.text.length) {
               [[self.ViewModel.UpdateGroupNameCommand execute:@{@"bulletin":self.messageTFView.text,@"code":@"0",@"groupid":self.GroupID}] subscribeNext:^(id  _Nullable x) {
                    if ([x[@"code"] intValue] == 0) {
                        if (self.confirmIdentity) {
                            self.confirmIdentity(self.messageTFView.text);
                        }
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }];
            }else{
                [YJProgressHUD showError:@"请编辑群公告"];
            }
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }];
}
-(ZWWTextView *)messageTFView{
    if (_messageTFView == nil) {
        _messageTFView = [[ZWWTextView alloc] init];
        _messageTFView.placeholder = self.Type;
        _messageTFView.font = [UIFont zwwNormalFont:12];
        _messageTFView.textColor = [UIColor colorWithHexString:@"#464646"];
        _messageTFView.editable = YES;
    }
    return _messageTFView;
}
- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"确定" forState:UIControlStateNormal];
        _button.titleLabel.tintColor = [UIColor whiteColor];
        [_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _button.titleLabel.font = [UIFont zwwNormalFont:15];
        _button.backgroundColor = [UIColor colorWithHexString:@"#01A1EF"];
    }
    return _button;
}
-(ZWProfilViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWProfilViewModel alloc]init];
    }
    return _ViewModel;
}
@end
