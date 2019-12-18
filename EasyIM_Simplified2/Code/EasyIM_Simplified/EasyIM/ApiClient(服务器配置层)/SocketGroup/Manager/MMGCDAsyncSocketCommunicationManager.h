//
//  MMGCDAsyncSocketCommunicationManager.h
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMConnectConfig.h"
#import "XMLDictionary.h"
NS_ASSUME_NONNULL_BEGIN

/**
 业务类型

 - MMRequestType_beat: 心跳
 - MMRequestType_login: 登陆
 - MMRequestType_getConversationsList: 获取会话列表
 - MMRequestType_sendMsg: 发送消息
 - MMRequestType_checkUserOnline: 检查用户是否在线
 - MMRequestType_vedio: 视频请求
 - MMRequestType_hangUp: 挂断
 - MMRequestType_logout: 退出登陆
 - MMRequestType_connectionAuthAppraisal: 连接鉴权
 */
typedef NS_ENUM(NSInteger, MMRequestType) {
    MMRequestType_beat = 1,
    MMRequestType_login,
    MMRequestType_getConversationsList,
    MMRequestType_sendMsg,
    MMRequestType_sendGroupMsg,
    MMRequestType_checkUserOnline,
    MMRequestType_vedio,
    MMRequestType_hangUp,
    MMRequestType_addFriend,
    MMRequestType_acceptCall,
    MMRequestType_rejectCall,
    MMRequestType_logout,
    MMRequestType_connectionAuthAppraisal,
    ////////////////////////////////////
    MMRequestType_joinChatRoom,
    MMRequestType_exitChatRoom,
    MMRequestType_sendChatRoomMsg
};


/**
 *  socket 连接状态
 */
typedef NS_ENUM(NSInteger, MMSocketConnectStatus) {
    MMSocketConnectStatusDisconnected = -1,  // 未连接
    MMSocketConnectStatusConnecting = 0,     // 连接中
    MMSocketConnectStatusConnected = 1       // 已连接
};

typedef void (^SocketDidReadBlock)(NSError *__nullable error, id __nullable data);

@protocol MMSocketDelegate <NSObject>

@optional


/**
 *  连上时
 */
- (void)socketDidConnect;


@end


@interface MMGCDAsyncSocketCommunicationManager : NSObject

// 连接状态
@property (nonatomic, assign, readonly) MMSocketConnectStatus connectStatus;

// 当前请求通道
@property (nonatomic, strong, nonnull) NSString *currentCommunicationChannel;

// socket 回调
@property (nonatomic, weak, nullable) id<MMSocketDelegate> socketDelegate;

/**
 获取单例

 @return 单例对象
 */
+ (nullable MMGCDAsyncSocketCommunicationManager *)sharedInstance;

/**
 初始化 socket

 @param config 主机地址和端口号
 */
- (void)createSocketWithConfig:(nonnull MMConnectConfig *)config;

/**
 *  socket断开连接
 */
- (void)disconnectSocket;

/**
 向服务器发送数据

 @param type 请求类型
 @param body 请求体
 @param callback 结果返回
 */
- (void)socketWriteDataWithRequestType:(MMRequestType)type
                           requestBody:(nonnull NSString *)body
                            completion:(nullable SocketDidReadBlock)callback;


@end

NS_ASSUME_NONNULL_END
