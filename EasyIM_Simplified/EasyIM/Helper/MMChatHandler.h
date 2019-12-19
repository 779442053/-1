//
//  MMChatHandler.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMReceiveMessageModel.h"


NS_ASSUME_NONNULL_BEGIN


/**
 - 发送消息
 */
@interface MMChatHandler : NSObject

//发送消息单例
+ (instancetype)shareInstance;


/**
 发送文字

 @param text 文字内容
 @param toUser 发送对象Id
 @param toUserName 发送对象名称
 @param aCompletionBlock 状态改变返回消息模型
 @return 消息模型
 */
- (MMMessage *)sendTextMessage:(NSString *)text
                        toUser:(NSString *)toUser
                    toUserName:(NSString *)toUserName
                toUserPhotoUrl:(NSString *)photoUrl
                           cmd:(NSString *)cmd
                    completion:(void(^) (MMMessage *message))aCompletionBlock;


/**
 发送图片消息
 
 @param filePath 本地文件地址
 @param toUser 发送目标
 @param aCompletionBlock 状态改变返回消息模型
 @return 消息模型
 */
- (MMMessage *)sendImgMessage:(NSString *)filePath
                    imageSize:(CGSize)size
                       toUser:(NSString *)toUser
                   toUserName:(NSString *)toUserName
               toUserPhotoUrl:(NSString *)photoUrl
                          cmd:(NSString *)cmd
                   completion:(void(^)(MMMessage *message))aCompletionBlock;


/**
 发送文件消息

 @param fileName 文件名
 @param toUser 发送目标
 @param aCompletionBlock 状态改变返回消息模型
 @return 消息模型
 */
- (MMMessage *)sendFileMessage:(NSString *)fileName
                        toUser:(NSString *)toUser
                    toUserName:(NSString *)toUserName
                toUserPhotoUrl:(NSString *)photoUrl
                           cmd:(NSString *)cmd
                    completion:(void(^)(MMMessage *message))aCompletionBlock;


/**
 发送语音消息

 @param voicePath 文件名
 @param toUser 发送目标
 @param aCompletionBlock 状态改变发回消息模型
 @return 消息模型
 */
- (MMMessage *)sendVoiceMessageWithVoicePath:(NSString *)voicePath
                                      toUser:(NSString *)toUser
                                  toUserName:(NSString *)toUserName
                              toUserPhotoUrl:(NSString *)photoUrl
                                         cmd:(NSString *)cmd
                                  completion:(void(^)(MMMessage *message))aCompletionBlock;

/**
 发送联系人消息
 
 @param model 联系人模型
 @param toUser toUser description
 @param toUserName toUserName description
 @param photoUrl photoUrl description
 @param cmd cmd description
 @param aCompletionBlock aCompletionBlock description
 @return return MMMessage
 */
- (MMMessage *)sendLinkmanMessageModel:(MMChatContentModel *)model
                                toUser:(NSString *_Nonnull)toUser
                            toUserName:(NSString *_Nonnull)toUserName
                        toUserPhotoUrl:(NSString *_Nullable)photoUrl
                                   cmd:(NSString *_Nonnull)cmd
                            completion:(void(^) (MMMessage *_Nonnull message))aCompletionBlock;

/// 撤回消息
/// @param Mid 消息ID..把需要撤回的消息传递过来,需要进行本地数据库操作
/// @param toUserid 接受者id
/// @param toUserName 接受者名字.如果是群,则不传
/// @param cmd 命令,根据此命令,判断是群还是单聊
/// @param aCompletionBlock 返回一个消息对象
- (MMMessage *)WithdrawMessageWithMessageID:(MMMessage *)Mid
        toUserID:(NSString *_Nonnull)toUserid
    toUserName:(NSString *_Nonnull)toUserName
           cmd:(NSString *_Nonnull)cmd
    completion:(void(^) (MMMessage *_Nonnull message))aCompletionBlock;

@end

NS_ASSUME_NONNULL_END
