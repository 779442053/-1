//
//  ZWCallViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2020/1/6.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWCallViewModel.h"

@implementation ZWCallViewModel
-(void)zw_initialize{
    @weakify(self)
    self.GetFriendStatedCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
             NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
                       parma[@"userid"] = input;
                       [self.request POST:userinfo parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                           ZWWLog(@"获取用户在线状态=%@",responseString)
                           if ([responseString[code] intValue] == 1) {
                               NSDictionary *dict = responseString[@"data"];
                               [subscriber sendNext:@{@"code":@"0",@"res":dict}];
                           }else{
                               [YJProgressHUD showError:responseString[msg]];
                               [subscriber sendNext:@{@"code":@"1"}];
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
