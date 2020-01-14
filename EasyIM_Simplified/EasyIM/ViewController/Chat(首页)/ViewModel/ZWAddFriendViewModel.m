//
//  ZWAddFriendViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWAddFriendViewModel.h"
#import "SearchFriendModel.h"
#import "MMGroupModel.h"
@interface ZWAddFriendViewModel()
@property(nonatomic,assign) NSInteger friendPage;
@property(nonatomic,assign) NSInteger GroupPage;
@end
@implementation ZWAddFriendViewModel
-(void)zw_initialize{
    @weakify(self)
    //添加好友
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
    
    //要求进群
    //需要先判断用户是否在群里.暂时找不到请求的接口
    self.addGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSMutableDictionary * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             //@strongify(self)
            //[YJProgressHUD showLoading:@"加载中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"joinGroup";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"groupID"] = input[@"groupID"];
            parma[@"creatorID"] = input[@"creatorID"];
            parma[@"msg"] = @"你好！我想加入该群";
            [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                [YJProgressHUD hideHUD];
                if (!error) {
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [subscriber sendCompleted];
            } ];
           
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //搜索好友
    self.searchFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            [YJProgressHUD showLoading:@"加载中..."];
            self.friendPage = 1;
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"keyword"] = input;
            parma[@"curPage"] = [NSString stringWithFormat:@"%ld",self.friendPage];
            parma[@"pageCount"] = @"20";
            [self.request POST:searchUser parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                ZWWLog(@"添加通讯录 = %@",responseString)
                if ([responseString[code] intValue] == 1) {
                    [MMProgressHUD showHUD:@"成功" withDelay:1];
                    NSArray *arr = [SearchFriendModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    [subscriber sendNext:@{@"code":@"0",@"res":arr}];
                }else{
                    [MMProgressHUD showError:responseString[msg]];
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD hideHUD];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //搜索更多好友
    self.searchMoreFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            self.friendPage++;
            [YJProgressHUD showLoading:@"加载中..."];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"keyword"] = input;
            parma[@"curPage"] = [NSString stringWithFormat:@"%ld",self.friendPage];
            parma[@"pageCount"] = @"20";
            [self.request POST:searchUser parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                ZWWLog(@"添加通讯录 = %@",responseString)
                if ([responseString[code] intValue] == 1) {
                    [MMProgressHUD showHUD:@"成功" withDelay:1];
                    NSArray *arr = [SearchFriendModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    [subscriber sendNext:@{@"code":@"0",@"res":arr}];
                }else{
                    [MMProgressHUD showError:responseString[msg]];
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD hideHUD];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //搜索群
    self.searchGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            [YJProgressHUD showLoading:@"加载中..."];
           self.GroupPage = 0;
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"keyword"] = input;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",self.GroupPage];;
            parma[@"perpage"] = @"20";
            [self.request POST:searchgroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"搜索群 = %@",responseString)
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
                    [MMProgressHUD showSuccess:@"成功"];
                    NSArray *arr = [MMGroupModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    [subscriber sendNext:@{@"code":@"0",@"res":arr}];
                }else{
                    [MMProgressHUD showError:responseString[msg]];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD hideHUD];
                [MMProgressHUD showError:ZWerror];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //搜索更多群
    self.searchMoreGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            [YJProgressHUD showLoading:@"加载中..."];
            self.GroupPage++;
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"keyword"] = input;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",self.GroupPage];;
            parma[@"perpage"] = @"20";
            [self.request POST:@"" parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"添加通讯录 = %@",responseString)
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 1) {
                 [MMProgressHUD showSuccess:@"成功"];
                 NSArray *arr = [MMGroupModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                        [subscriber sendNext:@{@"code":@"0",@"res":arr}];
                }else{
                   [MMProgressHUD showError:responseString[msg]];
                }
               [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD hideHUD];
                [MMProgressHUD showError:ZWerror];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
}
@end
