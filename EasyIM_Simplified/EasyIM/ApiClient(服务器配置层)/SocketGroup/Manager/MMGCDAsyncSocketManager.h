//
//  MMGCDAsyncSocketManager.h
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMGCDAsyncSocketManager : NSObject


/**
 *连接状态 1:已连接, -1未连接,0连接中
 */
@property (nonatomic, assign) NSInteger connectStatus;
//失败重连次数
@property (nonatomic, assign) NSInteger reconnectionCount;


/**
 获取单例

 @return 单例对象
 */
+ (nullable MMGCDAsyncSocketManager *)sharedInstance;

/**
 socket 连接

 @param delegate delegate
 */
- (void)connectSocketWithDelegate:(nonnull id)delegate;

/**
 socket 连接成功发送心跳

 @param beatBody 连接请求体
 */
- (void)socketDidConnectBeginSendBeat:(nonnull NSString *)beatBody;


/**
 socket 连接失败后重新连接

 @param reconnectBody 重新连接请求体
 */
- (void)socketDidDisconectBeginSendReconnect:(nonnull NSString *)reconnectBody;

/**
 向服务器发送数据

 @param data 数据
 */
- (void)socketWriteData:(nonnull NSString *)data;

/**
 socket 读取数据
 */
- (void)socketBeginReadData;

/**
 socket 主动断开连接
 */
- (void)disconnectSocket;

/**
 重设心跳次数
 */
- (void)resetBeatCount;

/**
 设置连接的host和port

 @param host IP地址
 @param port 端口
 */
- (void)changeHost:(nullable NSString *)host port:(NSInteger)port;


@end

NS_ASSUME_NONNULL_END
