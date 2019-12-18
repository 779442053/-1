//
//  MMChatDBManager.h
//  EasyIM
//
//  Created by momo on 2019/5/13.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMDatabase;

NS_ASSUME_NONNULL_BEGIN

/**
 数据库数据管理
 */
@interface MMChatDBManager : NSObject

+ (instancetype)shareManager;

/**
 向数据库添加消息
 
 @param message 消息模型
 */
- (void)addMessage:(MMMessage *)message;

/**
 更新消息
 
 @param message 消息模型
 */
- (void)updateMessage:(MMMessage *)message;

/**
 分页查询与某个用户的聊天信息
 
 @param conversationId 对方的用户名称
 @param limit 每页显示个数
 @param page 查询的页数
 @return 查询到的聊天记录
 */
- (NSArray <MMMessage *>*)queryMessagesWithUser:(NSString *)conversationId limit:(NSInteger)limit page:(NSInteger)page;

/**
 获取所有会话
 
 @return 返回会话列表
 */
//- (NSArray<MMRecentContactsModel *> *)getAllConversations;

- (void)getAllConversations:(void(^)(NSArray<MMRecentContactsModel *> *))versations;


/**
 删除一个会话
 
 @param aConversationId 会话ID
 @param aCompletionBlock 返回结果
 */
- (void)deleteConversation:(NSString *)aConversationId
                completion:(void (^)(NSString *aConversationId, NSError *aError))aCompletionBlock;


/**
 更新会话未读消息数量
 
 @param aConversationId 会话ID
 @param unreadCount 未读消息数量
 */
- (void)updateUnreadCountOfConversation:(NSString *)aConversationId unreadCount:(NSInteger)unreadCount;

/**
 插入或更新会话
 
 @param message 消息模型
 @param isChatting 会话是否已经开启
 */
- (void)addOrUpdateConversationWithMessage:(MMMessage *)message isChatting:(BOOL)isChatting;


/**
 检查conversationId是否存在

 @param conversationId conversationId
 @param exist 是否存在
 */
- (void)checkConversation:(NSString *)conversationId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist;

@end

NS_ASSUME_NONNULL_END
