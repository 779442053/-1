//
//  MMRequestManager.m
//  EasyIM
//
//  Created by momo on 2019/4/25.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMRequestManager.h"

#import "ZWUserModel.h"
#import "ZWDataManager.h"
@interface MMRequestManager ()

@end

@implementation MMRequestManager

+ (void)createSocketConfig
{
    
    //自定义配置连接环境
    MMConnectConfig *connectConfig = [[MMConnectConfig alloc] init];
    connectConfig.host = [ZWUserModel currentUser].host;
    connectConfig.port = [ZWUserModel currentUser].port;
    
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:connectConfig];
    
}

/**
 * 1v1 单聊邀请
 */
+ (void)sendVedioRequestWithToId:(NSString *)toId
                        callType:(MMCallType)callType
                        callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSDictionary *dic = @{
                          @"type":@"req",
                          @"xns":@"xns_user",
                          @"cmd":@"callUser",
                          @"sessionID":[ZWUserModel currentUser].sessionID,
                          @"toId":toId,
                          @"callType":callType == MMCallTypeVoice? @"0":@"1",
                          @"timeStamp":[MMDateHelper getNowTime]
                          };
    
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dic.innerXML];
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:MMRequestType_vedio requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        NSLog(@"视频请求数据：%@",data);
        if ([data isKindOfClass:[NSDictionary class]]) {
            MMCallSessionModel *model = [MMCallSessionModel yy_modelWithDictionary:data];
            callBack(model,error);
        }
    }];
    
}

/**
 *  1vM群音视频呼叫
 */
+(void)sendVideoOrAudioWithGroupId:(NSString *)strGroupid
                       andCallType:(MMCallType)callType
                          callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack{
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSDictionary *dicParams = @{
                                @"type":@"req",
                                @"xns":@"xns_group",
                                @"timeStamp":[MMDateHelper getNowTime],
                                @"cmd":@"CallGroup",
                                @"sessionID":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                                @"fromId":[ZWUserModel currentUser]?[ZWUserModel currentUser].userId:@"",
                                @"startId":[ZWUserModel currentUser]?[ZWUserModel currentUser].userId:@"",
                                @"groupId":strGroupid,
                                //callType:语音呼叫 3 视频呼叫 4
                                @"callType":callType == MMCallTypeVoice? @"3":@"4",
                                };
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dicParams.innerXML];
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:MMRequestType_vedio requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        NSLog(@"1vM群音视频请求数据：%@",data);
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dicTemp = data;
            
            MMCallSessionModel *model = [MMCallSessionModel yy_modelWithDictionary:dicTemp];
            
            if ([dicTemp.allKeys containsObject:@"frmUid"]) {
                model.fromId = dicTemp[@"frmUid"];
                model.startId = dicTemp[@"frmUid"];
            }
            
            if ([dicTemp.allKeys containsObject:@"groupId"]) {
                model.toId = dicTemp[@"groupId"];
            }
            callBack(model,error);
        }
    }];
}

+ (void)hangUpCallWithToId:(NSString *)toId
                  webrtcId:(NSString *)webrtcId
                  callType:(NSInteger)callType
                  callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSDictionary *dict = @{
                           @"type":@"req",
                           @"xns":@"xns_user",
                           @"cmd":@"HangUpCall",
                           @"sessionID":[ZWUserModel currentUser].sessionID,
                           @"webrtcId":webrtcId,
                           @"toId":toId,
                           @"media":@"",
                           @"callType":@(callType).description,
                           @"timeStamp":[MMDateHelper getNowTime]
                           };
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dict.innerXML];

    
    //3.创建请求的Manage
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:MMRequestType_hangUp requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        //3.1挂断Model处理
        if ([data isKindOfClass:[NSDictionary class]]) {
            MMCallSessionModel *model = [MMCallSessionModel yy_modelWithDictionary:data];
            callBack(model,error);
        }

    }];
    
}

+ (void)rejectCallWithToId:(NSString *)toId
                  webrtcId:(NSString *)webrtcId
                  callType:(NSInteger)callType
                  callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSDictionary *dict = @{
                           @"type":@"req",
                           @"xns":@"xns_user",
                           @"cmd":@"RejectCall",
                           @"sessionID":[ZWUserModel currentUser].sessionID,
                           @"webrtcId":webrtcId,
                           @"toId":toId,
                           @"media":@"",
                           @"callType":@(callType).description,
                           @"timeStamp":[MMDateHelper getNowTime]
                           };
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dict.innerXML];
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:MMRequestType_rejectCall requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        //3.1拒绝Model处理
        if ([data isKindOfClass:[NSDictionary class]]) {
            MMCallSessionModel *model = [MMCallSessionModel yy_modelWithDictionary:data];
            callBack(model,error);
        }
    }];

}
+ (void)checkUserOnlineWithUserId:(NSString *)userId
                         callBack:(void(^)(NSInteger status,NSError *error))callBack
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSDictionary *dict = @{
                           @"type":@"req",
                           @"cmd":@"checkUserOnline",
                           @"sessionID":[ZWUserModel currentUser].sessionID,
                           @"userID":userId
                           };
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dict.innerXML];
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:MMRequestType_checkUserOnline requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([data[@"result"] isEqualToString:@"1"]) {
                NSString *status = data[@"result"];
                callBack([status integerValue] ,nil);
            }else{
                callBack(0 ,error);
            }
        }else{
            callBack(0 ,error);
        }
    }];
}

+ (void)checkUserStatusCallBack:(void(^)(NSInteger status,NSError *error))callBack
{
    
    //1.构造参数
    NSDictionary *param = @{
                            @"cmd":@"userStatus",
                            @"sessionid":[ZWUserModel currentUser].sessionID
                            };
    
    //2.创建Get请求
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API parameters:param success:^(id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *status = responseObject[@"status"];
            callBack([status integerValue] ,nil);
        }
    } failure:^(NSError * _Nonnull error) {
        callBack(0,error);
    }];
    
}




+ (void)queryGroupCallBack:(void(^)(NSArray <MMGroupModel *>*groupList,NSError *error))callBack
{
    
    //0.初始化声明
    NSMutableArray *groupDataList = [NSMutableArray array];
    
    //1.构造参数
    NSDictionary *param = @{
                          @"cmd":@"group",
                          @"sessionId":[ZWUserModel currentUser].sessionID
                          };
    
    //2.创建Get请求
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API parameters:param success:^(id  _Nonnull responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            GetModel *getModel = [GetModel yy_modelWithDictionary:responseObject];
            NSString *xmlStr = [NSString stringWithContentsOfURL:[NSURL URLWithString:getModel.downloadurl] encoding:NSUTF8StringEncoding error:nil];
            NSMutableDictionary *jsonDic = [NSDictionary dictionaryWithXMLString:xmlStr].mutableCopy;
            [jsonDic removeObjectForKey:@"__name"];//去掉解析后带有__name的参数

            NSLog(@"我的群列表请求结果:%@",jsonDic);
            
            if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                id objData = jsonDic[@"list"][@"group"];
                if (objData) {
                    //多个群为数组
                    if ([objData isKindOfClass:[NSArray classForCoder]]) {
                        NSArray *arr = jsonDic[@"list"][@"group"];
                        [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSDictionary *dict = (NSDictionary *)obj;
                            MMGroupModel *groupModel =  [MMGroupModel yy_modelWithDictionary:dict];
                            [groupDataList addObject:groupModel];
                        }];
                    //单个群为字典
                    } else{
                        MMGroupModel *contactsModel = [MMGroupModel yy_modelWithDictionary:objData];
                        [groupDataList addObject:contactsModel];
                    }
                }
                
                callBack(groupDataList,nil);
            }else{
                callBack(groupDataList,nil);
            }
        }
        
    } failure:^(NSError * _Nonnull error) {
        callBack(nil,error);
    }];
    
}

+ (void)aSendPicMessageWithModel:(MMMessage *)aMessage
                      completion:(void(^) (NSError *error))aCompletionBlock
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSString *body = @"";
    MMRequestType requestType = MMRequestType_sendMsg;
    if ([aMessage.type isEqualToString:@"chat"]) {
        body = [NSString stringWithFormat:@"<JoyIM><type>%@</type><cmd>%@</cmd><sessionID>%@</sessionID><toID>%@</toID><toUserName>%@</toUserName><msgID>%@</msgID><msg><slice><type>%@</type><content>%@</content><width>%f</width><height>%f</height></slice></msg></JoyIM>",aMessage.type,aMessage.cmd,aMessage.sessionID,aMessage.toID,aMessage.toUserName,aMessage.msgID,aMessage.slice.type,aMessage.slice.content,aMessage.slice.width,aMessage.slice.height];
        requestType = MMRequestType_sendMsg;
    }else if ([aMessage.type isEqualToString:@"groupchat"]){
        body = [NSString stringWithFormat:@"<JoyIM><type>%@</type><cmd>%@</cmd><sessionID>%@</sessionID><groupID>%@</groupID><msgID>%@</msgID><msg><slice><type>%@</type><content>%@</content><width>%f</width><height>%f</height></slice></msg></JoyIM>",aMessage.type,aMessage.cmd,aMessage.sessionID,aMessage.toID,aMessage.msgID,aMessage.slice.type,aMessage.slice.content,aMessage.slice.width,aMessage.slice.height];
        requestType = MMRequestType_sendGroupMsg;
    }
    
    
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:requestType requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        
        MMLog(@"发送图片消息的error=====%@\n返回的Rsp=======%@",error,data);
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([data[@"result"] isEqualToString:@"1"]) {
                aCompletionBlock(nil);
            }else{
                aCompletionBlock(error);
            }
        }else{
            aCompletionBlock(error);
        }
    }];

}

+ (void)aSendFileMessageWithModel:(MMMessage *)aMessage
                       completion:(void(^) (NSError *error))aCompletionBlock
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSString *body = @"";
    MMRequestType requestType = MMRequestType_sendMsg;
    if ([aMessage.type isEqualToString:@"chat"]) {
        body = [NSString stringWithFormat:@"<JoyIM><type>%@</type><cmd>%@</cmd><sessionID>%@</sessionID><toID>%@</toID><toUserName>%@</toUserName><msgID>%@</msgID><msg><slice><type>%@</type><content>%@</content><length>%@</length></slice></msg></JoyIM>",aMessage.type,aMessage.cmd,aMessage.sessionID,aMessage.toID,aMessage.toUserName,aMessage.msgID,aMessage.slice.type,aMessage.slice.content,aMessage.slice.length];
        requestType = MMRequestType_sendMsg;
    }else if ([aMessage.type isEqualToString:@"groupchat"]){
        body =[NSString stringWithFormat:@"<JoyIM><type>%@</type><cmd>%@</cmd><sessionID>%@</sessionID><groupID>%@</groupID><msgID>%@</msgID><msg><slice><type>%@</type><content>%@</content><length>%@</length></slice></msg></JoyIM>",aMessage.type,aMessage.cmd,aMessage.sessionID,aMessage.toID,aMessage.msgID,aMessage.slice.type,aMessage.slice.content,aMessage.slice.length];
        requestType = MMRequestType_sendGroupMsg;
    }
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:requestType requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        
        MMLog(@"发送文件消息的error=====%@\n返回的Rsp=======%@",error,data);
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([data[@"result"] isEqualToString:@"1"]) {
                aCompletionBlock(nil);
            }else{
                aCompletionBlock(error);
            }
        }else{
            aCompletionBlock(error);
        }
    }];

}

+ (void)aSendVoiceMessageWithModel:(MMMessage *)aMessage
                        completion:(void(^) (NSError *error))aCompletionBlock
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];

    //2.构建TCP请求参数字符串
    NSString *body = @"";
    MMRequestType requestType = MMRequestType_sendMsg;
    if ([aMessage.type isEqualToString:@"chat"]) {
        body = [NSString stringWithFormat:@"<JoyIM><type>%@</type><cmd>%@</cmd><sessionID>%@</sessionID><toID>%@</toID><toUserName>%@</toUserName><msgID>%@</msgID><msg><slice><type>%@</type><content>%@</content><duration>%ld</duration></slice></msg></JoyIM>",aMessage.type,aMessage.cmd,aMessage.sessionID,aMessage.toID,aMessage.toUserName,aMessage.msgID,aMessage.slice.type,aMessage.slice.content,aMessage.slice.duration];        requestType = MMRequestType_sendMsg;
    }else if ([aMessage.type isEqualToString:@"groupchat"]){
        body = [NSString stringWithFormat:@"<JoyIM><type>%@</type><cmd>%@</cmd><sessionID>%@</sessionID><groupID>%@</groupID><msgID>%@</msgID><msg><slice><type>%@</type><content>%@</content><duration>%ld</duration></slice></msg></JoyIM>",aMessage.type,aMessage.cmd,aMessage.sessionID,aMessage.toID,aMessage.msgID,aMessage.slice.type,aMessage.slice.content,aMessage.slice.duration];
        requestType = MMRequestType_sendGroupMsg;
    }
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:requestType requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        
        MMLog(@"发送文件消息的error=====%@\n返回的Rsp=======%@",error,data);
        if ([data isKindOfClass:[NSDictionary class]]) {
            if ([data[@"result"] isEqualToString:@"1"]) {
                aCompletionBlock(nil);
            }else{
                aCompletionBlock(error);
            }
        }else{
            aCompletionBlock(error);
        }
    }];
}

+ (void)aNoticFriendsWithCmd:(NSString *)cmd
                   tagUserId:(NSString *)tagUserId
                        time:(NSString *)time
                         msg:(NSString *)msg
                 aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock
{
    
    //1.构造参数
    NSDictionary *dic = @{
                          @"cmd":cmd,
                          @"sessionid":[ZWUserModel currentUser].sessionID,
                          @"tagUserid":tagUserId,
                          @"time":time,
                          @"msg":msg,
                          @"groupid":@"0",
                          };
    
    //2.构造Get请求
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API parameters:dic success:^(id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            aCompletionBlock(responseObject, nil);
        }
    } failure:^(NSError * _Nonnull error) {
        aCompletionBlock(nil, error);
    }];
}


+ (void)addGroupWithGroupName:(NSString *)groupName
                     bulletin:(NSString *)bulletin
                        theme:(NSString *)theme
                        photo:(NSString *)photo
                     userlist:(NSString *)userlist
                  aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock
{
    
    //1.构造参数
    NSDictionary *dic = @{
                          @"cmd":@"addGroup",
                          @"sessionId":[ZWUserModel currentUser].sessionID,
                          @"groupName":groupName,
                          @"bulletin":bulletin,
                          @"theme":theme,
                          @"photo":@"",
                          @"userlist":userlist,
                          };
    
    //2.构造Get请求
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API parameters:dic success:^(id  _Nonnull responseObject) {
        MMLog(@"%@",responseObject);
        aCompletionBlock(responseObject, nil);
    } failure:^(NSError * _Nonnull error) {
        MMLog(@"%@",error);
        aCompletionBlock(nil, error);
    }];
}






/**
 获取群成员
 
 @param taggroupId 群id
 @param mode mode
 @param aCompletionBlock 结果返回
 */
+ (void)groupMemberWithtaggroupId:(NSString *_Nullable)taggroupId
                             mode:(NSString *_Nullable)mode
                      aCompletion:(void(^)(NSArray<MemberList *> *_Nullable memberList,NSString *_Nullable createId,NSError *_Nullable error))aCompletionBlock
{
    
    NSString *strURL = [NSString stringWithFormat:@"%@/api_im/group/groupmember",HTURL];
    ZWWLog(@"====url =%@",strURL)
    NSDictionary *dicData = @{
                              @"groupid":taggroupId,
                              @"page":@"0",//第一页0
                              @"perpage":@"100"
                              };
    
    [YHUtils POSTWithURLString:strURL
                    parameters:dicData
                       success:^(id  _Nullable responseObject) {
                           
                           NSString *domain = @"NSURLErrorDomain";
                           NSString *desc = responseObject[@"message"];
                           NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
                           NSError *error = [NSError errorWithDomain:domain
                                                                code:0
                                                            userInfo:userInfo];
                           
                           if (responseObject && [responseObject[@"code"] integerValue] == 1) {
                               NSDictionary *_dicTemp = responseObject[@"data"][@"data"];
                               
                               //设置创建者编号
                               NSString *cid;
                               if (_dicTemp && [[_dicTemp allKeys] containsObject:@"createID"]) {
                                   cid = [NSString stringWithFormat:@"%@",_dicTemp[@"createID"]];
                               }
                               
                               if (_dicTemp && [[_dicTemp allKeys] containsObject:@"list"]) {
                                   NSArray<MemberList *> *_memberList = [MemberList mj_objectArrayWithKeyValuesArray:_dicTemp[@"list"]];
                                   
                                   aCompletionBlock(_memberList,cid, nil);
                               }
                               else
                                   aCompletionBlock(nil,nil, error);
                           }
                           else
                               aCompletionBlock(nil,nil, error);
                       }
                       failure:^(NSError *error) {
                           aCompletionBlock(nil,nil,error);
                       }];
}



+ (void)exitGroupWithGroupid:(NSString *)groupid msg:(NSString *)msg
                 aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock
{
    
    //1.构建参数
    NSDictionary *dic = @{
                          @"cmd":@"exitGroup",
                          @"sessionId":[ZWUserModel currentUser].sessionID,
                          @"groupid":groupid,
                          @"msg":msg
                          };
    
    //2.构建Get请求
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API parameters:dic success:^(id  _Nonnull responseObject) {
        aCompletionBlock(responseObject, nil);
    } failure:^(NSError * _Nonnull error) {
        aCompletionBlock (nil, error);
    }];

}


//MARK: - 单聊(群聊)音频接受邀请响应
+ (void)acceptCallWithModel:(MMCallSessionModel *)model
                   callType:(NSInteger)callType
                   aCompletion:(void (^)(NSDictionary * _Nonnull, NSError * _Nonnull))aCompletionBlock
{
    
    //1.构建自定义配置环境
    [self createSocketConfig];
    
    //2.构建TCP请求参数字符串
    NSDictionary *dicParam = @{
                               @"type":@"req",
                               @"cmd":@"AcceptCall",
                               @"xns":@"xns_user",
                               @"timeStamp":[MMDateHelper getNowTime],
                               @"sessionID":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                               @"toId":model.fromId,
                               @"webrtcId":model.webrtcId,
                               @"media":@"",
                               @"callType":@(callType).description
                               };
    
    //群聊语音
    if (callType == 3) {
        dicParam = @{
                     @"type":@"req",
                     @"xns":@"xns_group",
                     @"timeStamp":[MMDateHelper getNowTime],
                     @"cmd":@"AcceptGroupCall",
                     @"sessionID":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                     @"fromId":[ZWUserModel currentUser].userId,
                     @"groupId":model.toId,
                     @"webrtcId":model.webrtcId,
                     @"startId":@"0",
                     @"callType":@"3"
                     };
    }
    
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dicParam.innerXML];
    
    MMLog(@"单聊(群聊)音频接受邀请响应参数......%@",body);
    
    //3.创建请求的Manager
    [[MMGCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:MMRequestType_acceptCall requestBody:body completion:^(NSError * _Nullable error, id  _Nullable data) {
        aCompletionBlock(data,error);
    }];

}


/**
 * 邀请好友入群
 */
+ (void)inviteFrd2GroupWithGroupId:(NSString *)groupId
                          friendId:(NSString *)friendId
                       aCompletion:(void (^)(NSDictionary * dic, NSError * error))aCompletionBlock
{
    
    //1.构建参数
    NSDictionary *dic = @{
                          @"cmd":@"inviteFrd2Group",
                          @"sessionId":[ZWUserModel currentUser].sessionID,
                          @"groupid":groupId,
                          @"friendId":friendId
                          };
    
    //2.构建Get请求
    [[MMApiClient sharedClient] GET:K_APP_REQUEST_API parameters:dic success:^(id  _Nonnull responseObject) {
        aCompletionBlock(responseObject, nil);
    } failure:^(NSError * _Nonnull error) {
        aCompletionBlock (nil, error);
    }];
    
}




//=====================================Model解析==================================/

+ (void)fetchTopicGroupListWithUserId:(NSString *)userId
                                  gid:(NSInteger)gid
                                 page:(NSInteger)page
                                limit:(NSInteger)limit
                           completion:(void(^)(NSArray <MMClassListModel *>*arr, NSError *error))aCompletionBlock
{
    
    //1.配置URL
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",TOP_CIRCLE_URL,@"api/topic/list"];
    NSDictionary *dic = @{
                             @"userId":userId,
                              @"gid":@(gid).description,
                              @"page":@(page).description,
                              @"limit":@(limit).description,
                          };
    
    //2.构造Get请求
    [[MMApiClient sharedClient] GET:baseUrl parameters:dic success:^(id  _Nonnull responseObject) {
        
        MMLog(@"%@",responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"code"] integerValue] == 1) {
                NSArray <MMClassListModel *> *arr  = [MMClassListModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
                MMLog(@"%@",arr);
                aCompletionBlock(arr,nil);
            }else{
                aCompletionBlock(nil,nil);
            }
        }        
    } failure:^(NSError * _Nonnull error) {
        aCompletionBlock(nil,error);
    }];

}

+ (void)fetchClassDetailWithUserId:(NSString *)userId
                               did:(NSInteger)did
                        completion:(void(^)(NSArray <MMClassListModel *>*arr, NSError *error))aCompletionBlock
{
    //1.配置URL
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",TOP_CIRCLE_URL,@"api/topic/content"];
    NSDictionary *dic = @{
                          @"userId":userId,
                          @"did":@(did).description,
                          };
    
    //2.构造Get请求
    [[MMApiClient sharedClient] GET:baseUrl parameters:dic success:^(id  _Nonnull responseObject) {
        
        MMLog(@"%@",responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"code"] integerValue] == 1 && [responseObject containsObject:responseObject[@"data"]]) {
                NSArray <MMClassListModel *> *arr  = [MMClassListModel mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
                MMLog(@"%@",arr);
                aCompletionBlock(arr,nil);
            }else{
                aCompletionBlock(nil,nil);
            }
        }
    } failure:^(NSError * _Nonnull error) {
        aCompletionBlock(nil,error);
    }];

}


//MARK: - 聊天室逻辑处理
/**
 退出当前聊天室
 
 @param roomId 聊天室编号
 @param strPwd 聊天室密码 //md5,可以为空,聊天室用
 @param strMsg 消息
 @param finshback 完成回调
 */
+ (void)liveRoomExitForRoomId:(NSString *_Nonnull)roomId
                       AndPwd:(NSString *_Nullable)strPwd
                       AndMsg:(NSString *_Nullable)strMsg
                andFinishBack:(void(^_Nullable)(id _Nullable responseData,NSString *_Nullable strError))finshback{
    
    NSDictionary *dicParams = @{
                                @"type":@"req",
                                @"cmd":@"exitChatRoom",
                                @"timeStamp":[MMDateHelper getNowTime],
                                @"sessionID":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                                @"passwd":strPwd?strPwd:@"",
                                @"ChatRoomID":roomId,
                                @"msg":strMsg?strMsg:@"你好！我要离开了"
                                };
    
    
    NSString *strBody = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dicParams.innerXML];
    
    [[MMGCDAsyncSocketCommunicationManager sharedInstance]
     socketWriteDataWithRequestType:(MMRequestType_exitChatRoom)
     requestBody:strBody
     completion:^(NSError * _Nullable error, id  _Nullable data) {
         NSLog(@"离开聊天室：%@,error:%@",data,error);
         
         NSDictionary *dicTemp = data;
         if ([data isKindOfClass:[NSDictionary class]]) {
             if ([[dicTemp allKeys] containsObject:@"err"]) {
                 [MMProgressHUD showHUD:dicTemp[@"err"]];
             }
             else{
                 //发送离开聊天室的通知
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:K_EXIT_ChAT_ROOM
                  object:nil
                  userInfo:@{
                             K_CHAT_ROMM_ID:dicTemp[K_CHAT_ROMM_ID],
                             K_CHAT_USER_ID:dicTemp[K_CHAT_USER_ID]
                             }];
                 
                 finshback(data,nil);
             }
         }
         else{
             NSLog(@"离开聊天室失败！详见：%@",error);
             [MBProgressHUD showError:error.localizedDescription];
         }
     }];
}

/**
 聊天室发送消息/礼物/红包
 http://apidoc.joysw.cn/web/#/1?page_id=63
 
 @param roomId 聊天室编号
 @param strMsg 消息内容
 @param giftDic 礼物对象(没有传空)
         @{
           @"giftcount":@"礼物数量",
           @"gift":@"礼物编号",
           @"toID":@"如为0则是发送给聊天室所有人，否则发给指定toID的人"
         }
 @param redPacketDic 红包对象(没有传空)
         @{
            @"money":@"红包金额",
            @"toID":@"如为0则是发送给聊天室所有人，否则发给指定toID的人"
         }
 @param finshback 事件完成回调
 */
+ (void)liveRoomSendMessageOrGiftForRoomId:(NSString *_Nonnull)roomId
                                AndMessage:(NSString *_Nullable)strMsg
                                  orGiftDic:(NSDictionary *_Nullable)giftDic
                             orRedPacketDic:(NSDictionary *_Nullable)redPacketDic
                             andFinishBack:(void(^_Nullable)(id _Nullable responseData,NSString *_Nullable strError))finshback{
    
    //消息对象、礼物编号、红包编号至少有一个不为空
    if (!strMsg && !giftDic && !redPacketDic) {
        [MMProgressHUD showHUD:@"参数有误"];
        return;
    }
    
    NSMutableDictionary *dicParams = [NSMutableDictionary
                      dictionaryWithDictionary:@{
                                                 @"type":@"req",
                                                 @"cmd":@"sendChatRoomMsg",
                                                 @"sessionID":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                                                 //发送者ID
                                                 @"fromID":[ZWUserModel currentUser]?[ZWUserModel currentUser].userId:@"",
                                                 //发送者的名字
                                                 @"senderName":[ZWUserModel currentUser].nickName,
                                                 //聊天室ID
                                                 @"ChatRoomID":roomId,
                                                 //如为0则是发送给聊天室所有人，否则发给指定toID的人
                                                 @"toID":@"0",
                                                 @"msgType":@"broadcast"
                                                 }];
    
    //设置消息
    if (strMsg) {
        [dicParams setValue:strMsg forKey:@"msg"];
    }
    
    //礼物,标签中不能什么也不填否则服务端解析出错,0-无礼物
    if (giftDic) {
        [dicParams setValue:giftDic[@"gift"] forKey:@"gift"];
        [dicParams setValue:giftDic[@"giftcount"] forKey:@"giftcount"];
        [dicParams setValue:redPacketDic[@"toID"] forKey:@"toID"];
    }
    else{
        [dicParams setValue:@"0" forKey:@"gift"];
        [dicParams setValue:@"0" forKey:@"giftcount"];
    }
    
    //红包,标签中不能什么也不填否则服务端解析出错，0-无红包
    if (redPacketDic) {
        [dicParams setValue:redPacketDic[@"money"] forKey:@"money"];
        [dicParams setValue:redPacketDic[@"toID"] forKey:@"toID"];
    }
    else{
        [dicParams setValue:@"0" forKey:@"money"];
    }
    
    NSString *strBody = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dicParams.innerXML];
    
    [[MMGCDAsyncSocketCommunicationManager sharedInstance]
     socketWriteDataWithRequestType:(MMRequestType_sendChatRoomMsg)
                        requestBody:strBody
                         completion:^(NSError * _Nullable error, id  _Nullable data) {
                             NSLog(@"聊天室消息发送：%@,error:%@",data,error);
                             
                             if (!data && error) {
                                 NSLog(@"聊天室消息发送 dicParams:%@",dicParams);
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [MBProgressHUD showError:error.localizedDescription];
                                 });
                                 return;
                             }
                             
                             NSDictionary *dicTemp = data;
                             if (![data isKindOfClass:[NSDictionary class]]) {
                                 dicTemp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                             }
                    
                             //成功返回1
                             if (([[dicTemp allKeys] containsObject:@"result"] && [dicTemp[@"result"] integerValue] == 1) || ![[dicTemp allKeys] containsObject:@"err"]) {
                                 finshback(dicTemp,nil);
                             }
                             else{
                                 NSLog(@"聊天室消息发送失败！详见：%@",error);
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [MBProgressHUD showError:error.localizedDescription];
                                 });
                             }
                         }];
}



/**
 加入聊天室

 @param strRoomId 聊天室编号
 @param strPwd 聊天室密码 //md5,可以为空,聊天室用
 @param strMsg 加入信息
 @param finishBack 操作回调
 */
+ (void)liveRoomJoinForRoomId:(NSString *_Nonnull)strRoomId
                       AndPwd:(NSString *_Nullable)strPwd
                   AndMessage:(NSString *_Nullable)strMsg
                AndFinishBack:(void(^_Nullable)(NSString *strError,id _Nullable responseData))finishBack{
    
    [MBProgressHUD showMessage:@"加入中..."];
    NSDictionary *dicParams = @{
                                @"type":@"req",
                                @"cmd":@"joinChatRoom",
                                @"timeStamp":[MMDateHelper getNowTime],
                                @"sessionID":[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"",
                                @"passwd":strPwd?strPwd:@"",
                                @"ChatRoomID":strRoomId,
                                @"msg":@"你好！我想加入聊天室"
                                };
    
    NSString *strBody = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dicParams.innerXML];

    [[MMGCDAsyncSocketCommunicationManager sharedInstance]
     socketWriteDataWithRequestType:(MMRequestType_joinChatRoom)
     requestBody:strBody
     completion:^(NSError * _Nullable error, id  _Nullable data) {
         NSLog(@"加入聊天室：%@,error:%@",data,error);
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [MBProgressHUD hideHUD];
         });
         
         if (!data && error) {
             NSLog(@"加入聊天室 dicParams:%@",dicParams);
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MMProgressHUD showHUD:error.localizedDescription];
             });
             
             return;
         }
         
         NSDictionary *dicTemp = data;
         if (![data isKindOfClass:[NSDictionary class]]){
             dicTemp = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
         }
         
         if (finishBack) {
             if ([[dicTemp allKeys] containsObject:@"err"]) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MMProgressHUD showHUD:dicTemp[@"err"]];
                 });
             }
             else{
                 finishBack(nil,dicTemp);
                 
                 NSString *strUId = [NSString stringWithFormat:@"%@",dicTemp[K_CHAT_USER_ID]];
                 
                 //发送进入聊天室的通知
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:K_JOIN_ChAT_ROOM
                  object:nil
                  userInfo:@{
                             K_CHAT_ROMM_ID:dicTemp[K_CHAT_ROMM_ID],
                             K_CHAT_USER_ID:strUId
                             }];
             }
         }
     }];
}

@end
