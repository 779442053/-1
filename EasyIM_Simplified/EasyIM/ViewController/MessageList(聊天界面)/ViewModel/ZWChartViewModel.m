//
//  ZWChartViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWChartViewModel.h"

@implementation ZWChartViewModel
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
}
@end
