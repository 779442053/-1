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
- (void)addDelegate:(id<MMChatManager>)delegate
{
    if (delegate && ![_multiDelegate.delegates.allObjects containsObject:delegate]) {
        [_multiDelegate addDelegate:delegate];
    }
}
- (void)removeDelegate:(id<MMChatManager>)delegate
{
    [_multiDelegate removeDelegate:delegate];
}
- (void)clearAllDelegates
{
    [_multiDelegate removeAllDelegates];
}
- (void)addHandleChatMessage:(NSDictionary *)aMessage
{//这里,我收到了一条消息==此时,并不知道当前对话是否开启
    ZWWLog(@"收到单聊消息===将该条消息转化成已读状态===============%@",aMessage);
    NSDictionary *userDic = aMessage[@"list"][@"user"];
    if (![userDic isKindOfClass:[NSDictionary class]]) {
        ZWWLog(@"消息格式有误！详见：%@",userDic);
        return;
    }
    MMReceiveMessageModel *receiveModel = [MMReceiveMessageModel mj_objectWithKeyValues:userDic];
    MMChatContentModel *chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"content"][@"slice"]];
    if ([[userDic allKeys] containsObject:@"msg"]) {
        if ([userDic[@"msg"][@"slice"] isKindOfClass:[NSArray class]]) {
            NSArray *slicearr = userDic[@"msg"][@"slice"];
            if (slicearr.count) {
                NSDictionary *sliceDict = slicearr[0];
                chatContentModel = [MMChatContentModel yy_modelWithDictionary:sliceDict];
            }
        }else{
            chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"msg"][@"slice"]];
        }
    }
    receiveModel.slice = chatContentModel;
    NSString *fromID = [NSString stringWithFormat:@"%@",receiveModel.fromID];
    NSString *UserID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    BOOL isSender  = [fromID isEqualToString:UserID] ? YES:NO;
    //创建消息模型
    MMMessage *message = [[MMMessage alloc] initWithToUser:receiveModel.toID
                                                toUserName:receiveModel.toName
                                                  fromUser:receiveModel.fromID
                                              fromUserName:receiveModel.fromNick.checkTextEmpty?receiveModel.fromNick:receiveModel.fromName
                                                  chatType:@"chat"
                                                  isSender:isSender
                                                       cmd:@"sendMsg"
                                                     cType:MMConversationType_Chat
                                               messageBody:chatContentModel];
    if (!isSender) {
        ZWWLog(@"别人发送的消息111ID =\n %@ ",message.msgID)
        message.msgID = userDic[@"msgID"];
        ZWWLog(@"别人发送的消息ID =\n %@ ",message.msgID)
    }
    message.localtime = [[NSDate date] timeStamp];
    //消息类型===当对方撤回消息的时候或者是系统消息的时候,需要手动封装消息
    message.messageType = [MMRecentConVersationModel getMessageType:message.slice.type];
    message.fromPhoto = receiveModel.fromPhoto;
    message.timestamp = [self transTimeStamp:receiveModel.time];//毫秒
    message.deliveryState = isSender ? MMMessageDeliveryState_Delivered:MMMessageDeliveryState_Delivered;
    message.conversation = isSender ? message.toID :  message.fromID;//
    MMLog(@"========%d",message.isInsert);
    MMLog(@"==数据库中可查询的会话对象====%@",message.conversation);
    message.isInsert = receiveModel.isInsert;
    //开启分享成,进行消息缓存操作
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[MMChatDBManager shareManager] addMessage:message];
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
    ZWWLog(@"收到群聊消息==================%@",aMessage);
    NSDictionary *userDic = aMessage[@"list"][@"group"];
    if (![userDic isKindOfClass:[NSDictionary class]]) {
        MMLog(@"消息格式有误！详见：%@",userDic);
        return;
    }
    MMReceiveMessageModel *receiveModel = [MMReceiveMessageModel mj_objectWithKeyValues:userDic];
    NSString * fromID = [NSString stringWithFormat:@"%@",receiveModel.fromID];
    NSString * userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    if ([fromID isEqualToString:userID] && !receiveModel.isInsert) {
        return;
    }
   //消息内容
    MMChatContentModel *chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"msg"][@"slice"]];
    if ([[userDic allKeys] containsObject:@"msg"]) {
        if ([userDic[@"msg"][@"slice"] isKindOfClass:[NSArray class]]) {
            NSArray *slicearr = userDic[@"msg"][@"slice"];
            if (slicearr.count) {
                NSDictionary *sliceDict = slicearr[0];
                chatContentModel = [MMChatContentModel yy_modelWithDictionary:sliceDict];
            }
        }else{
            chatContentModel = [MMChatContentModel yy_modelWithDictionary:userDic[@"msg"][@"slice"]];
        }
    }
    NSString *fname = [ZWUserModel currentUser].nickName;
    MMMessage *message = [[MMMessage alloc] initWithToUser:receiveModel.groupID
                                                toUserName:receiveModel.fromNick.checkTextEmpty?receiveModel.fromNick:receiveModel.fromName
                                                  fromUser:receiveModel.fromID
                                              fromUserName:fname
                                                  chatType:@"groupchat"
                                                  isSender:NO
                                                       cmd:@"sendMsg"
                                                     cType:MMConversationType_Group
                                               messageBody:chatContentModel];
    
    message.isInsert = receiveModel.isInsert;
    message.isSender = [receiveModel.fromID isEqualToString:userID]?YES:NO;
    message.localtime = [[NSDate date] timeStamp];
    message.timestamp = [self transTimeStamp:receiveModel.time];
    message.messageType = [MMRecentConVersationModel getMessageType:message.slice.type];
    message.fromPhoto = receiveModel.fromPhoto;
    message.conversation = receiveModel.groupID;
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
