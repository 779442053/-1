//
//  MMChatDBManager.m
//  EasyIM
//
//  Created by momo on 2019/5/13.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatDBManager.h"

#import "MMConversationHelper.h"

#import <fmdb/FMDB.h>

#import "MMRecentConVersationModel.h"

#import "NSDate+Extension.h"


@interface MMChatDBManager ()

@property (nonatomic, strong) FMDatabase *db;
@property (nonatomic, strong) FMDatabaseQueue *DBQueue;

@end

static MMChatDBManager *instance = nil;

@implementation MMChatDBManager


- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

+ (instancetype)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[MMChatDBManager alloc] init];
    });
    
    return instance;
}

#pragma mark - Getter

- (FMDatabaseQueue *)DBQueue
{
    
    NSString *dbName = [NSString stringWithFormat:@"%@.db", [ZWUserModel currentUser].userId];
    NSString *path = _DBQueue.path;
    
    if (!_DBQueue || ![path containsString:dbName]) {
        NSString *tablePath = [[self DBMianPath] stringByAppendingPathComponent:dbName];
        
        _DBQueue = [FMDatabaseQueue databaseQueueWithPath:tablePath];
        [_DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
            
            // 打开数据库
            if ([db open]) {
                
                // 会话数据库表
                //id:消息id,conversation:聊天对象(如果当前是单聊则为聊天对方,如果是群聊则是群号等),unreadcount:消息未读数,latestmsgtext:最后的文字消息,latestmsgtimestamp:最后的消息时间
                BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS conversation (id TEXT NOT NULL, latestHeadImage TEXT, unreadcount Integer, latestmsgtext TEXT, latestmsgtimestamp INT32,latestnickname TEXT,chattype TEXT)"];
                if (success) {
                    MMLog(@"创建会话表成功");
                }
                else {
                    MMLog(@"创建会话表失败");
                }
                
                // 消息数据表
                //id:消息id,localtime:本地发送的时间,timestamp:服务器时间,conversation:聊天对象(如果当前是单聊则为聊天对方,如果是群聊则是群号等),msgdirection:消息查询方向,chattype:聊天类型,bodies:消息体,status:发送状态
                BOOL msgSuccess = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS message (id TEXT NOT NULL, localtime INT32, timestamp INT32, conversation TEXT, msgdirection INT1, chattype TEXT, bodies TEXT, status INT1,toUserId TEXT, toUserName TEXT,fromUserName TEXT,fromUserId TEXT, fromPhoto TEXT)"];
                if (msgSuccess) {
                    MMLog(@"创建消息表成功");
                }
                else {
                    MMLog(@"创建消息表失败");
                }
            }
        }];
    }
    return _DBQueue;
}

/**
 查询会话在数据库是否存在
 
 @param conversationId 会话的ID
 @param exist 是否存在,且返回db以便下步操作
 */
- (void)conversation:(NSString *)conversationId isExist:(void(^)(BOOL isExist, FMDatabase *db, NSInteger unReadCount))exist
{
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL e = NO;
        NSInteger unreadCount = 0;
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation WHERE id = ?", conversationId];
        while (result.next) {
            e = YES;
            unreadCount = [result intForColumnIndex:2];
            break;
        }
        [result close];
        
        exist(e, db, unreadCount);
    }];
    
}

- (void)checkConversation:(NSString *)conversationId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist
{
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
    
        BOOL e = NO;
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation WHERE id = ?", conversationId];
        while (result.next) {
            e = YES;
            break;
        }
        [result close];
        
        exist(e, db);
    }];
    
}
- (void)message:(MMMessage *)message baseId:(BOOL)baseId isExist:(void(^)(BOOL isExist, FMDatabase *db))exist
{
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        BOOL e = NO;
        if (!message.msgID.length) {
            exist(NO, db);
            return ;
        }
        FMResultSet *result;
        if (baseId) {  // 基于消息ID查询
            result = [db executeQuery:@"SELECT * FROM message WHERE id = ?", message.msgID];
        }
        else {  // 基于消息发送的本地时间查询
            result = [db executeQuery:@"SELECT * FROM message WHERE localtime = ?", @(message.localtime)];
        }
        
        while (result.next) {
            
            e = YES;
            break;
        }
        
        [result close];
        exist(e, db);
    }];
}

- (void)getAllConversations:(void(^)(NSArray<MMRecentContactsModel *> *))versations
{
    
    NSMutableArray *conversations = [NSMutableArray array];
    
    
    
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM conversation WHERE chattype = 'chat' "];
        while (result.next) {
            
            MMRecentContactsModel *conversation = [[MMRecentContactsModel alloc] init];
            conversation.userId = [result stringForColumnIndex:0];
            conversation.latestHeadImage = [result stringForColumnIndex:1];
            conversation.unReadCount = [result intForColumnIndex:2];
            conversation.latestMsgStr = [result stringForColumnIndex:3];
            conversation.latestMsgTimeStamp = [result longLongIntForColumnIndex:4];
            conversation.latestnickname = [result stringForColumnIndex:5];
            
            [conversations addObject:conversation];
        }
        [result close];
    }];
    
    versations(conversations);
    
}

- (void)addMessage:(MMMessage *)message
{
    
    [self message:message baseId:YES isExist:^(BOOL isExist, FMDatabase *db) {
        
        // 判断在数据库中不存在 再插入消息
        if (!isExist) {
            BOOL isSender = message.isSender;
            NSString *bodies = [message.slice yy_modelToJSONString];
            NSString *msgId = message.msgID;
            long long time = message.timestamp;
            long long locTime = message.localtime;
            NSString *chatType = message.type;
            NSString *fromPhoto = message.fromPhoto;
            NSString *conversation = message.conversation;
            
            NSString *toUserName = message.toUserName;
            NSString *fromUserName = message.fromUserName;
            NSString *fromUserId = message.fromID;
            
            NSString *toUserId = message.toID;

//            if ([chatType isEqualToString:@"groupchat"]) {
//                fromUserName = isSender? message.fromUserName:message.toUserName;
//                fromUserId =isSender ? message.fromID: message.toID;
//                toUserId = isSender? message.toID:message.fromID;
//            }
            
            NSNumber *status;
            switch (message.deliveryState) {
                case MMMessageDeliveryState_Delivering:
                case MMMessageDeliveryState_Failure:
                    status = @0;
                    break;
                    
                case MMMessageDeliveryState_Delivered:
                    status = @1;
                    break;
                default:
                    break;
            }
            
            BOOL success = [db executeUpdate:@"INSERT INTO message (id, localtime, timestamp, conversation, msgdirection, chattype, bodies, status,toUserId,toUserName,fromUserName,fromUserId,fromPhoto) VALUES (?, ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?)", msgId, @(locTime),@(time), conversation, isSender?@1:@0, chatType, bodies, status,toUserId,toUserName,fromUserName,fromUserId,fromPhoto];
            
            if (success) {
                MMLog(@"消息加入成功!");
            }else{
                MMLog(@"消息加入失败!");
            }
        }
        
    }];
}

- (void)updateMessage:(MMMessage *)message
{
    
    [self message:message baseId:NO  isExist:^(BOOL isExist, FMDatabase *db) {
        
        NSNumber *sendStatus;
        switch (message.deliveryState) {
            case MMMessageDeliveryState_Failure:case MMMessageDeliveryState_Delivering:
                sendStatus = @0;
                break;
                
            case MMMessageDeliveryState_Delivered:
                sendStatus = @1;
                break;
            default:
                break;
        }
        // 如果消息存在，更新状态
        if (isExist) {
            
            [db executeUpdate:@"UPDATE message SET status = ?, id = ?, bodies = ? WHERE localtime = ?", sendStatus, message.msgID,  [message.slice yy_modelToJSONString],@(message.localtime)];
        }
    }];
}

- (NSArray<MMMessage *> *)queryMessagesWithUser:(NSString *)userName
{
    
    return [self queryMessagesWithUser:userName limit:10000 page:0];
}

- (NSArray<MMMessage *> *)queryMessagesWithUser:(NSString *)conversationId limit:(NSInteger)limit page:(NSInteger)page
{
    
    if (limit <= 0) {
        return nil;
    }
    
    NSMutableArray *messages = [NSMutableArray array];
    [self.DBQueue inDatabase:^(FMDatabase * _Nonnull db) {
        
        //获取时间戳
        NSDate *datetime = [NSDate date];
        NSTimeZone *zone = [NSTimeZone timeZoneForSecondsFromGMT:8];
        NSInteger interval = [zone secondsFromGMTForDate:datetime];
        NSDate *localeDate = [datetime  dateByAddingTimeInterval: interval];
        NSNumber *timeStamp = [NSNumber numberWithLongLong:[localeDate timeStamp]];
        
        FMResultSet *result = [db executeQuery:@"SELECT * FROM (SELECT * FROM message WHERE conversation = ? AND timestamp < ? ORDER BY timestamp DESC LIMIT ? OFFSET ?) ORDER BY timestamp ASC", conversationId, timeStamp, @(limit), @(limit*page)];
        
        while (result.next) {
            
            MMMessageFrame *mf = [[MMMessageFrame alloc] init];
            NSLog(@"取出数据");
            MMMessage *message = [self makeMessageWithFMResult:result];
            NSLog(@"取出成功");
            NSLog(@"========================");
            NSLog(@"计算尺寸");
            mf.aMessage = message;
            NSLog(@"计算完毕");
            
            [messages addObject:mf];
        }
        
        [result close];
    }];
    return messages;
}
/**
 添加或更新到数据库
 
 @param message 消息体
 @param isChatting 是否在会话中
 */
- (void)addOrUpdateConversationWithMessage:(MMMessage *)message isChatting:(BOOL)isChatting
{
    if (!message) {
        return;
    }
    
    //防止是自己的信息
    if ([message.conversation isEqualToString:[ZWUserModel currentUser].userId]) {
        return;
    }
    
    // 聊天对象
    NSString *conversationID =  message.conversation;
    
    // 最新消息字符
    NSString *latestMsgStr = [MMRecentConVersationModel getMessageStrWithMessage:message];
    
    long long timestamp = message.timestamp;
    NSString *chatType = message.type;
    
    // 会话是否开启
    [self conversation:conversationID isExist:^(BOOL isExist, FMDatabase *db, NSInteger unreadCount) {
        
        if (!isExist) {
            
            // 判断不存在再插入数据库
            // 如果是在会话中则未读数为0条 如果不是则是1条未读消息
            
            unreadCount = isChatting ? 0 : 1;
            
            NSString *latestHeadImage;
            NSString *latestnickname ;

            BOOL isSender = message.isSender;
            
            if (isSender) {
                latestHeadImage = message.toUserPhoto;
                latestnickname =  message.toUserName;
            }else{
                latestHeadImage = message.fromPhoto;
                latestnickname =  message.fromUserName;
            }
            
            
            [db executeUpdate:@"INSERT INTO conversation (id,latestHeadImage, unreadcount, latestmsgtext, latestmsgtimestamp,latestnickname,chatType) VALUES (?, ?, ?, ?,?,?,?)", conversationID,latestHeadImage,@(unreadCount), latestMsgStr, @(timestamp),latestnickname,chatType];
            MMLog(@"插入最近列表成功");
        }
        else {
            
            // 如果已经存在，更新最后一条消息
            // 如果是在会话中则未读数为0条 如果不是则+1条
            
            unreadCount = isChatting ? 0 : (unreadCount + 1);
            
            BOOL success = [db executeUpdate:@"UPDATE conversation SET  latestmsgtext = ?, unreadcount = ?, latestmsgtimestamp = ? WHERE id = ?", latestMsgStr, @(unreadCount), @(timestamp),conversationID];
            
            if (success) {
                MMLog(@"更新最近列表成功");
            }
            else {
                MMLog(@"更新最近列表失败");
            }
        }
    }];
}

- (void)deleteConversation:(NSString *)aConversationId
                completion:(void (^)(NSString *aConversationId, NSError *aError))aCompletionBlock
{
    
    [self checkConversation:aConversationId isExist:^(BOOL isExist, FMDatabase *db) {
        
        if (isExist) {
            
            BOOL success = [db executeUpdate:@"DELETE from conversation WHERE id = ?",aConversationId];
            
            NSError *error;
            if (success) {
                MMLog(@"删除成功");
                aCompletionBlock(aConversationId, nil);
            }else{
                MMLog(@"删除失败");
                aCompletionBlock(aConversationId, error);
            }
        }
    }];
    
}

- (void)updateUnreadCountOfConversation:(NSString *)aConversationId unreadCount:(NSInteger)unreadCount
{
    
    [self conversation:aConversationId isExist:^(BOOL isExist, FMDatabase *db, NSInteger unReadCount) {
        
        if (isExist) {
            BOOL success = [db executeUpdate:@"UPDATE conversation SET unreadcount = ? WHERE id = ?", @(unreadCount),aConversationId];
            
            if (success) {
                MMLog(@"更新成功");
            }
            else {
                MMLog(@"更新失败");
            }
        }
    }];
}


- (MMMessage *)makeMessageWithFMResult:(FMResultSet *)result
{
    
    NSString *bodies = [result stringForColumnIndex:6];
    MMChatContentModel *body = [MMChatContentModel yy_modelWithJSON:[bodies stringToJsonDictionary]];
    BOOL isSender = [result boolForColumnIndex:4];
    
    NSString *msgId = [result stringForColumnIndex:0];
    long long  localTime = [result longLongIntForColumnIndex:1];
    long long  timeStamp = [result longLongIntForColumnIndex:2];
    NSString *conversation = [result stringForColumnIndex:3];
    NSString *chat_type = [result stringForColumnIndex:5];
    NSInteger status = [result intForColumnIndex:7];
    NSString *toUser = [result stringForColumnIndex:8];
    NSString *toUserName = [result stringForColumnIndex:9];
    NSString *fromUserName = [result stringForColumnIndex:10];
    NSString *fromUser = [result stringForColumnIndex:11];
    NSString *fromPhoto = [result stringForColumnIndex:12];
    
    MMConversationType cType;
    NSString *cmd = @"";
    if ([chat_type isEqualToString:@"chat"]) {
        cType = MMConversationType_Chat;
        cmd = @"sendMsg";
    }else{
        cType = MMConversationType_Group;
        cmd = @"groupMsg";
        toUserName = fromUserName;
    }
    
    MMMessage *message = [[MMMessage alloc] initWithToUser:toUser
                                                toUserName:toUserName
                                                  fromUser:fromUser
                                              fromUserName:fromUserName
                                                  chatType:chat_type
                                                  isSender:isSender
                                                       cmd:cmd
                                                     cType:cType
                                               messageBody:body];
    message.timestamp = timeStamp;
    message.msgID = msgId;
    message.localtime = localTime;
    message.deliveryState = status?MMMessageDeliveryState_Delivered:MMMessageDeliveryState_Failure;
    message.fromPhoto = fromPhoto;
    message.conversation = conversation;
    
    return message;
}



#pragma mark - Private

- (NSString *)DBMianPath
{
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    
    path = [path stringByAppendingPathComponent:@"MMChatDB"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = false;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    
    if (!(isDir && isDirExist)) {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (bCreateDir) {
            
            MMLog(@"文件路径创建成功");
        }
    }
    return path;
    
}

@end
