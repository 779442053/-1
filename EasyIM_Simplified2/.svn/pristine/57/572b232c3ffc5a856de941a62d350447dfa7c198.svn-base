//
//  MMReceiveMessageModel.h
//  EasyIM
//
//  Created by momo on 2019/4/23.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMReceiveMessageModel : NSObject

#pragma mark - 公共部分
@property (nonatomic, copy) NSString *fromID;
@property (nonatomic, copy) NSString *fromName;
@property (nonatomic, copy) NSString *fromPhoto;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *msgID;
@property (nonatomic, copy) NSString *msgType;
@property (nonatomic, strong) MMChatContentModel *slice;

#pragma mark - 单聊接收部分
@property (nonatomic, copy) NSString *fromNick;
@property (nonatomic, copy) NSString *toID;
@property (nonatomic, copy) NSString *toName;

#pragma mark - 群消息接收部分
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *groupPhoto;

#pragma mark - 消息接收插入位置
@property (nonatomic, assign) BOOL isInsert;




@end

NS_ASSUME_NONNULL_END
