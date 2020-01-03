//
//  ZWGroudDetailViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWGroudDetailViewModel.h"

@implementation ZWGroudDetailViewModel
-(void)zw_initialize{
    @weakify(self)
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
                    NSString *cid;
                    if (_dicTemp && [[_dicTemp allKeys] containsObject:@"createID"]) {
                        cid = [NSString stringWithFormat:@"%@",_dicTemp[@"createID"]];
                        [subscriber sendNext:@{@"code":@"0",@"res":_dicTemp[@"list"],@"cid":cid}];
                    }
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
    //推出群
    self.exitGroupWithGroupid = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"exitGroup";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"groupID"] = input[@"groupid"];
            parma[@"msg"] = input[@"msg"];
            [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    //发出通知,更新界面UI
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //删除自己创建的群
    self.deleteGroupWithGroupId = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"groupid"] = input;
            [self.request POST:deletegroup parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                if ([responseString[@"code"] intValue] == 1) {
                    [YJProgressHUD showSuccess:@"解散成功"];
                    //发送通知,进行请求自己最近联系人
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [YJProgressHUD showError:@"删除失败"];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"解散错误,请稍后再来"];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //打开或者关闭q群推送
    self.setGroupSDNCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
           return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
               @strongify(self)
               [self.request POST:setusergroupnotify parameters:input success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                   if ([responseString[code] intValue] == 1) {
                       [subscriber sendNext:@{@"code":@"0"}];
                   }else{
                       [subscriber sendNext:@{@"code":@"1"}];
                   }
                   [subscriber sendCompleted];
               } failure:^(ZWRequest *request, NSError *error) {
                   [subscriber sendCompleted];
               }];
               return [RACDisposable disposableWithBlock:^{
                   
               }];
           }];
       }];
    //设置群聊天背景
    self.setGroupChatBg = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            NSDictionary *dic = @{
            @"cmd":@"exitGroup",
            @"sessionId":[ZWUserModel currentUser].sessionID,
            @"groupid":input[@"groupid"],
            @"msg":input[@"msg"]
            };
            [self.request POST:@"" parameters:dic success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //群主踢人
    self.kickPeopleFromGroupCommand =[[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"type"] = @"req";
            parma[@"cmd"] = @"kickGroupMember";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"memberID"] = input[@"memberID"] ;
            parma[@"class"] = @"0";
            parma[@"groupID"] = input[@"groupID"];
            parma[@"msg"] = input[@"msg"];
            [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    //创建群聊
    self.creatGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"name"] = input[@"name"];
            parma[@"photoUrl"] = input[@"photoUrl"];
            parma[@"friendID"] = input[@"friendID"];
            parma[@"type"] = @"req";
            parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
            parma[@"cmd"] = @"addGroup";
            parma[@"newpasswd"] = @"";
            parma[@"groupType"] = @"0";
            parma[@"bulletin"] = @"iOSAPP测试专用群";
            parma[@"theme"] = @"111";
            parma[@"mode"] = @"0";
            ZWWLog(@"创建群聊=%@",parma)
            [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
                if (!error) {
                    [YJProgressHUD showSuccess:@"创建群聊成功!"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil];
                    [subscriber sendNext:@{@"code":@"0"}];
                }else{
                    [YJProgressHUD showError:data[@"err"]];
                    [subscriber sendNext:@{@"code":@"1"}];
                }
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
    self.UploadImageToSeverCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(NSDictionary * input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            @strongify(self)
            [YJProgressHUD showLoading:@"发送中..."];
             NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
             NSString *Name;
             NSData *data;
            if ([input[@"code"] isEqualToString:@"image"]) {
                UIImage *uploadImage = input[@"res"];
                data = UIImageJPEGRepresentation(uploadImage, 0);
                parma[@"type"] = @"0";
                parma[@"file"] = data;
                Name = @"png";
            }else if ([input[@"code"] isEqualToString:@"arm"]){
                NSString *voicepath = input[@"res"];
                ZWWLog(@"luyin = %@",voicepath)
                data = [NSData dataWithContentsOfFile:voicepath];
                Name = @"wav";
                parma[@"type"] = @"1";
                parma[@"file"] = data;
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
    
    //搜搜群聊
    self.SearchGroupCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self)
        NSMutableDictionary *Parma = [[NSMutableDictionary alloc]init];
        Parma[@"keyword"] = input;
        [self.request POST:searchgroup parameters:Parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
            ZWWLog(@"搜索群聊=%@",responseString)
            if ([responseString[code] intValue] == 1) {
                [subscriber sendNext:@{@"code":@"0"}];
            }else{
                [subscriber sendNext:@{@"code":@"1"}];
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
