//
//  MMChatHandler.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatHandler.h"

#import "MMConnectConfig.h"
#import "MMGCDAsyncSocketCommunicationManager.h"

#import "ZWSocketManager.h"

#import "NSDate+Extension.h"
#import "NSObject+MMAlert.h"

#import "VoiceConverter.h"

#import "MMMessageConst.h"

@interface MMChatHandler ()

//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;


@property (nonatomic, strong) MMConnectConfig *connectConfig;


@end

static NSString *upLoadUrl = @"";//记录当前的上传地址

@implementation MMChatHandler
#pragma mark - 初始化聊天handler单例
+ (instancetype)shareInstance
{
    static MMChatHandler *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[MMChatHandler alloc] init];
    });
    return handler;
}


- (MMMessage *)sendTextMessage:(NSString *)text
                        toUser:(NSString *)toUser
                    toUserName:(NSString *)toUserName
                toUserPhotoUrl:(NSString *)photoUrl
                           cmd:(NSString *)cmd
                    completion:(void(^) (MMMessage *message))aCompletionBlock
{
    
    //1.对内容模型赋值
    MMChatContentModel *messageBody = [[MMChatContentModel alloc] init];
    messageBody.type = TypeText;
    messageBody.content = text;
    
    //2.对消息体某些字段传值,返回消息体
    BOOL isGroup = NO;
    NSString *chatType = @"chat";
    MMConversationType cType = MMConversationType_Chat;
    if ([cmd isEqualToString:@"groupMsg"]) {
        isGroup = YES;
        chatType = @"groupchat";
        cType = MMConversationType_Group;
    }
    //定义消息类型和消息部分信息
    MMMessage *message = [[MMMessage alloc] initWithToUser:toUser
                                                toUserName:toUserName
                                                  fromUser:[ZWUserModel currentUser].userId
                                              fromUserName:[ZWUserModel currentUser].userName
                                                  chatType:chatType
                                                  isSender:YES
                                                       cmd:cmd
                                                     cType:cType
                                               messageBody:messageBody];
    message.messageType = MMMessageType_Text;
    message.deliveryState = MMMessageDeliveryState_Delivering;
    message.conversation = toUser;
    message.fromPhoto = photoUrl;
    
    //3.发送请求
    [ZWSocketManager SendMessageWithMessage:message complation:^(NSError * _Nullable error, id  _Nullable data) {//这个data  就是刚刚我发出去的消息模型
        [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
            aCompletionBlock(message);
        }];
    }];
    return message;
}

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
                           completion:(void(^) (MMMessage *_Nonnull message))aCompletionBlock
{
    
    //1.对消息体某些字段传值,返回消息体
    BOOL isGroup = NO;
    NSString *chatType = @"chat";
    MMConversationType cType = MMConversationType_Chat;
    if ([cmd isEqualToString:@"groupMsg"]) {
        isGroup = YES;
        chatType = @"groupchat";
        cType = MMConversationType_Group;
    }
    
    MMMessage *message = [[MMMessage alloc] initWithToUser:toUser
                                                toUserName:toUserName
                                                  fromUser:[ZWUserModel currentUser].userId
                                              fromUserName:[ZWUserModel currentUser].userName
                                                  chatType:chatType
                                                  isSender:YES
                                                       cmd:cmd
                                                     cType:cType
                                               messageBody:model];
    message.messageType = MMMessageType_Text;
    message.deliveryState = MMMessageDeliveryState_Delivering;
    message.conversation = toUser;
    message.fromPhoto = photoUrl;
    
    //3.发送请求
    [MMRequestManager aSendTextMessageWithModel:message completion:^(NSError * _Nonnull error) {
        [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
            aCompletionBlock(message);
        }];
    }];
    
    return message;
    
}

/**
 改变发送状态
 
 @param aMessage 消息体
 @param isReSend 是否是重发
 @param error 错误状态
 @param aStausChange 发送状态
 */
- (void)sendMessage:(MMMessage *)aMessage
               isReSend:(BOOL)isReSend
                  error:(NSError *)error
       aSendStausChange:(void(^)(void))aStausChange
{
    
    
    //发送成功状态改变,发送失败状态改变
    if (!error) {
        aMessage.deliveryState = MMMessageDeliveryState_Delivered;
    }else{
        aMessage.deliveryState = MMMessageDeliveryState_Failure;
    }
    
    //重发则不保存
    if (!isReSend) {
        [self saveMessageAndConversationToDBWithMessage:aMessage];
    }

    
    // 更新消息
    [[MMChatDBManager shareManager] updateMessage:aMessage];

    // 数据库添加或者刷新会话
    [[MMChatDBManager shareManager] addOrUpdateConversationWithMessage:aMessage isChatting:YES];
    
    aStausChange();
}

/**
 保存消息和会话
 
 @param message 消息模型
 */
- (void)saveMessageAndConversationToDBWithMessage:(MMMessage *)message {
    
    message.localtime = [[NSDate date] timeStamp];
    message.timestamp = [[NSDate date] timeStamp];
    
    
    // 发送给自己的消息不插入数据库，等到接收到自己的消息后再插入数据库
    if (![message.fromID isEqualToString:message.toID]) {
        // 消息插入数据库
        [[MMChatDBManager shareManager] addMessage:message];
    }
    
    // 数据库添加或者刷新会话
    [[MMChatDBManager shareManager] addOrUpdateConversationWithMessage:message isChatting:YES];
}



- (MMMessage *)sendImgMessage:(NSString *)filePath
                    imageSize:(CGSize)size
                       toUser:(NSString *)toUser
                   toUserName:(NSString *)toUserName
               toUserPhotoUrl:(NSString *)photoUrl
                          cmd:(NSString *)cmd
                   completion:(void(^)(MMMessage *message))aCompletionBlock
{
    
    //1.对内容模型赋值
    MMChatContentModel *messageBody = [[MMChatContentModel alloc] init];
    messageBody.type = TypePic;
    messageBody.filePath = filePath;
    messageBody.width = size.width;
    messageBody.height = size.height;
    
    //2.对消息体某些字段传值,返回消息体
    BOOL isGroup = NO;
    NSString *chatType = @"chat";
    MMConversationType cType = MMConversationType_Chat;
    if ([cmd isEqualToString:@"groupMsg"]) {
        isGroup = YES;
        chatType = @"groupchat";
        cType = MMConversationType_Group;
    }
    
    MMMessage *message = [[MMMessage alloc] initWithToUser:toUser toUserName:toUserName fromUser:[ZWUserModel currentUser].userId fromUserName:[ZWUserModel currentUser].userName chatType:chatType isSender:YES cmd:cmd cType:cType messageBody:messageBody];
    message.messageType = MMMessageType_Image;
    message.deliveryState = MMMessageDeliveryState_Delivering;
    message.conversation = toUser;
    message.fromPhoto = photoUrl;
    
    //3.发送请求
    [self getUrl:filePath completion:^(NSString *url) {
        MMLog(@"url ===========%@",url);
        if ([url isEqualToString:@""]) {
            messageBody.content = filePath;
            NSString *domain = @"com.MyCompany.MyApplication.ErrorDomain";
            NSString *desc = NSLocalizedString(@"Unable to…", @"");
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
            NSError *error = [NSError errorWithDomain:domain
                                                 code:-101
                                             userInfo:userInfo];
            [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
                aCompletionBlock(message);
            }];
        }else{
            messageBody.content = url;
            [MMRequestManager aSendPicMessageWithModel:message completion:^(NSError * _Nonnull error) {
                [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
                    aCompletionBlock(message);
                }];
            }];
        }
    }];
    return message;
}

- (void)getUrl:(NSString *)filePath completion:(void(^)(NSString *url))aCompletionBlock
{
    
    //获取可上传的地址,如果上传的地址存在则直接请求上传,如不过不存在就先请求上传的地址
    if (upLoadUrl.length) {
        
        [self uploadWithFilePath:filePath completion:^(NSString *url) {
            aCompletionBlock(url);
        }];
        
    }else{
        
        [MMRequestManager fetchUpLoadFileUrlCompletion:^(NSDictionary * _Nonnull dict, NSError * _Nonnull error) {
            if (!error) {
                if (K_APP_REQUEST_OK(dict[@"ret"])) {
                    NSString *uploadApi1 = dict[@"uploadApi1"];
                    NSString *uploadApi2 = dict[@"uploadApi2"];
                    NSString *uploadApi3 = dict[@"uploadApi3"];
#warning 这里的上传地址改了参数且去掉端口8003才能上传
                    upLoadUrl = [uploadApi1 containsString:@"http://"] ? uploadApi1 : ([uploadApi2 containsString:@"http://"] ? uploadApi2 : uploadApi3);
                    upLoadUrl = [upLoadUrl stringByReplacingOccurrencesOfString:@":8003" withString:@""];
                    [self uploadWithFilePath:filePath
                                  completion:^(NSString *url) {
                        aCompletionBlock(url);
                    }];
                }else{
                    MMLog(@"获取文件地址失败");
                }
            }
        }];
        
    }
    
}

- (void)uploadWithFilePath:(NSString *)filePath completion:(void(^)(NSString *url))aCompletionBlock
{
    [MMRequestManager upLoadFileWithFilePath:filePath fileUrl:upLoadUrl completion:^(NSData * _Nonnull data, NSError * _Nonnull error) {
        
        if (!error) {
            NSString *nameStr =  [[NSString alloc] initWithData: data encoding:NSUTF8StringEncoding];
            NSData *jsonData = [nameStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            
            MMLog(@"文件内容:=====================%@",dataDic);
            NSString *urlMessage = @"";
            if ([dataDic[@"code"] isEqualToString:@"1"] ) {
                urlMessage = dataDic[@"message"];//获取到网上的地址
                aCompletionBlock(urlMessage);
            }else{
                MMLog(@"文件上传失败");
                aCompletionBlock(urlMessage);
                [self showAlertWithMessage:@"上传文件失败"];
            }
        }
        else{
            aCompletionBlock(@"");
        }
    }];

}

- (MMMessage *)sendFileMessage:(NSString *)fileName
                        toUser:(NSString *)toUser
                    toUserName:(NSString *)toUserName
                toUserPhotoUrl:(NSString *)photoUrl
                           cmd:(NSString *)cmd
                    completion:(void(^)(MMMessage *message))aCompletionBlock
{
    
    //1.对内容模型赋值
    NSString *path = [[MMFileTool fileMainPath] stringByAppendingPathComponent:fileName];
    double size = [MMFileTool fileSizeWithPath:path];
    
    //判断类型
    NSNumber *type = [MMMessageHelper fileType:[fileName pathExtension]];
    if (!type) {
        type = @0;
    }
    
    MMChatContentModel *messageBody = [[MMChatContentModel alloc] init];
    messageBody.type = TypeFile;
    messageBody.length = [NSString stringWithFormat:@"%.0f",size];
    MMLog(@"%@",[NSString stringWithFormat:@"%.0f",size]);
    messageBody.content = path;
    messageBody.fileName = fileName;
    
    //2.对消息体某些字段传值,返回消息体
    BOOL isGroup = NO;
    NSString *chatType = @"chat";
    MMConversationType cType = MMConversationType_Chat;
    if ([cmd isEqualToString:@"groupMsg"]) {
        isGroup = YES;
        chatType = @"groupchat";
        cType = MMConversationType_Group;
    }
    
    MMMessage *message = [[MMMessage alloc] initWithToUser:toUser toUserName:toUserName fromUser:[ZWUserModel currentUser].userId fromUserName:[ZWUserModel currentUser].userName chatType:chatType isSender:YES cmd:cmd cType:cType messageBody:messageBody];
    message.messageType = MMMessageType_Doc;
    message.deliveryState = MMMessageDeliveryState_Delivering;
    message.conversation = toUser;
    message.fromPhoto = photoUrl;
    
    //3.发送请求
    [self getUrl:path completion:^(NSString *url) {
        MMLog(@"url ===========%@",url);
        if ([url isEqualToString:@""]) {
            messageBody.content = path;
            NSString *domain = @"com.MyCompany.MyApplication.ErrorDomain";
            NSString *desc = NSLocalizedString(@"Unable to…", @"");
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
            NSError *error = [NSError errorWithDomain:domain
                                                 code:-101
                                             userInfo:userInfo];
            [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
                aCompletionBlock(message);
            }];
        }else{
            messageBody.content = url;
            [MMRequestManager aSendFileMessageWithModel:message completion:^(NSError * _Nonnull error) {
                [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
                    aCompletionBlock(message);
                }];
            }];
        }
    }];
    return message;
    
}

- (MMMessage *)sendVoiceMessageWithVoicePath:(NSString *)voicePath
                                      toUser:(NSString *)toUser
                                  toUserName:(NSString *)toUserName
                              toUserPhotoUrl:(NSString *)photoUrl
                                         cmd:(NSString *)cmd
                                  completion:(void(^)(MMMessage *message))aCompletionBlock
{
    
    //1.转换格式wav-->amr
    //删除之前的后缀名并改写成amr格式
    NSString *amrPath   = [[voicePath stringByDeletingPathExtension] stringByAppendingPathExtension:@"amr"];
    //转成amr格式并保存
    [VoiceConverter ConvertWavToAmr:voicePath amrSavePath:amrPath];
    
    
    //2.对内容模型赋值
    MMChatContentModel *messageBody = [[MMChatContentModel alloc] init];
    messageBody.type = TypeVoice;//设置类型
    messageBody.filePath = voicePath;//本地音频
    messageBody.duration = [[MMRecordManager shareManager] durationWithVideo:[NSURL fileURLWithPath:voicePath]];
    
    //2.对消息体某些字段传值,返回消息体
    BOOL isGroup = NO;
    NSString *chatType = @"chat";
    MMConversationType cType = MMConversationType_Chat;
    if ([cmd isEqualToString:@"groupMsg"]) {
        isGroup = YES;
        chatType = @"groupchat";
        cType = MMConversationType_Group;
    }
    
    MMMessage *message = [[MMMessage alloc] initWithToUser:toUser toUserName:toUserName fromUser:[ZWUserModel currentUser].userId fromUserName:[ZWUserModel currentUser].userName chatType:chatType isSender:YES cmd:cmd cType:cType messageBody:messageBody];
    message.messageType = MMMessageType_Voice;
    message.deliveryState = MMMessageDeliveryState_Delivering;
    message.conversation = toUser;
    message.fromPhoto = photoUrl;
    
    //3.发送请求
    [self getUrl:amrPath completion:^(NSString *url) {
        MMLog(@"url ===========%@",url);
        if ([url isEqualToString:@""]) {
            messageBody.content = voicePath;
            NSString *domain = @"com.MyCompany.MyApplication.ErrorDomain";
            NSString *desc = NSLocalizedString(@"Unable to…", @"");
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
            NSError *error = [NSError errorWithDomain:domain
                                                 code:-101
                                             userInfo:userInfo];
            [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
                aCompletionBlock(message);
            }];
        }else{
            messageBody.content = url;
            [MMRequestManager aSendVoiceMessageWithModel:message completion:^(NSError * _Nonnull error) {
                [self sendMessage:message isReSend:NO error:error aSendStausChange:^{
                    aCompletionBlock(message);
                }];
            }];
        }
        //删除转化后的amr文件
        [MMFileTool removeFileAtPath:amrPath];
    }];
    
    return message;
    
}

@end
