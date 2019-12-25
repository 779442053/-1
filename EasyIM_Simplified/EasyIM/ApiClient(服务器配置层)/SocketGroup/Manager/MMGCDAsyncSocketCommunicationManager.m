//
//  MMGCDAsyncSocketCommunicationManager.m
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMGCDAsyncSocketCommunicationManager.h"

//Socket
#import "MMErrorManager.h"
#import "MMSocketModel.h"
#import "MMConnectConfig.h"
#import "MMGCDAsyncSocketManager.h"

//Tools
#import "AFNetworkReachabilityManager.h"
#import "MMClient.h"


//XmlParse
#import "XMLDictionary.h"
#import "AppDelegate.h"

//ViewCtroller
#import "LoginVC.h"
#import "AddFriendStatusViewController.h"

//Defines
#import "MMDefines.h"
#import "NSObject+MMAlert.h"
//声音播放
#import <AVFoundation/AVFoundation.h>

@interface MMGCDAsyncSocketCommunicationManager ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString *socketAuthAppraisalChannel;  //socket验证通道,支持多通道
@property (nonatomic, strong) NSMutableDictionary *requestDic;
@property (nonatomic, strong) MMGCDAsyncSocketManager *socketManager;
@property (nonatomic, assign) NSTimeInterval interval;  //服务器与本地时间的差值
@property (nonatomic, strong) MMConnectConfig *connectConfig;

@property (nonatomic, strong) NSMutableArray *dataArr;

@property (nonatomic, strong) NSString *beatBody;

/** 音视频邀请声音播放对象 */
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;

@end

@implementation MMGCDAsyncSocketCommunicationManager

@dynamic connectStatus;

#pragma mark - 单例

+ (MMGCDAsyncSocketCommunicationManager *)sharedInstance
{
    static MMGCDAsyncSocketCommunicationManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.socketManager = [MMGCDAsyncSocketManager sharedInstance];
    self.requestDic = [NSMutableDictionary dictionary];
    [self startMonitoringNetwork];
    return self;
}
#pragma mark - SocketMethod
- (void)createSocketWithConfig:(nonnull MMConnectConfig *)config
{
    if (!config.host.length) {
        return;
    }
    self.connectConfig = config;
    [self.socketManager changeHost:config.host port:config.port];
    [self.socketManager connectSocketWithDelegate:self];
}
///断开连接
- (void)disconnectSocket
{
    [self.socketManager disconnectSocket];
}
- (void)socketWriteDataWithRequestType:(MMRequestType)type
                           requestBody:(nonnull NSString *)body
                            completion:(nullable SocketDidReadBlock)callback
{
    if (self.socketManager.connectStatus == -1) {
        if (callback) {
            callback([MMErrorManager errorWithErrorCode:2003],
                     nil);
        }
        return;
    }
    
    if (callback) {
        [self.requestDic setObject:callback forKey:@(type).description];
    }
    [self.socketManager socketWriteData:body];
}

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(uint16_t)port
{
    [self.socketManager socketBeginReadData];
}
//Socket连接失败回调
- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)err
{
    [self.socketManager socketDidDisconectBeginSendReconnect:_beatBody];
}
//Socket成功发送数据后返回数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.dataArr addObject:data];
    [self.socketManager socketBeginReadData];
    [self.dataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *objData = [NSData dataWithData:obj];
        [self  dealWithData:objData];
        [self.dataArr removeObject:obj];
    }];
}
- (void)differenceOfLocalTimeAndServerTime:(long long)serverTime
{
    if (serverTime == 0) {
        self.interval = 0;
        return;
    }
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    self.interval = serverTime - localTimeInterval;
}

- (void)startMonitoringNetwork
{
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    __weak __typeof(&*self) weakSelf = self;
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                if (weakSelf.socketManager.connectStatus != -1) {
                    [self disconnectSocket];//没有网,就断开连接
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            default:
                break;
        }
    }];
}
#pragma mark - Getter
- (MMSocketConnectStatus)connectStatus
{
    return self.socketManager.connectStatus;
}
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr =[[NSMutableArray alloc] init];
    }
    return _dataArr;
}
/**
 处理Tcp获得的消息
 */
- (void)dealWithData:(NSData *)data
{
    NSData *bodyData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
    NSString *newMessage = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    if ([newMessage containsString:@"<JoyIM>"] && [newMessage containsString:@"</JoyIM>"]) {
        NSMutableDictionary *jsonDic = [NSDictionary dictionaryWithXMLString:newMessage].mutableCopy;
        [jsonDic removeObjectForKey:@"__name"];//删除带有__name的参数
        SocketDidReadBlock didReadBlock;
        NSString *errString = jsonDic[@"err"];
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:[jsonDic.allKeys containsObject:@"result"]? [jsonDic[@"result"] integerValue]:-1
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: errString.checkTextEmpty?errString :  ([jsonDic.allKeys containsObject:@"desc"]?jsonDic[@"desc"]:@"未知错误")
                                                    }];
        
        NSString *strCMD = [NSString stringWithFormat:@"%@",jsonDic[@"cmd"]];
        NSInteger type = ZWGCDSocketTCPCmdTypeEnum(strCMD);
        switch (type) {
            /** heartBeat 心跳包 */
            case GCDSocketTCPCmdTypeHeartBeat:
                return;
            //MARK:下线通知
            //全局通知一个用户下线暂不用直接返回
            case GCDSocketTCPCmdTypeUpdateuserstate:
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_LINE object:jsonDic];
                return;
            //MARK:好友上线通知
            case GCDSocketTCPCmdTypeFriendStatus:
                return;
            //MARK:邀请好友入群
            case GCDSocketTCPCmdTypeInviteFrd2Group:
                break;
            //MARK:好友通知
            case  GCDSocketTCPCmdTypeHasBulletin:
                [[NSNotificationCenter defaultCenter] postNotificationName:FriendChangeNotifion object:jsonDic];
                return;
            //MARK:视频呼叫返回状态(对方等待通知界面)
            //callUser  1v1音视频呼叫
            //CallGroup 1vM群组音视频呼叫
            case  GCDSocketTCPCmdTypeCallUser:
            case  GCDSocketTCPCmdTypeCallGroup:
            {
                //接收到对方的视频请求
                NSString *fUId = [jsonDic.allKeys containsObject:@"frmUid"]?jsonDic[@"frmUid"]:jsonDic[@"fromId"];
                if (![fUId isEqualToString:[ZWUserModel currentUser].userId]) {
                    
                    //循环播放提示音，在接受或拒绝或超时时关闭播放
                    [YHUtils playVoiceForAudioAndVideo:^(AVAudioPlayer *_Nullable _avaudio) {
                        _avAudioPlayer = _avaudio;
                    }];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Request object:nil userInfo:jsonDic];
                }
                //发起人(不播放声音，否则无法关闭)
                else{
                    //发视频邀请的Response
                    didReadBlock = self.requestDic[@(MMRequestType_vedio).description];
                    if (didReadBlock) {
                        didReadBlock(nil, jsonDic);
                    }
                }
            }
                return;
            //MARK:1.获取登陆消息
            case GCDSocketTCPCmdTypeLogin:
            {
                //1.1 处理登陆时的数据,并返回结果
                if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                    didReadBlock = self.requestDic[@(MMRequestType_login).description];
                    if (didReadBlock) {
//                        [self didConnectionAuthAppraisal:jsonDic[@"sessionID"]];
//                        didReadBlock(error, jsonDic);
                    }
                //1.2 处理在别的设备登入你的账号时
                }else{
                    [self  alert:jsonDic];
                }
            }
                break;
            //MARK:2.发送消息回调
            case GCDSocketTCPCmdTypeSendMsg:
            {
                didReadBlock = self.requestDic[@(MMRequestType_sendMsg).description];
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                }
            }
                break;
            //MARK:3.读取消息
            case GCDSocketTCPCmdTypeFetchMsg:
            {
                //播放消息声音
                [YHUtils playVoiceForMessage];
                [[MMClient  sharedClient] addHandleChatMessage:jsonDic];
            }
                break;
            //MARK:4.挂断
            case GCDSocketTCPCmdTypeHangUpCall:
            {
                [self stopAndReleaseAudioPlayer];
                [YHUtils closeVoiceAudioAndVideo];
                
                //如果对方挂断则通知对方已挂断
                if (![jsonDic[@"fromId"] isEqualToString:[ZWUserModel currentUser].userId]) {
                    //...通知...
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
                }else{
                    //挂断的Response
                    if (![jsonDic[@"webrtcId"] isEqualToString:[ZWUserModel currentUser].userId]) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
                    }else{
                        didReadBlock = self.requestDic[@(MMRequestType_hangUp).description];
                        if (didReadBlock) {
                            didReadBlock(nil, jsonDic);
                        }
                    }
                }
            }
                break;
            //MARK:5.接受音视频邀请(AcceptCall 1v1、AcceptGroupCall 1vM)
            case GCDSocketTCPCmdTypeAcceptCall:
            case GCDSocketTCPCmdTypeAcceptGroupCall:
            {
                [self stopAndReleaseAudioPlayer];
                NSString *fUId = [jsonDic.allKeys containsObject:@"frmUid"]?jsonDic[@"frmUid"]:jsonDic[@"fromId"];
                if (![fUId isEqualToString:[ZWUserModel currentUser].userId]) {
                    //振动手机提示
                    [YHUtils vibratingCellphone];
                    //对方接受邀请,通知发请求者改变此时状态
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Accept object:nil userInfo:jsonDic];
                }
                //发起人
                else{
                    //发起请求的Response
                    //接受邀请,返回Rsp回调
                    didReadBlock = self.requestDic[@(MMRequestType_acceptCall).description];
                    if (didReadBlock) {
                        didReadBlock(nil, jsonDic);
                    }
                }
            }
                break;
            //MARK:6.拒绝视频邀请(RejectCall 1v1、RejectGroupCall 1vM)
            case GCDSocketTCPCmdTypeRejectCall:
            case GCDSocketTCPCmdTypeRejectGroupCall:
            {
                [self stopAndReleaseAudioPlayer];
                [YHUtils closeVoiceAudioAndVideo];
                //6.1拒绝邀请的Rsp
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
            }
                break;
            //MARK:7.读取群消息 fetchGroupMsg */
            case GCDSocketTCPCmdTypeFetchGroupMsg:
            {
                //群免打扰设置处理
                NSString *strGroupId = [NSString stringWithFormat:@"%@",jsonDic[@"list"][@"group"][@"groupID"]];
                NSString *strUserId = [[NSUserDefaults standardUserDefaults] stringForKey:strGroupId];
                if (strUserId.checkTextEmpty && [ZWUserModel currentUser] && [[ZWUserModel currentUser].userId isEqualToString:strUserId]) {
                    MMLog(@"用户[%@]已开启对群[%@]消息免打扰",strUserId,strGroupId);
                }
                else{
                    //播放消息声音
                    [YHUtils playVoiceForMessage];
                }
                [[MMClient  sharedClient] addHandleGroupMessage:jsonDic];
            }
                break;
            //MARK:8.检查用户是否在线 checkUserOnline
            case GCDSocketTCPCmdTypeCheckUserOnline:
            {
                didReadBlock = self.requestDic[@(MMRequestType_checkUserOnline).description];
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                }
            }
                break;
            //MARK:9.发群消息回调 groupMsg
            case GCDSocketTCPCmdTypeGroupMsg:
            {
                didReadBlock = self.requestDic[@(MMRequestType_sendGroupMsg).description];
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                }
            }
                break;
            //MARK:10.加好友回调 addFriend
            case GCDSocketTCPCmdTypeAddFriend:
            {
                didReadBlock = self.requestDic[@(MMRequestType_addFriend).description];
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                }
            }
                break;
            //MARK:11.解散群回调 deleteGroup
            case GCDSocketTCPCmdTypeDeleteGroup:
            {
                
            }
                break;
            //MARK:12.退出群回调 exitGroup
            case GCDSocketTCPCmdTypeExitGroup:
            {
                //暂时先这么写,以后放到通知列表里
                if (![jsonDic[@"fromID"] isEqualToString:[ZWUserModel currentUser].userId]) {
                    [self showAlertWithMessage:[NSString stringWithFormat:@"%@已退群出%@群",jsonDic[@"fromID"],jsonDic[@"groupID"]]];
                }
            }
                break;
                
            //MARK:13.加入聊天室 joinChatRoom
            case GCDSocketTCPCmdTypeJoinChatRoom:
            {
                didReadBlock = self.requestDic[@(MMRequestType_joinChatRoom).description];
                
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                }
                else{
                    //发送进入聊天室的通知
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:K_JOIN_ChAT_ROOM
                     object:nil
                     userInfo:@{
                                K_CHAT_ROMM_ID:jsonDic[K_CHAT_ROMM_ID],
                                K_CHAT_USER_ID:jsonDic[K_CHAT_USER_ID]
                                }];
                }
            }
                break;
                
            //MARK:14.离开聊天室 exitChatRoom
            case GCDSocketTCPCmdTypeExitChatRoom:
            {
                didReadBlock = self.requestDic[@(MMRequestType_exitChatRoom).description];
                
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                }
                else{
                    //发送离开聊天室的通知
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:K_EXIT_ChAT_ROOM
                     object:nil
                     userInfo:@{
                                K_CHAT_ROMM_ID:jsonDic[K_CHAT_ROMM_ID],
                                K_CHAT_USER_ID:jsonDic[K_CHAT_USER_ID]
                                }];
                }
            }
                break;
                
            //MARK:15.聊天室发送消息/礼物/红包 sendChatRoomMsg
            case GCDSocketTCPCmdTypeSendChatRoomMsg:
            {
                didReadBlock = self.requestDic[@(MMRequestType_sendChatRoomMsg).description];
                
                if (didReadBlock) {
                    didReadBlock(error, jsonDic);
                    [self.requestDic removeObjectForKey:@(MMRequestType_sendChatRoomMsg).description];
                }
                else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:K_GET_MSG_ChAT_ROOM object:nil userInfo:jsonDic];
                    NSLog(@"收到聊天室其他用户发的消息,详见：%@",jsonDic);
                }
            }
                break;
                
            //MARK:n.退出登录 logout
            case GCDSocketTCPCmdTypeLogout:
            {
                didReadBlock = self.requestDic[@(MMRequestType_logout).description];
                didReadBlock(error, jsonDic);
            }
                break;
                
            default:
                NSLog(@"未知类型的cmd:%@",strCMD);
                break;
        }
    }
}
#pragma mark - Private
// 通知下线
- (void)alert:(NSDictionary *)dic
{
    AppDelegate *appDelegate =  [AppDelegate shareAppDelegate];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下线通知" message:dic[@"err"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        exit(1);//推出程序
    }];
    
    UIAlertAction *reloginAction = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self disconnectSocket];
        appDelegate.window.rootViewController = [LoginVC new];
    }];
    
    [alert addAction:exitAction];
    
    [alert addAction:reloginAction];
    
    [appDelegate.window.rootViewController  presentViewController:alert animated:YES completion:nil];
    
}
/** 停止播放并销毁 */
-(void)stopAndReleaseAudioPlayer{
    if (_avAudioPlayer) {
        [_avAudioPlayer stop];
        _avAudioPlayer = nil;
    }
    
    ZWWLog(@"音视频邀请声音播放对象已移除");
}
@end
