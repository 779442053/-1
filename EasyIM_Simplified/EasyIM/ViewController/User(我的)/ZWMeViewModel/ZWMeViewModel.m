//
//  ZWMeViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/3.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWMeViewModel.h"

@implementation ZWMeViewModel
-(void)zw_initialize{
    @weakify(self)
    self.getMyUserInfoCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"loading..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"userid"] = input;
            [self.request POST:userinfo parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
                    ZWUserModel *model = [ZWUserModel currentUser];
                    model.nickName = responseString[@"data"][@"nickname"];
                    model.userId = responseString[@"data"][@"userid"];
                    model.depart = responseString[@"data"][@"depart"];
                    model.photoUrl = responseString[@"data"][@"photoUrl"];
                    model.userSig = responseString[@"data"][@"usersig"];
                    model.email = responseString[@"data"][@"email"];
                    if (responseString[@"data"][@"sex"]) {
                        NSString *sex = responseString[@"data"][@"sex"];
                        if ([sex intValue] == 1 ) {
                            model.sex = @"男";
                        }else{
                            model.sex = @"女";
                        }
                    }
                    
                    [ZWDataManager saveUserData];
                    [subscriber sendNext:@{@"code":@"0"}];
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
    
    //添加好友
    self.addFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             //@strongify(self)
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
    self.add2GroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"joinGroup";
            parma[@"sessionID"] = [ZWUserModel currentUser].userId;
            parma[@"groupID"] = input;
            parma[@"msg"] = [NSString stringWithFormat:@"你好!我是%@，请求加入该群",[ZWUserModel currentUser].nickName];
            ZWWLog(@"添加群=%@",parma)
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
    
}
@end
