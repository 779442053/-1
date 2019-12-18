//
//  ZWGroudDetailViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWGroudDetailViewModel.h"

@implementation ZWGroudDetailViewModel
-(void)zw_initialize{
    @weakify(self)
    self.getGroupPeopleListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            [self.request POST:groupmember parameters:input success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"==群成员=%@",responseString)
                if (responseString && [responseString[@"code"] integerValue] == 1){
                    NSDictionary *_dicTemp = responseString[@"data"][@"data"];
                    //设置创建者编号
                    NSString *cid;
                    if (_dicTemp && [[_dicTemp allKeys] containsObject:@"createID"]) {
                        cid = [NSString stringWithFormat:@"%@",_dicTemp[@"createID"]];
                        [subscriber sendNext:@{@"code":@"0",@"res":_dicTemp[@"list"],@"cid":cid}];
                    }
                    if (_dicTemp && [[_dicTemp allKeys] containsObject:@"list"]) {
                        [subscriber sendNext:@{@"code":@"0",@"res":_dicTemp[@"list"]}];
                    }
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //推出群
    self.exitGroupWithGroupid = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSDictionary *dic = @{
            @"cmd":@"exitGroup",
            @"sessionId":[ZWUserModel currentUser].sessionID,
            @"groupid":input[@"groupid"],
            @"msg":input[@"msg"]
            };
            [self.request POST:@"" parameters:dic success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //删除自己创建的群
    self.deleteGroupWithGroupId = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSDictionary *dic = @{
            @"groupid":input[@"groupid"]
            };
            [self.request POST:deletegroup parameters:dic success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[@"code"] intValue] == 1) {
                    [YJProgressHUD showSuccess:@"删除成功"];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [YJProgressHUD showError:@"删除失败"];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"系统错误,请稍后再来"];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //打开或者关闭q群推送
    self.setGroupSDNCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
           return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
               @strongify(self)
               NSDictionary *dic = @{
               @"cmd":@"exitGroup",
               @"sessionId":[ZWUserModel currentUser].sessionID,
               @"groupid":input[@"groupid"],
               @"msg":input[@"msg"]
               };
               [self.request POST:@"" parameters:dic success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                   [subscriber sendCompleted];
               } failure:^(ZWRequest *request, NSError *error) {
                   [subscriber sendCompleted];
               }];
               return [RACDisposable disposableWithBlock:^{
                   
               }];
           }];
       }];
    //设置群聊天背景
    self.setGroupChatBg = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSDictionary *dic = @{
            @"cmd":@"exitGroup",
            @"sessionId":[ZWUserModel currentUser].sessionID,
            @"groupid":input[@"groupid"],
            @"msg":input[@"msg"]
            };
            [self.request POST:@"" parameters:dic success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
}
@end
