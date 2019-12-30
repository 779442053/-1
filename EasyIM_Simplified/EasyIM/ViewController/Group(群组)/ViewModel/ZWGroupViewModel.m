//
//  ZWGroupViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/27.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWGroupViewModel.h"
#import "ZWGroupModel.h"
@interface ZWGroupViewModel()
@property(nonatomic,assign) NSInteger page;
@end
@implementation ZWGroupViewModel
{
    int total;
    int current_page;
    int per_page;
}
-(void)zw_initialize{
    @weakify(self)
    self.requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            dispatch_async(dispatch_get_main_queue(), ^{
                                 [YJProgressHUD showLoading:@"加载中..."];
                       });
            @strongify(self)
            self.page = 0;
            NSMutableDictionary *parma = [NSMutableDictionary dictionary];
            parma[@"userid"] = [ZWUserModel currentUser].userId;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",self.page];
            parma[@"perpage"] = @"20";
            [self.request POST:getgroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                                    [YJProgressHUD hideHUD];
                           });
                ZWWLog(@"我的群组=%@",responseString)
                if ([responseString[@"code"] intValue] == 1) {
                    NSArray *dataARR = [ZWGroupModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
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
    
    self.requestMoreCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            dispatch_async(dispatch_get_main_queue(), ^{
                                 [YJProgressHUD showLoading:@"加载中..."];
                       });
            @strongify(self)
            self.page++;
            NSMutableDictionary *parma = [NSMutableDictionary dictionary];
            parma[@"userid"] = [ZWUserModel currentUser].userId;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",self.page];
            parma[@"perpage"] = @"20";
            [self.request POST:getgroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                                    [YJProgressHUD hideHUD];
                           });
                if ([responseString[@"code"] intValue] == 1) {
                    NSArray *dataARR = [ZWGroupModel mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
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
    
    //添加好友或者群
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
            }];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
}
@end
