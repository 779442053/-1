//
//  MMClient.h
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

//MultiDelegate
#import "MMChatManager.h"
#import "MultiDelegate.h"

//ViewController
#import "MMChatViewController.h"
#import "ChatViewController.h"

//Category
#import "NSDate+Extension.h"


NS_ASSUME_NONNULL_BEGIN

@interface MMClient : NSObject


/**
 全部未读消息数量
 */
@property (nonatomic, assign) NSInteger unreadMessageCount;

/**
 正在聊天的会话控制器
 */
@property (nonatomic, weak) MMChatViewController *chattingConversation;


/**
 消息会话列表
 */
@property (nonatomic, weak) ChatViewController *chatListViewC;



/**
 单例

 @return 返回单例对象
 */
+ (instancetype)sharedClient;


/**
 处理单聊消息

 @param aMessage 单聊消息
 */
- (void)addHandleChatMessage:(NSDictionary *)aMessage;

/**
 处理群聊消息

 @param aMessage 群聊消息
 */
- (void)addHandleGroupMessage:(NSDictionary *)aMessage;



/**
 添加代理
 
 @param delegate 代理
 */

- (void)addDelegate:(id<MMChatManager>)delegate;

/**
 移除代理
 
 @param delegate 代理
 */
- (void)removeDelegate:(id<MMChatManager>)delegate;

@end

NS_ASSUME_NONNULL_END
