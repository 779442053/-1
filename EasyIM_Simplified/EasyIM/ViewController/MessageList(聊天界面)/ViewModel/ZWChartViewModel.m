//
//  ZWChartViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWChartViewModel.h"
#import "ZWGroupModel.h"
@interface ZWChartViewModel()
@property(nonatomic,assign) NSInteger page;
@end
@implementation ZWChartViewModel
{
    int total;
    int current_page;
    int per_page;
}
-(void)zw_initialize{
    @weakify(self)
    self.GetChartLishDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSDictionary *parma = input;
            [self.request POST:getmsghis parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"liao聊天记录=%@",responseString)
                [YJProgressHUD showLoading:@"loading..."];
                if ([responseString[@"code"] intValue] == 1) {
                    NSMutableArray *array = [NSMutableArray array];
                    if (responseString[@"data"][@"data"]){
                        NSArray *result = responseString[@"data"][@"data"];
                        result = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                            NSString *time1 = obj1[@"dTime"];
                            NSString *time2 = obj2[@"dTime"];
                            return [time2 compare:time1]; //降序
                        }];
                        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"isInsert":@"YES"}];
                            [dic addEntriesFromDictionary:obj];
                           NSDictionary *dict = @{
                                                  @"list":@{@"user":dic}
                                                  };
                           //2.2.1对应处理数据
                           [[MMClient  sharedClient] addHandleChatMessage:dict];
                        }];
                        ZWWLog(@"==========result=%@",result)
                        [array addObjectsFromArray:result];
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":array}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [YJProgressHUD hideHUD];
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"系统错误,请稍后再来"];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
            }];
        }];
    }];
    self.GetGroupChartLishDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSDictionary *parma = input;
            [self.request POST:getgroupmsghis parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"群聊天记录=%@",responseString)
                [YJProgressHUD showLoading:@"loading..."];
                if ([responseString[@"code"] intValue] == 1) {
                    NSMutableArray *array = [NSMutableArray array];
                    if (responseString[@"data"][@"data"]){
                        NSArray *result = responseString[@"data"][@"data"][@"msg"];
                        NSString *strGroupName = [NSString stringWithFormat:@"%@",responseString[@"data"][@"data"][@"groupName"]];
                        result = [result sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                            NSString *time1 = obj1[@"dTime"];
                            NSString *time2 = obj2[@"dTime"];
                            return [time2 compare:time1]; //降序
                        }];
                         [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                             NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:@{@"isInsert":@"YES",@"groupName":strGroupName}];
                             [dic addEntriesFromDictionary:obj];
                             NSDictionary *dict = @{
                                                    @"list":@{@"group":dic}
                                                    };
                             //2.2.1对应处理数据
                             [[MMClient  sharedClient] addHandleGroupMessage:dict];
                         }];
                        ZWWLog(@"==========result=%@",result)
                        [array addObjectsFromArray:result];
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":array}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [YJProgressHUD hideHUD];
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"系统错误,请稍后再来"];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
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
            [self.request POST:getfriendgroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
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
            [self.request POST:getfriendgroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
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
    //获取c群成员
    self.getGroupPeopleListCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            NSMutableDictionary *parma  = [[NSMutableDictionary alloc]init];
            parma[@"groupid"] = input;
            parma[@"page"] = @"0";
            parma[@"perpage"] = @"100";
            [self.request POST:groupmember parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"==群成员=%@",responseString)
                if (responseString && [responseString[@"code"] integerValue] == 1){
                    NSDictionary *_dicTemp = responseString[@"data"][@"data"];
                    //设置创建者编号
//                    NSString *cid;
//                    if (_dicTemp && [[_dicTemp allKeys] containsObject:@"createID"]) {
//                        cid = [NSString stringWithFormat:@"%@",_dicTemp[@"createID"]];
//                        [subscriber sendNext:@{@"code":@"0",@"res":_dicTemp[@"list"],@"cid":cid}];
//                    }
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
    
    
}
@end
