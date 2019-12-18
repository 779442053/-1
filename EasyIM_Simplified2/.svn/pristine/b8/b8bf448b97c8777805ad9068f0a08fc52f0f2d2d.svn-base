//
//  MMChatHandler.h
//  EasyIM
//
//  Created by momo on 2019/4/18.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMChatHandlerDelegate <NSObject>

@required

//接收消息代理
- (void)didReceiveMessage:(ICMessage *)chatModel type:(ICMessageType)messageType;

@optional
//发送消息超时代理
- (void)sendMessageTimeOutWithTag:(long)tag;

@end

@interface MMChatHandler : NSObject

//聊天单例
+ (instancetype)shareInstance;

//添加代理
- (void)addDelegate:(id<MMChatHandlerDelegate>)delegate delegateQueue:(dispatch_queue_t)queue;
//移除代理
- (void)removeDelegate:(id<MMChatHandlerDelegate>)delegate;
//发送消息
- (void)sendMessage:(ICMessage *)chatModel timeOut:(NSUInteger)timeOut tag:(long)tag;


//发送文本消息
- (void)sendTextMessage:(ICMessage *)textModel;

//发送语音消息
- (void)sendAudioMessage:(ICMessage *)audioModel;

//发送图片消息
- (void)sendPicMessage:(NSArray<ICMessage *>*)picModels;

//发送视频消息
- (void)sendVideoMessage:(ICMessage *)videoModel;

@end

NS_ASSUME_NONNULL_END
