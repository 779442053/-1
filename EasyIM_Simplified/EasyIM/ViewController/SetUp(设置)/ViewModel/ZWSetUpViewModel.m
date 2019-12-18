//
//  ZWSetUpViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWSetUpViewModel.h"

@implementation ZWSetUpViewModel
-(void)zw_initialize{
    @weakify(self)
    self.changePswCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"修改中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"password"] = input;
            [self.request POST:ResetPsw parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
                    [YJProgressHUD showSuccess:@"修改成功"];
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
