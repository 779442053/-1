//
//  ZWContactsViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/27.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWContactsViewModel.h"
#import "ContactsModel.h"
#import "NewFriendModel.h"
@interface ZWContactsViewModel()
@property(nonatomic,assign) NSInteger page;
@end
@implementation ZWContactsViewModel
{
    int total;
    int current_page;
    int per_page;
}
-(void)zw_initialize{
     @weakify(self)
    self.requestCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSMutableDictionary *dict) {
        dispatch_async(dispatch_get_main_queue(), ^{
                      [YJProgressHUD showLoading:@"加载中..."];
            });
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            self.page = 0;
            NSMutableDictionary *parma = [NSMutableDictionary dictionary];
            parma[@"userid"] = [ZWUserModel currentUser].userId;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",self.page];
            parma[@"perpage"] = @"20";
            [self.request POST:getfriendlist parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                                    [YJProgressHUD hideHUD];
                           });
                
                if ([responseString[@"code"] intValue] == 1) {
                    NSArray *dataARR = [ContactsModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    total = [responseString[@"data"][@"page"][@"total"] intValue];
                    current_page = [responseString[@"data"][@"page"][@"current_page"] intValue];
                    per_page = [responseString[@"data"][@"page"][@"per_page"] intValue];
                    BOOL ismore;
                    if (total >= per_page) {
                        ismore = YES;
                    }else{
                         ismore = NO;
                    }
                    ZWWLog(@"total = %d current_page = %d per_page=%d",total,current_page,per_page)
                    [subscriber sendNext:@{@"code":@"0",@"res":dataARR,@"isMore":@(ismore)}];
                    [subscriber sendCompleted];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                             [YJProgressHUD showError:responseString[@"message"]];
                    });
                    
                    [subscriber sendNext:@{@"code":@"1",@"result":responseString[@"message"]}];
                    [subscriber sendCompleted];
                }
            } failure:^(ZWRequest *Request, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                        [YJProgressHUD showError:@"网络错误,请稍后再来"];
                });
                
                [subscriber sendError:error];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    self.requestMoreCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(NSMutableDictionary *dict) {
        [YJProgressHUD showLoading:@"加载中..."];
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            self.page ++;
            NSMutableDictionary *parma = [NSMutableDictionary dictionary];
            parma[@"userid"] = [ZWUserModel currentUser].userId;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",self.page];
            parma[@"perpage"] = @"20";
            [self.request POST:getfriendlist parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[@"code"] intValue] == 1) {
                    NSArray *dataARR = [ContactsModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    total = [responseString[@"data"][@"page"][@"total"] intValue];
                    current_page = [responseString[@"data"][@"page"][@"current_page"] intValue];
                    per_page = [responseString[@"data"][@"page"][@"per_page"] intValue];
                    BOOL ismore;
                    if (total >= per_page) {
                        ismore = YES;
                    }else{
                         ismore = NO;
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":dataARR,@"isMore":@(ismore)}];
                    [subscriber sendCompleted];
                }else{
                    [YJProgressHUD showError:responseString[@"message"]];
                    [subscriber sendNext:@{@"code":@"1",@"result":responseString[@"message"]}];
                    [subscriber sendCompleted];
                }
            } failure:^(ZWRequest *Request, NSError *error) {
                [YJProgressHUD hideHUD];
                [YJProgressHUD showError:@"网络错误,请稍后再来"];
                [subscriber sendError:error];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    self.restUserNameCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            NSString *userid = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
            parma[@"userid"] = userid;
            parma[@"muserid"] = input[@"muserid"];
            parma[@"musername"] = input[@"musername"];;
            [self.request POST:setmemo parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[@"code"] intValue] == 1) {
                    [YJProgressHUD showSuccess:@"修改成功"];
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
    //获取通知
    self.GetPushdataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"token"] = [ZWUserModel currentUser].token;
            [self.request POST:@"/api_im/friend/fetchBulletin" parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[code] intValue] == 1) {
                    NSArray *arr = [NewFriendModel  mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    if (arr.count) {
                        [subscriber sendNext:@{@"code":@"0",@"res":arr}];
                    }else{
                        [subscriber sendNext:@{@"code":@"1"}];
                    }
                }else if ([responseString[code] intValue] == 1020 && [responseString[msg] isEqualToString:@"登陆验证失败"]){
                    [subscriber sendNext:@{@"code":@"2"}];
                    [YJProgressHUD showError:responseString[msg]];
                }else{
                    [YJProgressHUD showError:responseString[msg]];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [MMProgressHUD showHUD:msg withDelay:1];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    ///获取通讯录里面的好友
    self.GetContactFriendCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"mobile"] = input;
            [self.request POST:getuserbymobile parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"通讯录里面的好友 = %@",responseString)
                if ([responseString[code] intValue] == 1) {
                    NSArray *arr = [NewFriendModel  mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    if (arr.count) {
                        [subscriber sendNext:@{@"code":@"0",@"res":arr}];
                    }else{
                        [subscriber sendNext:@{@"code":@"1"}];
                    }
                }else if ([responseString[code] intValue] == 1020 && [responseString[msg] isEqualToString:@"登陆验证失败"]){
                    [subscriber sendNext:@{@"code":@"2"}];
                    [YJProgressHUD showError:responseString[msg]];
                }else{
                    [YJProgressHUD showError:responseString[msg]];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [MMProgressHUD showHUD:msg withDelay:1];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];;
    
}
@end
