//
//  ZWUserModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/13.
//  Copyright © 2019 step. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWUserModel : NSObject<NSCoding>
@property (nonatomic, copy) NSString *cmd; //Login
@property (nonatomic, copy) NSString *departId; //部门ID
@property (nonatomic, copy) NSString *err; //成功失败内容
@property (nonatomic, copy) NSString *meetingID; //会议ID
@property (nonatomic, copy) NSString *nickName; //nickname
@property (nonatomic, copy) NSString *photoUrl; //头像地址
@property (nonatomic, copy) NSString *type; //类型
@property (nonatomic, copy) NSString *result;//成功失败 1/0
@property (nonatomic, copy) NSString *sessionID; //sessionId
@property (nonatomic, copy) NSString *userId; //userid
@property (nonatomic, copy) NSString *userSig; //用户签名
@property (nonatomic, copy) NSString *userName; //名字
@property (nonatomic, copy) NSString *email; //邮箱
@property (nonatomic, copy) NSString *sex; //b性别 1男  2 女
@property (nonatomic, copy) NSString *mobile; //手机号
@property (nonatomic, copy) NSString *telephone;//固定电话
//@property (nonatomic, copy) NSString *Userremark;//个性签名
@property (nonatomic, copy) NSString *depart;//部门
@property (nonatomic, copy) NSString *company;//公司
@property (nonatomic,assign) double money;//金币
@property (nonatomic, copy) NSString *ver; //版本
@property (nonatomic, copy) NSString *xns; //协议
@property (nonatomic, copy) NSString *userPsw;
@property (nonatomic, copy) NSString *domain; 
@property (nonatomic, copy) NSString *host; // ip地址
@property (nonatomic, assign) NSInteger port; // 端口号
@property (nonatomic, copy) NSString * SocialApi;
@property (nonatomic, copy) NSString * IP;
@property (nonatomic, copy) NSString *webapi; // 预登陆返回的web接口地址
@property (nonatomic, copy) NSString *webrtc; // socket 长连接地址
/////**********************/////自己配置的用户全局数据
///是否登录
@property(nonatomic,assign)BOOL             isLogin;
@property(nonatomic,copy)NSString             *HostUrl;
@property(nonatomic,copy)NSString             *token;
+ (instancetype)currentUser;
@end

NS_ASSUME_NONNULL_END
