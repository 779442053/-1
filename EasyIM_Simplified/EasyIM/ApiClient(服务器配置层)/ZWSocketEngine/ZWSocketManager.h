//
//  ZWSocketManager.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWSocketConfig.h"
#import "MMMessage.h"
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, SGSocketConnectState) {
    SGSocketConnectState_NotConnect = 1,     ///未连接
    SGSocketConnectState_ConnectSuccess = 2, ///连接成功
    SGSocketConnectState_ConnectFail = 3,    ///连接失败
    SGSocketConnectState_Connecting = 4,     ///正在连接
    SGSocketConnectState_ReConnecting = 5,   ///正在重新连接中
};
typedef void(^SocketConnectResponseBlock)(NSError * error);
typedef void (^SocketDidReadBlock)(NSError *__nullable error, id __nullable data);
@interface ZWSocketManager : NSObject

+ (instancetype)shareInstance;

/**
 获取连接状态

 @return <#return value description#>
 */
+ (SGSocketConnectState)SocketConnectState;

/**
 连接

 @param configM <#configM description#>
 */
+ (void)ConnectSocketWithConfigM:(ZWSocketConfig*)configM complation:(SocketConnectResponseBlock)complation;

/**
 断开连接

 */
+ (void)DisConnectSocket;

/**
 聊天,发送消息
 */
+ (void)SendMessageWithMessage:(MMMessage*)message complation:(SocketDidReadBlock)complation;;
//聊天,除相互发消息以外y所有操作
+ (void)SendDataWithData:(NSMutableDictionary*)parma complation:(SocketDidReadBlock)complation;
/**
 开启心跳定时器
 */
- (void)startPingTimer;

@end

NS_ASSUME_NONNULL_END
