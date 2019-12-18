//
//  MMClient.m
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMClient.h"

// 接收的消息Model
#import "MMReceiveMessageModel.h"
#import "MMRecentConVersationModel.h"
#import "VoiceConverter.h"


@interface MMClient()
{
    MultiDelegate<MMChatManager>     *_multiDelegate;
}

@end

static MMClient *helper = nil;

@implementation MMClient


+ (instancetype)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[MMClient alloc] init];
    });
    return helper;
}

- (id)init
{
    self = [super init];
    if (self) {
        _multiDelegate = (MultiDelegate<MMChatManager> *)[[MultiDelegate alloc] init];
        _multiDelegate.silentWhenEmpty = YES;
    }
    return self;
}

- (void)dealloc
{
    
}
#pragma mark - Public Methods
#pragma mark - <添加代理>
- (void)addDelegate:(id<MMChatManager>)delegate
{
    if (delegate && ![_multiDelegate.delegates.allObjects containsObject:delegate]) {
        [_multiDelegate addDelegate:delegate];
    }
}

#pragma mark - <移除当前代理>

- (void)removeDelegate:(id<MMChatManager>)delegate
{
    [_multiDelegate removeDelegate:delegate];
}

#pragma mark - <移除所有代理>
- (void)clearAllDelegates
{
    [_multiDelegate removeAllDelegates];
}

#pragma mark - Hangdles

- (void)addHandleChatMessage:(NSDictionary *)aMessage
{
    
    MMLog(@"收到单聊消息===将该条消息转化成已读状态===============%@",aMessage);
    NSDictionary *userDic = aMessage[@"list"][@"user"];
    if (![userDic isKindOfClass:[NSDictionary class]]) {
        MMLog(@"消息格式有误！详见：%@",userDic);
        return;
    }
    
    MMReceiveMessageModel *receiveModel = [MMReceiveMessageModel mj_objectWithKeyValues:userDic];

    MMChatContentModel *chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"content"][@"slice"]];
    if ([[userDic allKeys] containsObject:@"msg"]) {
        chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"msg"][@"slice"]];
    }

    BOOL isSender  = [receiveModel.fromID isEqualToString:[ZWUserModel currentUser].userId] ? YES:NO;
    
    MMMessage *message = [[MMMessage alloc] initWithToUser:receiveModel.toID
                                                toUserName:receiveModel.toName
                                                  fromUser:receiveModel.fromID
                                              fromUserName:receiveModel.fromNick.checkTextEmpty?receiveModel.fromNick:receiveModel.fromName
                                                  chatType:@"chat"
                                                  isSender:isSender
                                                       cmd:@"sendMsg"
                                                     cType:MMConversationType_Chat
                                               messageBody:chatContentModel];
    
    message.localtime = [[NSDate date] timeStamp];
    message.messageType = [MMRecentConVersationModel getMessageType:message.slice.type];
    message.fromPhoto = receiveModel.fromPhoto;
    message.timestamp = [self transTimeStamp:receiveModel.time];
    message.deliveryState = isSender ? MMMessageDeliveryState_Delivered:MMMessageDeliveryState_Failure;
    message.conversation = isSender ? message.toID :  message.fromID;//会话对象是conversation 对方的id
    MMLog(@"%d",message.isInsert);
    MMLog(@"%@",message.conversation);
    message.isInsert = receiveModel.isInsert;
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 消息插入数据库
        [[MMChatDBManager shareManager] addMessage:message];
        // 会话插入数据库或者更新会话
        NSString *currentToId = isSender ? message.toID : message.fromID;
        BOOL isChatting = [currentToId isEqualToString:[MMClient sharedClient].chattingConversation.conversationModel.toUid];
        [[MMChatDBManager shareManager] addOrUpdateConversationWithMessage:message isChatting:isChatting];
    });
    
    // 代理处理
    if (self.chatListViewC || self.chattingConversation) {
        [_multiDelegate clientManager:self
                   didReceivedMessage:message];
    }
    
}


- (void)addHandleGroupMessage:(NSDictionary *)aMessage
{
    MMLog(@"收到群聊消息==================%@",aMessage);
    
    NSDictionary *userDic = aMessage[@"list"][@"group"];
    if (![userDic isKindOfClass:[NSDictionary class]]) {
        MMLog(@"消息格式有误！详见：%@",userDic);
        return;
    }
    
    MMReceiveMessageModel *receiveModel = [MMReceiveMessageModel mj_objectWithKeyValues:userDic];
    
    if ([receiveModel.fromID isEqualToString:[ZWUserModel currentUser].userId] && !receiveModel.isInsert) {
        return;
    }

    MMChatContentModel *chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"content"][@"slice"]];
    if ([[userDic allKeys] containsObject:@"msg"]) {
        chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"msg"][@"slice"]];
    }
    
    NSString *fname = [ZWUserModel currentUser].nickName;
    MMMessage *message = [[MMMessage alloc] initWithToUser:receiveModel.groupID
                                                toUserName:receiveModel.fromNick.checkTextEmpty?receiveModel.fromNick:receiveModel.fromName
                                                  fromUser:receiveModel.fromID
                                              fromUserName:fname
                                                  chatType:@"groupchat"
                                                  isSender:NO
                                                       cmd:@"sendMsg"
                                                     cType:MMConversationType_Chat
                                               messageBody:chatContentModel];
    
    message.isInsert = receiveModel.isInsert;
    message.isSender = [receiveModel.fromID isEqualToString:[ZWUserModel currentUser].userId]?YES:NO;
    message.localtime = [[NSDate date] timeStamp];
    message.timestamp = [self transTimeStamp:receiveModel.time];
    message.messageType = [MMRecentConVersationModel getMessageType:message.slice.type];
    message.fromPhoto = receiveModel.fromPhoto;
    
    // 消息插入数据库
    [[MMChatDBManager shareManager] addMessage:message];
    
    // 会话插入数据库或者更新会话
    BOOL isChatting = [receiveModel.groupID isEqualToString:[[[[MMClient sharedClient] chattingConversation] conversationModel] toUid]];
    
    [[MMChatDBManager shareManager] addOrUpdateConversationWithMessage:message
                                                            isChatting:isChatting];
    
    // 代理处理
    if (isChatting) {
        [_multiDelegate clientManager:self
                   didReceivedMessage:message];
    }
}
- (long long)transTimeStamp:(NSString *)dateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateStr];
    return [date timeIntervalSince1970] * 1000;
}

@end
