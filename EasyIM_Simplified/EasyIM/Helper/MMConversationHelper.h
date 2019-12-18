//
//  MMConversationHelp.h
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MMRecentContactsModel;
NS_ASSUME_NONNULL_BEGIN

/**
 其实就是一个中间转换Model 因为有多个通道要到通一个通道.并对其数据预赋值
 */
@interface MMConversationModel : NSObject


#pragma mark - 公共

/**请求命令*/
@property (nonatomic, copy) NSString *cmd;

/**发送对象uid或者群id*/
@property (nonatomic, copy) NSString *toUid;

/**发送对象uerName或者群昵称*/
@property (nonatomic, copy) NSString *toUserName;

@property (nonatomic, assign) BOOL isGroup;

#pragma mark - 个聊

/** 备注*/
@property (nonatomic, copy) NSString *remarkName;
/** 昵称*/
@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *photoUrl;

#pragma mark - 群聊

/** 群主id*/
@property (nonatomic, copy) NSString *creatorId;

/** 0:群 10:聊天室*/
@property (nonatomic, copy) NSString *mode;

/** 群创建时间戳*/
@property (nonatomic, copy) NSString *time;

/** 群是否免打扰*/
@property (nonatomic, copy) NSString *notify;


- (NSString *)getTitle;


/**
 个人聊天数据初始化数据

 @param toUid 发送对象uid
 @param toUserName 发送对象userName
 @param nickName 发送对象nickName
 @param cmd 请求命令
 @return 返回该中间Model
 */
- (instancetype)initWithToUid:(NSString *)toUid
                   toUserName:(NSString *)toUserName
                     nickName:(NSString *)nickName
                   remarkName:(NSString *)remarkName
                     photoUrl:(NSString *)photoUrl
                          cmd:(NSString *)cmd;


/**
 群聊天数据初始化数据

 @param groupId 群id
 @param groupName 群名
 @param creatorId 群主id
 @param mode 0:群 10:聊天室
 @param time 创建时间
 @param cmd 请求命令
 @return 返回中间Model
 */
- (instancetype)initWithGroupId:(NSString *)groupId
                      groupName:(NSString *)groupName
                      creatorId:(NSString *)creatorId
                           mode:(NSString *)mode
                           time:(NSString *)time
                         notify:(NSString *)notify
                            cmd:(NSString *)cmd;

@end


@interface MMConversationHelper : NSObject

+ (instancetype)shared;


/**
 获取到MMConversationModel

 @param aContact 联系人Model
 @return MMConversationModel对象
 */
+ (MMConversationModel *)modelFromContact:(ContactsModel *)aContact;

/**
 获取到MMConversationModel

 @param aGroup 群Model
 @return MMConversationModel对象
 */
+ (MMConversationModel *)modelFromGroup:(MMGroupModel *)aGroup;
//+ (MMConversationModel *)modelFromGroup:(MMGroupModel *)aGroup;

/**!
 * 获取到MMConversationModel
 * @params aRecenContact MMRecentContactsModel
 */
+ (MMConversationModel *)modelFromRecentContacts:(MMRecentContactsModel *)aRecenContact;

@end


NS_ASSUME_NONNULL_END
