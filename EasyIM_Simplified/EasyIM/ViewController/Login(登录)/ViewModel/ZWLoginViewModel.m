//
//  ZWLoginViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWLoginViewModel.h"

@implementation ZWLoginViewModel
-(void)zw_initialize{
    @weakify(self);
    self.preLoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSDictionary * input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [YJProgressHUD showLoading:@"loading..."];
            NSMutableDictionary *parmay = [NSMutableDictionary dictionary];
            [self.request POST:PreLogin parameters:parmay success:^(ZWRequest *request, NSDictionary *responseString,NSDictionary *data) {
                [YJProgressHUD hideHUD];
                ZWWLog(@"===%@ === %@",responseString,data)
                if ([responseString[@"code"] intValue] == 1) {
                    [YJProgressHUD hideHUD];
                    //预登陆成功,待用户登录成功之后,开始配置socket环境.保存本地变量
                    if ([responseString[@"data"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = responseString[@"data"];
                        ZWUserModel *userModel = [ZWUserModel currentUser];
                        userModel.port = [dict[@"port"] intValue];//端口号
                        userModel.HostUrl = dict[@"webapi"];//接口地址,会变调
                        userModel.webrtc = dict[@"webrtc"];//socket  地址
                        userModel.host = dict[@"ip"];//IP地址
                        userModel.SocialApi = dict[@"SocialApi"];
                        userModel.IP = dict[@"ip"];
                        [ZWDataManager saveUserData];
                        [subscriber sendNext:@{@"code":@"0"}];
                        [subscriber sendCompleted];
                    }else{
                        NSString *message = [NSString stringWithFormat:@"预登陆失败,原因:%@",responseString[@"message"]];
                        [YJProgressHUD showError:message];
                        [subscriber sendNext:@{@"code":@"1"}];
                        [subscriber sendCompleted];
                    }
                }else{
                    [YJProgressHUD showError:responseString[@"message"]];
                    [subscriber sendNext:@{@"code":@"1"}];
                    [subscriber sendCompleted];
                }
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"系统错误,请稍后再来"];
                [subscriber sendError:error];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                ZWWLog(@"登录信号消失")
            }];
        }];
    }];
    
    self.LoginCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSDictionary * input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self);
            [YJProgressHUD showLoading:@"登录中..."];
            NSDictionary *parmay = input;
            [self.request POST:Login parameters:parmay success:^(ZWRequest *request, NSDictionary *responseString,NSDictionary *data) {
                [YJProgressHUD hideHUD];
                ZWWLog(@"=登录==%@",responseString[@"data"])
                if ([responseString[@"code"] intValue] == 1) {
                    [YJProgressHUD hideHUD];
                    //预登陆成功,待用户登录成功之后,开始配置socket环境.保存本地变量
                    if ([responseString[@"data"] isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = responseString[@"data"];
                        ZWUserModel *userModel = [ZWUserModel currentUser];
                         userModel.userId = dict[@"userId"];
                         userModel.token = dict[@"token"];
                        if (dict[@"username"] && !ZWWOBJECT_IS_EMPYT(dict[@"username"])) {
                            userModel.userName = dict[@"username"];
                        }else if (dict[@"nickName"] && !ZWWOBJECT_IS_EMPYT(dict[@"nickName"])) {
                            userModel.nickName = dict[@"nickName"];
                                
                            }
                         
                         userModel.userPsw = parmay[@"userPsw"];
                         userModel.domain = parmay[@"domain"];
                         userModel.isLogin = YES;
                         userModel.mobile = parmay[@"username"];
                        [ZWDataManager saveUserData];
                        [[NSNotificationCenter defaultCenter] postNotificationName:appLogin object:nil];
                        [ZWSaveTool setBool:YES forKey:@"IMislogin"];
                        [self LoginIMSever];
                        [subscriber sendNext:@{@"code":@"0"}];
                        [subscriber sendCompleted];
                    }else{
                        NSString *message = [NSString stringWithFormat:@"登陆失败,原因:%@",responseString[@"message"]];
                        [YJProgressHUD showError:message];
                        [subscriber sendNext:@{@"code":@"1"}];
                        [subscriber sendCompleted];
                    }
                }else{
                    [YJProgressHUD showError:responseString[@"message"]];
                    [subscriber sendNext:@{@"code":@"1"}];
                    [subscriber sendCompleted];
                }
            } failure:^(ZWRequest *request, NSError *error) {
                [YJProgressHUD showError:@"系统错误,请稍后再来"];
                [subscriber sendError:error];
                [subscriber sendCompleted];
            }];
            return [RACDisposable disposableWithBlock:^{
                ZWWLog(@"登录信号消失")
            }];
        }];
    }];
}

-(void)LoginIMSever{
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"type"] = @"req";
    parma[@"cmd"] = @"login";
    parma[@"xns"] = @"xns_user";
    parma[@"loginType"] = @"410";
    parma[@"deviceDesc"] = [UIDevice currentDevice].name;
    NSString *userName = [ZWUserModel currentUser].userName;
    NSString *mobil = [ZWUserModel currentUser].mobile;
    if (!ZWWOBJECT_IS_EMPYT(userName)) {
        parma[@"userName"] = userName;
    }else if (!ZWWOBJECT_IS_EMPYT(mobil)){
        parma[@"mobile"] = mobil;
    }else{
        [YJProgressHUD showError:@"缺少用户昵称,名字,账号"];
    }
    parma[@"userPsw"] = [ZWUserModel currentUser].userPsw;
    parma[@"domain"] = @"9000";
    parma[@"timeStamp"] = [MMDateHelper getNowTime];
    parma[@"oem"] = @"111";
    parma[@"enc"] = @"0";
    parma[@"zip"] = @"0";
    ZWWLog(@"登录IM= \n %@",parma)
    [ZWSocketManager ConnectSocketWithConfigM:[ZWSocketConfig ShareInstance] complation:^(NSError * _Nonnull error) {
        if (!error) {
            [ZWSocketManager SendDataWithData:parma];
        }
    }];
    

}
-(NSString *)HexStringWithData:(NSData *)data{
    Byte *bytes = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1){
            hexStr = [NSString stringWithFormat:@"%@ 0%@",hexStr,newHexStr];
        }
        else{
            hexStr = [NSString stringWithFormat:@"%@ %@",hexStr,newHexStr];
        }
    }
    hexStr = [hexStr uppercaseString];
    return hexStr;
}
@end
