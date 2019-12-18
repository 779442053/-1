//
//  MMChatManager.h
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MMClient;

/**
 *  聊天相关操作
 *  消息都是从DB中加载
 */
@protocol MMChatManager<NSObject>

@required

#pragma mark - Delegate


- (void)clientManager:( MMClient *__nullable )manager didReceivedMessage:(MMMessage *)message;

///**
// 获取所有会话
//
// @return 返回会话列表
// */
//- (NSArray *)getAllConversations;
//
///**
// 获取一个会话
//
// @param aConversationId 会话ID
// @param aType 会话类型
// @param aIfCreate 如果不存在是否创建
// @return 返回会话对象
// */
//- (MMMessage *)getConversation:(NSString *)aConversationId
//                               type:(MMConversationType)aType
//                   createIfNotExist:(BOOL)aIfCreate;
//
//
///**
// 删除一个会话
//
// @param aConversationId 会话ID
// @param aIsDeleteMessages 是否删除记录
// @param aCompletionBlock 返回结果
// */
//- (void)deleteConversation:(NSString *)aConversationId
//          isDeleteMessages:(BOOL)aIsDeleteMessages
//                completion:(void (^)(NSString *aConversationId, NSError *aError))aCompletionBlock;
//
//
///**
// 更新一条消息
//
// @param aMessage 消息
// @param aCompletionBlock 返回结果
// */
//- (void)updateMessage:(MMMessage *)aMessage
//           completion:(void (^)(MMMessage *aMessage, NSError *aError))aCompletionBlock;
//
//
///**
// 发送消息
//
// @param aMessage 消息
// @param aProgressBlock 附件上传进度回调block
// @param aCompletionBlock 发送完成回调block
// */
//- (void)sendMessage:(MMMessage *)aMessage
//           progress:(void (^)(int progress))aProgressBlock
//         completion:(void (^)(MMMessage *message, NSError *error))aCompletionBlock;
//
///**
// 撤回消息
//
// @param aMessage 消息
// @param aCompletionBlock 返回结果
// */
//- (void)recallMessage:(MMMessage *)aMessage
//           completion:(void (^)(MMMessage *aMessage, NSError *aError))aCompletionBlock;
//
///**
// 重发送消息
//
// @param aMessage 消息
// @param aProgressBlock 附件上传进度回调block
// @param aCompletionBlock 发送完成回调block
// */
//- (void)resendMessage:(MMMessage *)aMessage
//             progress:(void (^)(int progress))aProgressBlock
//           completion:(void (^)(MMMessage *message, NSError *error))aCompletionBlock;

@end

NS_ASSUME_NONNULL_END
