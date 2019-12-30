//
//  ZWChatViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWChatViewModel.h"
#import "MMRecentContactsModel.h"

#import "NewFriendModel.h"
@interface ZWChatViewModel()
@property (nonatomic,assign)NSInteger *Currentpage;
@end
@implementation ZWChatViewModel
-(void)zw_initialize{
    @weakify(self)//开始连接socket=登录处理
    self.socketContactCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [ZWSocketManager ConnectSocketWithConfigM:[ZWSocketConfig ShareInstance] complation:^(NSError * _Nonnull error) {
                if (!error) {//说明连接上了
                    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
                    parma[@"type"] = @"req";
                    parma[@"cmd"] = @"login";
                    parma[@"xns"] = @"xns_user";
                    parma[@"loginType"] = @"410";
                    parma[@"deviceDesc"] = [UIDevice currentDevice].name;
                    parma[@"userName"] = [ZWUserModel currentUser].userName;
                    parma[@"userPsw"] = [ZWUserModel currentUser].userPsw;
                    parma[@"domain"] = @"9000";
                    parma[@"timeStamp"] = [MMDateHelper getNowTime];
                    parma[@"oem"] = @"xire";
                    parma[@"enc"] = @"0";
                    parma[@"zip"] = @"0";
                    [ZWSocketManager SendDataWithData:parma] ;
                    
                    [subscriber sendNext:@"0"];
                }else{
                    [subscriber sendNext:@"1"];
                    [MMProgressHUD showError:@"socket 连接出现错误"];
                }
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];

    self.requestCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            self.Currentpage = 0;
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"targettype"] = input;
            parma[@"page"] = [NSString stringWithFormat:@"%ld",(long)self.Currentpage];
            parma[@"perpage"] = @"20";
            [self.request POST:getusernormal parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
               // ZWWLog(@"最近联系人=%@",responseString)
                if ([responseString[code] intValue] == 1) {
                    //获取到最近联系人,将s本地数据库进行更新操作
                    //targettype 2最近联系人(默认) 12常用联系人 3最近群组 13常用群组4最近会议 14 常用会议
                    
                    
                }else if ([responseString[code] intValue] == 1020 && [responseString[@"message"] isEqualToString:@"登陆验证失败"]){
                    [subscriber sendNext:@{@"code":@"2"}];
                    [YJProgressHUD showError:responseString[msg]];
                }else{
                    [subscriber sendNext:@{@"code":@"1"}];
                    [MMProgressHUD showError:responseString[msg]];
                }
                [subscriber sendCompleted];
            } failure:^(ZWRequest *request, NSError *error) {
                [MMProgressHUD showError:ZWerror];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    //获取通知的消息
    self.GetPushdataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
             @strongify(self)
            NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
            parma[@"token"] = [ZWUserModel currentUser].token;
            [self.request POST:@"/api_im/friend/fetchBulletin" parameters:parma success:^(ZWRequest *request, NSMutableDictionary *responseString, NSDictionary *data) {
                ZWWLog(@"登录之后,获取系统所有的通知 = %@",responseString)
                if ([responseString[code] intValue] == 1) {
                    NSArray *arr = [NewFriendModel  mj_objectArrayWithKeyValuesArray:responseString[@"data"][@"data"]];
                    [subscriber sendNext:@{@"code":@"0",@"res":arr}];
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
           [ZWSocketManager SendDataWithData:parma];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                
            }];
        }];
    }];
    
}
@end
