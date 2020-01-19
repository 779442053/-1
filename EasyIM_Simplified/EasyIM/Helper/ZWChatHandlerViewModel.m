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
    
    self.UploadImageToSeverCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"发送中..."];
             NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
             NSString *Name;
             NSData *data;
            if ([input[@"code"] isEqualToString:@"image"]) {
                NSString *imagepath = input[@"res"];
                UIImage * uploadImage = [[MMMediaManager sharedManager] imageWithLocalPath:imagepath];
                data = UIImageJPEGRepresentation(uploadImage, 0);
                parma[@"type"] = @"0";
                parma[@"file"] = data;
                Name = @"png";
            }else if ([input[@"code"] isEqualToString:@"arm"]){
                NSString *voicepath = input[@"res"];
                data = [NSData dataWithContentsOfFile:voicepath];
                Name = @"wav";
                parma[@"type"] = @"1";
                parma[@"file"] = data;
            }else if ([input[@"code"] isEqualToString:@"mov"]){
                data = input[@"res"];
                Name = @"mp4";
                parma[@"type"] = @"1";
                parma[@"file"] = data;
                ZWWLog(@"上传短视频参数 = %@",parma)
            }
            
            [self.request upload:@"/api_im/friend/uploadimg" withFileData:data mimeType:@"file" name:Name parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 0) {
                    ZWWLog(@"聊天上传文件得到路径 = %@",responseString)
                    NSString *imageurl;
                    if (responseString[@"imgurl"]) {
                        NSArray *arr = responseString[@"imgurl"];
                        imageurl = arr.firstObject;
                    }else{
                        imageurl = @"";
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":imageurl}];
                }else{
                    [YJProgressHUD showError:responseString[msg]];
                    [subscriber sendNext:@{@"code":@"1",@"res":responseString[msg]}];
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
    
    //上传短视频
    self.UploadVideoToSeverCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSData * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"发送中..."];
             NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
             NSString *Name;
             NSData *data;
             data = input;
             Name = @"mp4";
             parma[@"type"] = @"1";
             parma[@"file"] = data;
             ZWWLog(@"上传短视频参数 = %@",parma)
            [self.request upload:@"/api_im/friend/uploadimg" withFileData:data mimeType:@"file" name:Name parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [YJProgressHUD hideHUD];
                if ([responseString[code] intValue] == 0) {
                    ZWWLog(@"聊天上传文件得到路径 = %@",responseString)
                    NSString *imageurl;
                    if (responseString[@"imgurl"]) {
                        NSArray *arr = responseString[@"imgurl"];
                        imageurl = arr.firstObject;
                    }else{
                        imageurl = @"";
                    }
                    [subscriber sendNext:@{@"code":@"0",@"res":imageurl}];
                }else{
                    [YJProgressHUD showError:responseString[msg]];
                    [subscriber sendNext:@{@"code":@"1",@"res":responseString[msg]}];
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
