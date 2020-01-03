//
//  MMMessage.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMChatServerDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class MMChatContentModel;

@interface MMMessage : NSObject

/** 消息类型 */
@property (nonatomic, assign) MMMessageType messageType;

/** 聊天类型*/
@property (nonatomic, copy) NSString *type;

/** 接收用户ID*/
@property (nonatomic, copy) NSString *toID;

/** 接收用户名*/
@property (nonatomic, copy) NSString *toUserName;

@property (nonatomic, copy) NSString *toUserPhoto;

/** 发送人的ID*/
@property (nonatomic, copy) NSString *fromID;

/** 发送人的昵称*/
@property (nonatomic, copy) NSString *fromUserName;

/** 发送人的头像*/
@property (nonatomic, copy) NSString *fromPhoto;

/** 消息ID*/
@property (nonatomic, copy) NSString *msgID;

/** 消息发送服务器时间戳*/
@property (nonatomic, assign) long long timestamp;

/** 消息发送本地时间戳*/
@property (nonatomic, assign) long long localtime;

/** 消息对象*/
@property (nonatomic, strong) MMChatContentModel *slice;

/** 发送状态*/
@property (nonatomic, assign) MessageDeliveryState deliveryState;

/** SessionID*/
@property (nonatomic, copy) NSString *sessionID;

/** 发送者*/
@property (nonatomic, assign) BOOL isSender;

/** 是否已读*/
@property (nonatomic, assign) NSInteger status;

/** 请求命令*/
@property (nonatomic, copy) NSString *cmd;

/** 聊天类型*/
@property (nonatomic, assign) MMConversationType cType;

/** 数据库中可查找的会话对象*/
@property (nonatomic, copy) NSString *conversation;


#pragma mark - 消息接收插入位置
@property (nonatomic, assign) BOOL isInsert;


/**
 MMMessage对象数据初始化

 @param toUser 发送对象 或者
 @param toUserName 发送对象的群名或者单聊对象
 @param fromUser 发送者
 @param chatType 聊天类型
 @param isSender 是否是发送者
 @param cType 聊天类型
 @param body 消息体参数
 @return 返回MMMessage对象
 */
- (instancetype)initWithToUser:(NSString *)toUser
                    toUserName:(NSString *)toUserName
                      fromUser:(NSString *)fromUser
                  fromUserName:(NSString *)fromUserName
                      chatType:(NSString *)chatType
                      isSender:(BOOL)isSender
                           cmd:(NSString *)cmd
                       cType:(MMConversationType)cType
                   messageBody:( MMChatContentModel *)body;

@end

@interface MMChatContentModel :NSObject

#pragma mark - 公共

/** 消息类型:text/pic/voice/video/file/linkman */
@property (nonatomic, copy) NSString *type;

/**消息内容:文字消息,图片消息,语音消息,视频消息,文件消息*/
@property (nonatomic, copy) NSString *content;

/**本地文件路径*/
@property (nonatomic, copy) NSString *filePath;

#pragma mark - 语音

/**语音时长,单位是秒*/
@property (nonatomic, assign) NSInteger duration;

#pragma mark - 图片

/**图片的宽度*/
@property (nonatomic, assign) CGFloat width;

/**图片的高度 */
@property (nonatomic, assign) CGFloat height;

#pragma mark - 文件

/**文件的长度,单位是byte*/
@property (nonatomic, copy) NSString  *length;

/**文件的名称*/
@property (nonatomic, copy) NSString *fileName;

#pragma mark - 地图
/**经度*/
@property (nonatomic, assign) CGFloat jingDu;

/**纬度 */
@property (nonatomic, assign) CGFloat weiDu;
/**街道地址*/
@property (nonatomic, copy) NSString *address;

#pragma mark - 联系人
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *photo;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;

@end


NS_ASSUME_NONNULL_END
