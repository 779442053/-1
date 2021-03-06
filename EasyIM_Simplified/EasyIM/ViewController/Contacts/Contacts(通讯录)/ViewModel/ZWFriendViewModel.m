//
//  ZWFriendViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWFriendViewModel.h"
#import "SearchFriendModel.h"
@implementation ZWFriendViewModel
-(void)zw_initialize{
    //添加好友
    @weakify(self)
    self.addFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            // @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"addFriend";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"toID"] = input;
            parma[@"msg"] = [NSString stringWithFormat:@"你好!我是%@，请求加您为好友",[ZWUserModel currentUser].nickName];
            ZWWLog(@"添加朋友=%@",parma)
           [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
               if (!error) {
                   [subscriber sendNext:@{@"code":@"0"}];
               }else{
                   [subscriber sendNext:@{@"code":@"1"}];
               }
               [subscriber sendCompleted];
           }];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    
    
    self.acceptFriendCommand =  [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            // @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"acceptFriend";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"toID"] = input;
            parma[@"time"] = [MMDateHelper getNowTime];
            parma[@"msg"] = @"你好!通过添加好友，我们可以聊天啦";
            ZWWLog(@"接受好友请求=%@",parma)
            [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                }
            }];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    self.rejectFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"rejectFriend";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"toID"] = input;
            parma[@"time"] = [MMDateHelper getNowTime];
            parma[@"msg"] = @"对方拒绝你的好友请求";
            ZWWLog(@"拒绝好友请求=%@",parma)
            [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"0"}];
                }
            }];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //设置好友备注
    self.setmemoFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"loading..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"userid"] = [ZWUserModel currentUser].userId;;
            parma[@"muserid"] = input[@"muserid"] ;
            parma[@"musername"] = input[@"musername"];;
            parma[@"musernotice"] = input[@"musernotice"];
            [self.request POST:setmemo parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
                    [YJProgressHUD showSuccess:@"设置成功!"];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
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
    
    self.GetUserInfoCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
           NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"muserid"] = [ZWUserModel currentUser].userId;
            parma[@"userid"] = input;
            [self.request POST:userinfo parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"获取好友信息=%@",responseString)
                if ([responseString[code] intValue] == 1) {
                    SearchFriendModel *Model = [SearchFriendModel mj_objectWithKeyValues:responseString[@"data"]];
                    [subscriber sendNext:@{@"code":@"0",@"res":Model}];
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
    
    //删除好友
    self.deleteUserCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSString * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"friendid"] = input;
            parma[@"userid"] = [ZWUserModel currentUser].userId;
            [self.request POST:delfriend parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[@"code"] intValue] == 1) {
                    [[MMChatDBManager shareManager] deleteConversation:input completion:^(NSString * _Nonnull aConversationId, NSError * _Nonnull aError) {
                        if (!aError) {
                            ZWWLog(@"成功")
                        }else{
                            ZWWLog(@"失败")
                        }
                    }];
                    [YJProgressHUD showSuccess:@"删除成功"];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                    [YJProgressHUD showError:responseString[@"message"]];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"系统错误,请稍后再来"];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
}
@end
