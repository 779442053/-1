//
//  ZWProfilViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWProfilViewModel.h"

@implementation ZWProfilViewModel
-(void)zw_initialize{
    @weakify(self)
    self.requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"loading..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"userid"] = input;
            //parma[@"muserid"] = input;
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
    
    self.updateUserInfoCommand =[[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"修改中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"userid"] = [ZWUserModel currentUser].userId;
            if ([input[@"code"] intValue] == 0) {
                parma[@"nickname"] = input[@"nickname"];
            }else if ([input[@"code"] intValue] == 1){
                parma[@"email"] = input[@"email"];
            }else if ([input[@"code"] intValue] == 2){
                //签名
                parma[@"usersig"] = input[@"usersig"];
            }else if ([input[@"code"] intValue] == 3){
                //性别   1.男  2.女
                parma[@"sex"] = input[@"sex"];
            }else if ([input[@"code"] intValue] == 4){
                parma[@"mobile"] = input[@"mobile"];
            }
            [self.request POST:update parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
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
    
    self.uploadUserImageCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"修改中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"file"] = input;
            [self.request uploadFile:updateuserphoto withFileData:input mimeType:@"file" name:@"png" parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[code] intValue] == 1) {
                    NSString *imageurl;
                    if (responseString[@"data"]) {
                        imageurl = responseString[@"data"][@"url"];
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":imageurl}];
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
    
    //修改群名称
    self.UpdateGroupNameCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"修改中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"groupid"] = input[@"groupid"];
            if ([input[@"code"] isEqualToString:@"name"]) {
                parma[@"groupname"] = input[@"groupname"];
            }else{
                parma[@"bulletin"] = input[@"bulletin"];
            }
            [self.request POST:modifygroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                ZWWLog(@"修改群信息=%@",responseString)
                if ([responseString[code] intValue] == 1) {
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
}
@end
