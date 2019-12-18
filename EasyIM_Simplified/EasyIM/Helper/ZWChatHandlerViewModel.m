//
//  ZWChatHandlerViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/18.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWChatHandlerViewModel.h"

@implementation ZWChatHandlerViewModel
-(void)zw_initialize{
    @weakify(self)
    self.uploadFileCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"发送中..."];
            NSString *uploadUrl = input[@"res"];
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"file"] = input[@"image"];
            [self.request uploadFile:uploadUrl withFileData:input[@"image"] mimeType:@"file" name:@"png" parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
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
    //张威威
    self.GetuploadFileUrlCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [self.request POST:queryFileUpApiUrl parameters:@{} success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[code] intValue] == 1) {
                    NSString *imageurl;
                    if (responseString[@"data"]) {
                        imageurl = responseString[@"data"][@"data"][@"uploadApi1"];
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":imageurl}];
                }else{
                    [YJProgressHUD showError:responseString[msg]];
                    [subscriber sendNext:@{@"code":@"1",@"res":responseString[msg]}];
                }
                [subscriber sendCompleted];
            }failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:ZWerror];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];;
}
@end
