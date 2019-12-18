//
//  ChatViewController.h
//  EasyIM
//
//  Created by apple on 2019/8/20.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 聊天
 */
@interface ChatViewController : MMBaseViewController

/**
 与某个联系人的会话是否存在，存在的话返回该会话
 
 @param toUser 会话的目标联系人
 @return 与某个联系人的会话
 */
- (MMRecentContactsModel *)isExistConversationWithToUser:(NSString *)toUser;
    
/**
 会话存在，则更新会话最新消息，不存在则添加该会话
 
 @param conversationName 会话ID
 @param message 最新一条消息
 */
- (void)addOrUpdateConversation:(NSString *)conversationName
                  latestMessage:(MMMessageFrame *)message
                         isRead:(BOOL)isRead;
    
/**
 更新未读消息红点
 
 @param conversationName 会话ID
 */
- (void)updateRedPointForUnreadWithConveration:(NSString *)conversationName;
    
@end

NS_ASSUME_NONNULL_END
