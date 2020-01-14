//
//  ZWRegistViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWRegistViewModel.h"

@implementation ZWRegistViewModel
-(void)zw_initialize{
    @weakify(self);
       self.RegistCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSDictionary * input) {
           return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
               @strongify(self);
               [YJProgressHUD showLoading:@"注册中..."];
               NSMutableDictionary *parmay = [NSMutableDictionary dictionary];
               parmay[@"userpsw"] = input[@"userpsw"];
               parmay[@"mobile"] = input[@"mobile"];
               [self.request POST:Regist parameters:parmay success:^(ZWRequest *request, NSDictionary *responseString,NSDictionary *data) {
                   [YJProgressHUD hideHUD];
                   ZWWLog(@"===%@ === %@",responseString,data)
                   if ([responseString[@"code"] intValue] == 1) {
                       [YJProgressHUD hideHUD];
                       //预登陆成功,待用户登录成功之后,开始配置socket环境.保存本地变量
                       if ([responseString[@"data"] isKindOfClass:[NSDictionary class]]) {
                           ZWUserModel *userModel = [ZWUserModel currentUser];
                           userModel.mobile = input[@"mobile"];
                           [ZWDataManager saveUserData];
                           [subscriber sendNext:@{@"code":@"0"}];
                           [subscriber sendCompleted];
                       }else{
                           NSString *message = [NSString stringWithFormat:@"注册失败,原因:%@",responseString[msg]];
                           [YJProgressHUD showError:message];
                           [subscriber sendNext:@{@"code":@"1"}];
                           [subscriber sendCompleted];
                       }
                   }else{
                       ZWWLog(@"注册失败方法")
                       [MMProgressHUD showError:responseString[msg]];
                       [subscriber sendNext:@{@"code":@"1"}];
                       [subscriber sendCompleted];
                   }
               } failure:^(ZWRequest *request, NSError *error) {
                   [YJProgressHUD showError:@"系统错误,请稍后再来"];
                   [subscriber sendError:error];
                   [subscriber sendCompleted];
               }];
               return [RACDisposable disposableWithBlock:^{
                   ZWWLog(@"登录信号消失")
               }];
           }];
       }];
    
    self.CodeCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self);
            [YJProgressHUD showLoading:@"发送中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc] init];
            parma[@"mobile"] = input;
            [self.request POST:SendCode parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
                    [YJProgressHUD showSuccess:@"验证码发送成功"];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                    [YJProgressHUD showError:responseString[msg]];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:ZWerror];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
}
@end
