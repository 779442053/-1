//
//  ZWSocketManager.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWSocketManager.h"
#import "GCDAsyncSocket.h"
#import "XMLDictionary.h"
#import "AFNetworkReachabilityManager.h"
#import "ZWDataManager.h"
#import "ZWSaveTool.h"
#import "MMDateHelper.h"
#import "NSObject+MMAlert.h"
#import "YJProgressHUD.h"
#import "YHUtils.h"
#import "AppDelegate.h"
#import "LoginVC.h"
@interface ZWSocketManager()<GCDAsyncSocketDelegate>

@property (nonatomic,strong)GCDAsyncSocket * socket;
@property(nonatomic ,strong)NSTimer  * pingTimer;///心跳定时器
@property(nonatomic ,strong)NSTimer  * reconnectTimer;///断线重连定时器
@property(nonatomic ,assign)int reconnectNum;///当前重连的连接次数
@property(nonatomic,strong)ZWSocketConfig * configM;
@property(nonatomic,assign)SGSocketConnectState connectState;
@property(nonatomic,copy)SocketConnectResponseBlock connectBlock;
//消息发送成功回调
@property(nonatomic,copy)SocketDidReadBlock DidReadBlock;
/** 音视频邀请声音播放对象 */
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
@end
static ZWSocketManager * _instance = nil;
@implementation ZWSocketManager
typedef struct {
    uint16_t len;//有效负载长度,  2BYTE
    uint8_t  zip;//压缩 > 0 启用,1BYTE
    uint8_t  enc;//加密 > 0 启用,1BYTE
}PacketHeader;

#pragma mark - 业务方法
+ (SGSocketConnectState)SocketConnectState{
    if (!_instance) {
        return SGSocketConnectState_NotConnect;
    }else{
        return _instance.connectState;
    }
}
+ (void)ConnectSocketWithConfigM:(ZWSocketConfig*)configM complation:(SocketConnectResponseBlock)complation{
    [ZWSocketManager shareInstance].configM = configM;
    [ZWSocketManager shareInstance].connectBlock = complation;
    if ([ZWSocketManager shareInstance].connectState == SGSocketConnectState_NotConnect ||
        [ZWSocketManager shareInstance].connectState == SGSocketConnectState_ConnectFail) {
        _instance.connectState = SGSocketConnectState_Connecting;
        NSError *error;
        if (![ZWSocketManager shareInstance].socket) {
            [ZWSocketManager shareInstance].socket = [[GCDAsyncSocket alloc] initWithDelegate:_instance delegateQueue:dispatch_get_main_queue()];
            ZWWLog(@"第一次连接")
        }
        if(![[ZWSocketManager shareInstance].socket connectToHost:configM.ip onPort:configM.port withTimeout:configM.timeout error:&error]){
            complation(error);
            ZWWLog(@"第二次次连接")
        }
    }
}
/**断开连接*/
+ (void)DisConnectSocket{
    ZWWLog(@"主动断开连接,将定时器清空")
    if ([ZWSocketManager shareInstance].connectState == SGSocketConnectState_Connecting ||
        [ZWSocketManager shareInstance].connectState == SGSocketConnectState_ConnectSuccess ||
        [ZWSocketManager shareInstance].connectState == SGSocketConnectState_ReConnecting) {
        [[ZWSocketManager shareInstance].socket disconnect];
        [ZWSocketManager shareInstance].connectState = SGSocketConnectState_NotConnect;
        ///关闭定时器
        [[ZWSocketManager shareInstance] stopPingTimer];
        
    }
}

+ (void)SendMessageWithMessage:(MMMessage*)message complation:(SocketDidReadBlock)complation;{
    //消息,分为群聊,单聊,语音呼叫,视频呼叫 文件,图片,联系人,位置
    [ZWSocketManager shareInstance].DidReadBlock = complation;
    //消息类型不一样,主要是slice 不一样.所以,只需要修改 slice  就可以啦
    NSMutableDictionary * presliceDic = [[NSMutableDictionary alloc]init];
    if (message.messageType == MMMessageType_Text) {//文字
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"content"] = message.slice.content;
    }else if (message.messageType == MMMessageType_Voice){//短录音
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"content"] = message.slice.content;
        presliceDic[@"duration"] = [NSString stringWithFormat:@"%ld",message.slice.duration];
    }else if (message.messageType == MMMessageType_Image){//图片
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"content"] = message.slice.content;
        presliceDic[@"width"] = [NSString stringWithFormat:@"%f",message.slice.width];
        presliceDic[@"height"] = [NSString stringWithFormat:@"%f",message.slice.height];
    }else if (message.messageType == MMMessageType_Video){//短视频
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"content"] = message.slice.content;
    }else if (message.messageType == MMMessageType_Doc){//文件
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"content"] = message.slice.content;
        presliceDic[@"length"] = message.slice.length;
    }else if (message.messageType == MMMessageType_linkman){//联系人
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"userID"] = message.slice.userID;
        presliceDic[@"userName"] = message.slice.userName;
        presliceDic[@"nickName"] = message.slice.nickName;
        presliceDic[@"photo"] = message.slice.photo;
    }else if (message.messageType == MMMessageType_Location){//地图
        presliceDic[@"type"] = message.slice.type;
        presliceDic[@"jingDu"] = [NSString stringWithFormat:@"%f",message.slice.jingDu];
        presliceDic[@"weiDu"] = [NSString stringWithFormat:@"%f",message.slice.weiDu];;
        presliceDic[@"address"] = message.slice.address;
    }
    NSDictionary *sliceDic = @{
       @"slice":presliceDic
    };
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    if ([message.type isEqualToString:@"chat"]) {//单聊
        parma[@"type"] = message.type;
        parma[@"cmd"] = message.cmd;
        parma[@"sessionID"] = message.sessionID;
        parma[@"toID"] = message.toID;
        parma[@"toUserName"] = message.toUserName;
        parma[@"msgID"] = message.msgID;
        parma[@"msg"] = sliceDic;
    }else if ([message.type isEqualToString:@"groupchat"]){//群聊
        parma[@"type"] = message.type;
        parma[@"cmd"] = message.cmd;
        parma[@"sessionID"] = message.sessionID;
        parma[@"groupID"] = message.toID;
        parma[@"msgID"] = message.msgID;
        parma[@"msg"] = sliceDic;
    }else{
        [MMProgressHUD showHUD:@"未知消息类型!!!"];
    }
    ZWWLog(@"发送消息发送消息发送消息发送消息=%@",parma)
    NSInteger SocketrequestTag = ZWGCDSocketTCPCmdTypeEnum(parma[@"cmd"]);
     NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",parma.innerXML];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger size = bodyData.length;//数据包的长度
    PacketHeader head = {size, 0, 0};//包头结构体
    NSData *headData = [[NSData alloc] initWithBytes:&head length:4];//包头data
    NSMutableData *mData = [NSMutableData dataWithData:headData];
    [mData appendData:bodyData];//
    [[ZWSocketManager shareInstance].socket writeData:mData withTimeout:-1 tag:SocketrequestTag];
}
+ (void)SendDataWithData:(NSMutableDictionary*)parma complation:(SocketDidReadBlock)complation{
    ZWWLog(@"发送socket数据Dict=%@",parma)
    [ZWSocketManager shareInstance].DidReadBlock = complation;
    NSInteger SocketrequestTag = ZWGCDSocketTCPCmdTypeEnum(parma[@"cmd"]);
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",parma.innerXML];
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger size = bodyData.length;//数据包的长度
    PacketHeader head = {size, 0, 0};//包头结构体
    NSData *headData = [[NSData alloc] initWithBytes:&head length:4];
    NSMutableData *mData = [NSMutableData dataWithData:headData];
    [mData appendData:bodyData];
    [[ZWSocketManager shareInstance].socket writeData:mData withTimeout:-1 tag:SocketrequestTag];
}
//连接成功之后,需要做的事情:
/**
 1. 登录IMTCP  服务,获取 secssionid
 2.拿到sessionid 开始心跳
 =====> 和tcp 建立稳定连接
 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    ZWWLog(@"多次走这里原因:\n 1.断网 \n2.主动断开,再次尝试连接 \n 3.初次连接成功,在规定时间内没有发送心跳包.造成断开连接")
    [ZWMessage success:@"测试使用" title:@"socket连接成功!!"];
    [_socket readDataWithTimeout:-1 tag:0];
    _instance.connectState = SGSocketConnectState_ConnectSuccess;
    if(_reconnectTimer){//如果连接成功啦.就暂停定时器的操作.同时,开始心跳链接
        [self stopReconnectTimer];
    }
    //如果用户登录过,并且有sessionid ,那么,就是因为程序长时间不执行,造成代码死掉的
    BOOL islogin = [ZWSaveTool BoolForKey:@"IMislogin"];
    if ([ZWUserModel currentUser].sessionID && islogin) {
        ZWWLog(@"说明我登录过,\n并且拿到了sessionnid,再次进行登录,不修改状态登录IM")
        [self loginIMServer];//成功之后,会自动开启心跳定时器,进行稳定连接
    }else{
        ZWWLog(@"第一次进来,\n按照正常流程走就可以啦")
    }
    if (self.connectBlock) {//告诉引用着.连接成功啦
        self.connectBlock(nil);
    }
}
-(void)loginIMServer{
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"type"] = @"req";
    parma[@"cmd"] = @"login";
    parma[@"xns"] = @"xns_user";
    parma[@"loginType"] = @"410";
    parma[@"deviceDesc"] = [UIDevice currentDevice].name;
    NSString *userName = [ZWUserModel currentUser].userName;
    NSString *mobil = [ZWUserModel currentUser].mobile;
    if (!ZWWOBJECT_IS_EMPYT(userName)) {
        parma[@"userName"] = userName;
    }else if (!ZWWOBJECT_IS_EMPYT(mobil)){
        parma[@"mobile"] = mobil;
    }else{
        [YJProgressHUD showError:@"缺少用户昵称,名字,账号"];
    }
    parma[@"userPsw"] = [ZWUserModel currentUser].userPsw;
    parma[@"domain"] = @"9000";
    parma[@"timeStamp"] = [MMDateHelper getNowTime];
    parma[@"oem"] = @"";
    parma[@"enc"] = @"0";
    parma[@"zip"] = @"0";
    parma[@"netstatus"] = @"1";
    ZWWLog(@"本地不修改登录状态登录IM= \n %@",parma)
    [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
        if (!error) {
            ZWWLog(@"断先重连成功")
        }else{
            ZWWLog(@"断先重连失败")
        }
    }];
    
}
/**
 *  连接失败回调
 *    这里判断错误类型，选择重新连接或者提示用户
 *  @param sock  socket
 *  @param error   error
 */
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)error{
   //  和服务器z断开连接
    if (error) {
         [ZWMessage error:@"连接失败!!" title:[NSString stringWithFormat:@"Socket连接错误-----\n%@",error]];
        _instance.connectState = SGSocketConnectState_ConnectFail;
        ///连接失败回调
        if (self.connectBlock) {
            self.connectBlock(error);
        }
        ///开启重连
        [self startReconnectTimer];
    }else{
        ///主动断开连接
         _instance.connectState = SGSocketConnectState_NotConnect;
    }
    ///心跳删除
    if (_pingTimer) {
        [self stopPingTimer];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [self dealWithData:data];
    [_socket readDataWithTimeout:-1 tag:tag];
}
-(void)dealWithData:(NSData *)data{
    NSData *bodyData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
    NSString *responseMessage = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    //ZWWLog(@"===\n %@",responseMessage)
    if ([responseMessage containsString:@"<JoyIM>"] && [responseMessage containsString:@"</JoyIM>"]){
        NSMutableDictionary *jsonDic = [NSDictionary dictionaryWithXMLString:responseMessage].mutableCopy;
        NSString *strCMD = [NSString stringWithFormat:@"%@",jsonDic[@"cmd"]];
        if ([jsonDic.allKeys containsObject:@"__name"]) {
            [jsonDic removeObjectForKey:@"__name"];
        }
        ZWWLog(@"socket 返回数据 = \n %@",jsonDic)
        NSString *errString;
        if ([[jsonDic allKeys] containsObject:@"err"] && [jsonDic[@"err"] isKindOfClass:[NSString class]]) {
            errString = jsonDic[@"err"];
        }else{
            errString = @"inviteFrd2Group";
        }
        NSError *error = [NSError errorWithDomain:NSURLErrorDomain
                                             code:[jsonDic.allKeys containsObject:@"result"]? [jsonDic[@"result"] integerValue]:[jsonDic.allKeys containsObject:@"ret"]?[jsonDic[@"ret"] intValue]:-1
                                         userInfo:@{
                                                    NSLocalizedDescriptionKey: errString.checkTextEmpty?errString :  ([jsonDic.allKeys containsObject:@"desc"]?jsonDic[@"desc"]:@"未知错误")
                                                    }];
        NSInteger type = ZWGCDSocketTCPCmdTypeEnum(strCMD);
        switch (type) {
            case GCDSocketTCPCmdTypeHeartBeat:
                break;
            case GCDSocketTCPCmdTypeupdateUserStatus:
                ZWWLog(@"全局通知一个用户下线暂不用直接返回.登录或者修改用户在线状态")
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_LINE object:jsonDic];
                break;
            case GCDSocketTCPCmdTypeFriendStatus:
            {
                ZWWLog(@"好友上线通知=%@",jsonDic)
                [YHUtils playVoiceForMessage];
                [ZWMessage success:@"好友上线了" title:@"温馨提示"];
            }
                break;
            case GCDSocketTCPCmdTypeInviteFrd2Group:
                ZWWLog(@"邀请好友入群=%@",jsonDic)
                if ([jsonDic[@"ret"] intValue] == 1 || ![jsonDic.allKeys containsObject:@"ret"] ) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil,jsonDic);
                    }
                }else{
                   if (self.DidReadBlock) {
                        self.DidReadBlock(error,nil);
                    }
                }
                break;
            case GCDSocketTCPCmdTypenewMember2Group:
            ZWWLog(@"邀请好友入群,其他群内成员受到消息=%@",jsonDic)
            if ([jsonDic[@"ret"] isEqualToString:@"1"]) {
                NSString *groupName = jsonDic[@"groupName"];
                NSString *title = [NSString stringWithFormat:@"%@ 消息提醒",groupName];
                [ZWMessage success:@"有新成员加入了群聊,赶快认识一下吧~~" title:title];
            }else{
               
            }
            break;
            case  GCDSocketTCPCmdTypeHasBulletin:
                ZWWLog(@"好友通知\n 好友通知\n 好友通知\n 好友通知\n 好友通知\n 好友通知\n == %@",jsonDic)
                //通知类型,有很多种
                [[NSNotificationCenter defaultCenter] postNotificationName:FriendChangeNotifion object:jsonDic];
                return;
            case  GCDSocketTCPCmdTypeCallUser:
            {ZWWLog(@"音视频呼叫对方,状态放回=%@",jsonDic)
                /**在这里,在block 出去之后,进行界面修改,声音提醒*/
                NSString *fUId = [jsonDic.allKeys containsObject:@"fromId"]?jsonDic[@"fromId"]:jsonDic[@"fromId"];
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if (![fUId isEqualToString:userID]){
                    ZWWLog(@"别人呼叫我")
                    [YHUtils playVoiceForAudioAndVideo:^(AVAudioPlayer *_Nullable _avaudio) {
                        _avAudioPlayer = _avaudio;
                    }];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Request object:nil userInfo:jsonDic];
                }else{
            ZWWLog(@"我正在呼叫别人.这个时候,才是我发起的请求,需要告知我d发送请求的状态")
                    if ([jsonDic[@"result"] isEqualToString:@"1"]){
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil,jsonDic);
                          }
                    }else{
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error,nil);
                        }
                    }
                }
            }
               break;
            case  GCDSocketTCPCmdTypeCallGroup://群呼叫
            {
                //接收到对方的视频请求
                NSString *fUId = [jsonDic.allKeys containsObject:@"frmUid"]?jsonDic[@"frmUid"]:jsonDic[@"fromId"];
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if (![fUId isEqualToString:userID]) {
                    //循环播放提示音，在接受或拒绝或超时时关闭播放
                    [YHUtils playVoiceForAudioAndVideo:^(AVAudioPlayer *_Nullable _avaudio) {
                        _avAudioPlayer = _avaudio;
                    }];
                    ZWWLog(@"群里面,有人呼叫我 = %@",jsonDic)
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Request object:nil userInfo:jsonDic];
                }else{
                    ZWWLog(@"发视频邀请的Response=%@",jsonDic)
                    if ([jsonDic[@"result"] isEqualToString:@"1"]){
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil,jsonDic);
                          }
                    }else{
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error,nil);
                        }
                    }
                }
            }
                return;
            case GCDSocketTCPCmdTypeLogin:
            {
            ZWWLog(@"登录,获取sectionid 开启心跳机制 = %@",jsonDic)
            if ([jsonDic[@"result"] isEqualToString:@"1"])
            {
                if ([jsonDic.allKeys containsObject:@"sessionID"]) {
                    [ZWUserModel currentUser].sessionID = jsonDic[@"sessionID"];
                    [ZWUserModel currentUser].nickName = jsonDic[@"nickName"];
                    [ZWUserModel currentUser].photoUrl = jsonDic[@"photoUrl"];
                    [ZWUserModel currentUser].userSig = jsonDic[@"userSig"];
                    [ZWDataManager saveUserData];
                    if (self.DidReadBlock) {
                        ZWWLog(@"IM登陆成功")
                        self.DidReadBlock(nil,jsonDic);
                    }
                    [[ZWSocketManager shareInstance]startPingTimer];
                }
            }else{
                ZWWLog(@"1.2 处理在别的设备登入你的账号时")
                [ZWMessage error:jsonDic[@"err"] title:@"系统错误"];
                if ([jsonDic[@"err"] isEqualToString:@"该帐号在另外地点登录了"]) {
                    [ZWSocketManager DisConnectSocket];
                    [self alert:jsonDic];
                }
                if (self.DidReadBlock) {
                    self.DidReadBlock(error,nil);
                }
                }
            }
                break;
            //MARK:2.发送消息回调
            case GCDSocketTCPCmdTypeSendMsg:
            {
                if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil,jsonDic);
                    }
                }else{
                   if (self.DidReadBlock) {
                        self.DidReadBlock(error,nil);
                    }
                }
            }
                break;
            //我收到消息==张威威
            case GCDSocketTCPCmdTypeFetchMsg:
            {
                [YHUtils playVoiceForMessage];
                [[MMClient  sharedClient] addHandleChatMessage:jsonDic];
            }
                break;
            //MARK:4.挂断
            case GCDSocketTCPCmdTypeHangUpCall:
            {ZWWLog(@"究竟是谁挂断谁的操作操作===%@",jsonDic)
                [self stopAndReleaseAudioPlayer];
                [YHUtils closeVoiceAudioAndVideo];
                //如果对方挂断则通知对方已挂断
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if (![jsonDic[@"643444"] isEqualToString:userID]) {
                    ZWWLog(@"别人挂断我")
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
                }else{
                    ZWWLog(@"我主动挂断别人")
                    if (![jsonDic[@"webrtcId"] isEqualToString:userID]) {
                        ZWWLog(@"我主动挂断正在进行的通话")
                        [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
                    }else{
                        ZWWLog(@"我主动挂断正在呼叫中的音视频邀请")
                        if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                            if (self.DidReadBlock) {
                                self.DidReadBlock(nil,jsonDic);
                            }
                        }else{
                           if (self.DidReadBlock) {
                                self.DidReadBlock(error,nil);
                            }
                        }
                    }
                    if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil,jsonDic);
                        }
                    }else{
                       if (self.DidReadBlock) {
                            self.DidReadBlock(error,nil);
                        }
                    }
                }
            }
                break;
            case GCDSocketTCPCmdTypeAcceptCall:
            {
                ZWWLog(@"私聊,别人接受我,或者我接受别人的音视频邀请")
                [self stopAndReleaseAudioPlayer];
                NSString *fUId = [jsonDic.allKeys containsObject:@"frmUid"]?jsonDic[@"frmUid"]:jsonDic[@"fromId"];
                 NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if (![fUId isEqualToString:userID]) {
                    //振动手机提示
                    [YHUtils vibratingCellphone];
                    ZWWLog(@"对方接受邀请,通知发请求者改变此时状态")
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Accept object:nil userInfo:jsonDic];
                }else{
                    ZWWLog(@"我接受别人的私聊音视频邀请")
                    if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                           if (self.DidReadBlock) {
                               self.DidReadBlock(nil,jsonDic);
                           }
                       }else{
                          if (self.DidReadBlock) {
                               self.DidReadBlock(error,nil);
                           }
                       }
                }
            }
                break;
            case GCDSocketTCPCmdTypeAcceptGroupCall:
            {
                [self stopAndReleaseAudioPlayer];
                NSString *fUId = [jsonDic.allKeys containsObject:@"frmUid"]?jsonDic[@"frmUid"]:jsonDic[@"fromId"];
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if (![fUId isEqualToString:userID]) {
                    //振动手机提示
                    [YHUtils vibratingCellphone];
                    //对方接受邀请,通知发请求者改变此时状态
                    [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Accept object:nil userInfo:jsonDic];
                }else{
                   if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                       if (self.DidReadBlock) {
                           self.DidReadBlock(nil,jsonDic);
                       }
                   }else{
                      if (self.DidReadBlock) {
                           self.DidReadBlock(error,nil);
                       }
                   }
                }
            }
                break;
            case GCDSocketTCPCmdTypeRejectCall:
            {
                ZWWLog(@"拒绝别人的单聊音视频邀请 = %@",jsonDic)
                [self stopAndReleaseAudioPlayer];
                [YHUtils closeVoiceAudioAndVideo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
                if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil,jsonDic);
                    }
                }else{
                   if (self.DidReadBlock) {
                        self.DidReadBlock(error,nil);
                    }
                }
                
            }
             break;
            case GCDSocketTCPCmdTypeRejectGroupCall:
            {
                ZWWLog(@"拒绝群里面的音视频邀请=%@",jsonDic)
                [self stopAndReleaseAudioPlayer];
                [YHUtils closeVoiceAudioAndVideo];
                [[NSNotificationCenter defaultCenter] postNotificationName:CALL_Vedio_Refuse object:nil userInfo:jsonDic];
                if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil,jsonDic);
                    }
                }else{
                   if (self.DidReadBlock) {
                        self.DidReadBlock(error,nil);
                    }
                }
            }
                break;
            //MARK:7.读取群消息 fetchGroupMsg */
            case GCDSocketTCPCmdTypeFetchGroupMsg:
            {
                //群免打扰设置处理
                NSString *strGroupId = [NSString stringWithFormat:@"%@",jsonDic[@"list"][@"group"][@"groupID"]];
                NSString *strUserId = [[NSUserDefaults standardUserDefaults] stringForKey:strGroupId];
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if (strUserId.checkTextEmpty && [ZWUserModel currentUser] && [userID isEqualToString:strUserId]) {
               ZWWLog(@"用户[%@]已开启对群[%@]消息免打扰",strUserId,strGroupId);
                }
                else{
                    //播放消息声音
                    if (jsonDic[@"xns"] && [jsonDic[@"xns"] isEqualToString:@"xns_group"]) {
                        NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                        NSString *fromID = [NSString stringWithFormat:@"%@",jsonDic[@"list"][@"group"][@"fromID"]];
                        ZWWLog(@"群里发过来的fromID =%@  myuserid = %@",fromID,userID)
                        if ([fromID isEqualToString:userID]) {
                            [YHUtils ShackTheIphon];
                            ZWWLog(@"自己发到群里的消息")
                        }else{
                            [YHUtils playVoiceForMessage];
                            ZWWLog(@"别人w向群里d发的消息")
                        }
                    }else{
                        [YHUtils playVoiceForMessage];
                    }
                }
                [[MMClient  sharedClient] addHandleGroupMessage:jsonDic];
            }
                break;
            case GCDSocketTCPCmdTypeCheckUserOnline:
            {

            }
                break;
            case GCDSocketTCPCmdTypedelFriend:
            {
                ZWWLog(@"删除好友 = %@",jsonDic)
                [[NSNotificationCenter defaultCenter] postNotificationName:delfriend object:jsonDic];
                if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil,jsonDic);
                    }
                }else{
                   if (self.DidReadBlock) {
                        self.DidReadBlock(error,nil);
                    }
                }
                //删除本地聊天记录,删除联系人里面的数据源
            }
                break;
            case GCDSocketTCPCmdTypeGroupMsg:
            {
                if ([jsonDic[@"result"] isEqualToString:@"1"]) {
                    if (self.DidReadBlock) {
                        ZWWLog(@"群发发送成功 1")
                        self.DidReadBlock(nil,jsonDic);
                    }
                }else{
                   if (self.DidReadBlock) {
                        self.DidReadBlock(error,nil);
                    }
                }
            }
                break;
            //MARK:10.加好友回调 addFriend
            case GCDSocketTCPCmdTypeAddFriend:
            {
                ZWWLog(@"加好友回调 addFriend")
                if ([jsonDic.allKeys containsObject:@"result"]) {
                    if ([jsonDic[@"result"] intValue] == 1) {
                        [YJProgressHUD showSuccess:@"添加好友成功,等待对方确认"];
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil, jsonDic);
                        }
                    }else{
                        //添加好友失败
                        [YJProgressHUD showError:jsonDic[@"err"]];
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error, jsonDic);
                        }
                    }
                }
            }
                break;
            //MARK:11.解散群回调 deleteGroup
            case GCDSocketTCPCmdTypeDeleteGroup:
            {
                NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                if ([jsonDic[@"fromID"] isEqualToString:userID]) {
                    [self showAlertWithMessage:[NSString stringWithFormat:@"群主%@已将%@群解散", jsonDic[@"fromID"],jsonDic[@"groupID"]]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil userInfo:jsonDic];
                }
            }
                break;
                /**踢人出群回调*/
            case GCDSocketTCPCmdTypekickGroupMember:
            {//受到该消息,z说明群主提出了某一个群成员
                if ([jsonDic[@"result"] intValue] == 1) {
                    NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                    if ([jsonDic[@"memberID"] isEqualToString:userID]){
                        //.说明我被踢出群了
                        [ZWMessage message:@"你被群主踢出了群聊" title:@"群消息提醒:"];
                    }else{
                        //受到别人退出群的系统消息
                        [YHUtils playVoiceForMessage];
                        [[MMClient  sharedClient] addHandleGroupMessage:jsonDic];
                    }
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, jsonDic);
                    }
                }
            }
                break;
            //MARK:12.退出群回调 exitGroup需要封装成系统消息,进行界面提示
                //当别人退出群的时候,主动接受该消息
            case GCDSocketTCPCmdTypeExitGroup:
            {
                if ([jsonDic[@"result"] intValue] == 1) {
                    //自己退出,需要做界面提醒
                    NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
                    NSString *fromID = [NSString stringWithFormat:@"%@",jsonDic[@"fromID"]];
                    if (![fromID isEqualToString:userID]) {
                        NSString *fromNick = jsonDic[@"fromNick"];
                        NSString *fromName = jsonDic[@"fromName"];
                        NSString *name = fromNick.length ? fromNick : fromName;
                        [self showAlertWithMessage:[NSString stringWithFormat:@"%@已退群出%@群",name,jsonDic[@"groupName"]]];
                    }else{
                        ZWWLog(@"自己被提出群,告诉界面,做数据处理")
                        [[NSNotificationCenter defaultCenter] postNotificationName:deletegroup object:jsonDic];
                    }
                    //自己退出群聊
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, jsonDic);
                    }
                }
            }
                break;
                
            //MARK:13.加入聊天室 joinChatRoom
            case GCDSocketTCPCmdTypeJoinChatRoom:
            {

            }
                break;
                
            //MARK:14.离开聊天室 exitChatRoom
            case GCDSocketTCPCmdTypeExitChatRoom:
            {

            }
                break;
                
            //MARK:15.聊天室发送消息/礼物/红包 sendChatRoomMsg
            case GCDSocketTCPCmdTypeSendChatRoomMsg:
            {

            }
                break;
                
            //MARK:n.退出登录 logout
            case GCDSocketTCPCmdTypeLogout:
            {
                ZWWLog(@"退出登录 logout  可以使用block  形式")//
                //只有在使用一对多的情况下使用通知
                [[NSNotificationCenter defaultCenter] postNotificationName:appLoginOut object:nil];
                if ([jsonDic[@"result"] intValue] == 1) {
                    if (self.DidReadBlock) {
                        [ZWSocketManager  DisConnectSocket];//断开连接
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        [ZWSocketManager  DisConnectSocket];//断开连接
                        self.DidReadBlock(error, nil);
                    }
                }
            }
                break;
            case GCDSocketTCPCmdTyperevokeMsg:
            {
                ZWWLog(@"撤回消息成功 = %@",jsonDic)
                if ([jsonDic[@"result"] intValue] == 1) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, nil);
                    }
                }
            }
                break;
            case GCDSocketTCPCmdTypeacceptJoinGroup:
            {
                ZWWLog(@"群主同意别人加入本群,=%@",jsonDic)
                if ([jsonDic[@"result"] intValue] == 1) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, nil);
                    }
                }
            }
                break;
            case GCDSocketTCPCmdTypeagreeJoinGroup:
            {
                ZWWLog(@"群主同意别人加入本群,无论是别人,还是自己,都需要接受这个群消息=%@",jsonDic)
                if ([jsonDic[@"result"] intValue] == 1) {
                    if ([jsonDic[@"ApplyID"] isEqualToString:[ZWUserModel currentUser].sessionID]) {
                        //群主同意我加入该群
                        NSString *gropName = jsonDic[@"name"];
                        NSString *message = [NSString stringWithFormat:@"群主已同意您加入:%@ 群",gropName];
                        [ZWMessage success:message title:@"群消息:"];
                        [YHUtils playVoiceForMessage];
                        [[MMClient  sharedClient] addHandleGroupMessage:jsonDic];
                    }
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, jsonDic);
                    }
                }
                
            }
                break;
                case GCDSocketTCPCmdTyperejectJoinGroup:
            {//群主主动发送拒绝加入群的消息
                if ([jsonDic[@"result"] intValue] == 1) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, jsonDic);
                    }
                }
            }
              break;
            case GCDSocketTCPCmdTypejoinGroup:
            {
                if ([jsonDic[@"result"] intValue] == 1) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    [ZWMessage error:jsonDic[@"err"] title:@"申请失败!"];
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, jsonDic);
                    }
                }
            }
              break;
                case GCDSocketTCPCmdTyperejectaddGroup:
            {//创建群
                if ([jsonDic[@"result"] intValue] == 1) {
                    if (self.DidReadBlock) {
                        self.DidReadBlock(nil, jsonDic);
                    }
                }else{
                    if (self.DidReadBlock) {
                        self.DidReadBlock(error, jsonDic);
                    }
                }
            }
              break;
                case GCDSocketTCPCmdTypeacceptFriend:
                {//接受好友的请求
                    if ([jsonDic[@"result"] intValue] == 1) {
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil, jsonDic);
                        }
                    }else{
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error, jsonDic);
                        }
                    }
                }
                  break;
                case GCDSocketTCPCmdTyperejectFriend:
                {//接受好友的请求
                    if ([jsonDic[@"result"] intValue] == 1) {
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil, jsonDic);
                        }
                    }else{
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error, jsonDic);
                        }
                    }
                }
                  break;//
                case GCDSocketTCPCmdTypeignoreBulletin:
                {//忽略通知
                    if ([jsonDic[@"result"] intValue] == 1) {
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil, jsonDic);
                        }
                    }else{
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error, jsonDic);
                        }
                    }
                }
                  break;
                case GCDSocketTCPCmdTypecallHeartbeat:
                {  ZWWLog(@"呼叫新天发送返回数据=%@",jsonDic)
                    if ([jsonDic[@"result"] intValue] == 1) {
                        if (self.DidReadBlock) {
                            self.DidReadBlock(nil, jsonDic);
                        }
                    }else{
                        if (self.DidReadBlock) {
                            self.DidReadBlock(error, jsonDic);
                        }
                    }
                }
                  break;
                case GCDSocketTCPCmdTypefetchBulletin:
                {  ZWWLog(@"删除好友等相关等操作之后,\n被删除者接到的y通知=%@",jsonDic)
                    
                }
                  break;
            default:
                NSLog(@"未知类型的cmd:%@",strCMD);
                break;
        }
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    [_socket readDataWithTimeout:-1 tag:tag];
}

#pragma  mark - 对象单例初始化方法
+ (instancetype)shareInstance{
    if(_instance){///之所以多次一举是觉得每次都调用allocWithZone方法会浪费时间
        return _instance;
    }else{
        return  [[self alloc]init];
    }
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
    ///初始化管理对象的时候即初始化socket对象，这样可以保证永远只有一个管理对象和socket对象
            ///!注意这里delegate给的是_instance实例对象，不能是self
            _instance.socket = [[GCDAsyncSocket alloc] initWithDelegate:_instance delegateQueue:dispatch_get_main_queue()];
            _instance.connectState = SGSocketConnectState_NotConnect;
        }
    });
    return _instance;
}
- (void)startPingTimer{
    if (_instance) {
        _instance.pingTimer = [NSTimer scheduledTimerWithTimeInterval:_instance.configM.pingTimeInterval target:self selector:@selector(pingTimerAction) userInfo:nil repeats:true];
        /** 防止强引用 */
        [[NSRunLoop currentRunLoop] addTimer:_instance.pingTimer forMode:NSRunLoopCommonModes];
        [_instance.pingTimer fire];
    }
}
- (void)stopPingTimer{
    [_pingTimer invalidate];
    _pingTimer = nil;
}
- (void)pingTimerAction{
    NSMutableDictionary *heartParma = [[NSMutableDictionary alloc]init];
    heartParma[@"cmd"] = @"heartBeat";
    heartParma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    heartParma[@"type"] = @"req";
    heartParma[@"loginType"] = @"410";
    heartParma[@"deviceDesc"] = [UIDevice currentDevice].name;
    [ZWSocketManager  SendDataWithData:heartParma complation:^(NSError * _Nullable error, id  _Nullable data) {
        if (!error) {
            ZWWLog(@"心跳包成功")
        }else{
            ZWWLog(@"心跳包失败")
        }
    }];
}
#pragma mark - socket重连
/**
 开启定时器发送重连
 */
- (void)startReconnectTimer{
    if(!_reconnectTimer){
        _reconnectNum = 0;
        _reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:_instance.configM.reconnectTimeInterval target:self selector:@selector(reconnectTimerAction) userInfo:nil repeats:true];
        /** 防止强引用 */
        [[NSRunLoop currentRunLoop] addTimer:_reconnectTimer forMode:NSRunLoopCommonModes];
        [_instance.pingTimer fire];
    }else{
        ///
        [ZWMessage error:@"测试使用" title:@"重连次数超过了限制，关闭重连定时器"];
        if(_reconnectNum > _configM.reconnectTime){
            [self stopReconnectTimer];
        }
    }
}

- (void)reconnectTimerAction{
    _reconnectNum ++;
    [ZWSocketManager ConnectSocketWithConfigM:_configM complation:nil];
}

- (void)stopReconnectTimer{
    [_reconnectTimer invalidate];
    _reconnectTimer = nil;
    _reconnectNum = 0;
}
// 通知下线
- (void)alert:(NSDictionary *)dic
{
    AppDelegate *appDelegate =  [AppDelegate shareAppDelegate];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"下线通知" message:dic[@"err"] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        exit(1);//推出程序
    }];
    
    UIAlertAction *reloginAction = [UIAlertAction actionWithTitle:@"重新登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [ZWSaveTool setBool:NO forKey:@"IMislogin"];
        [ZWDataManager readUserData];
        LoginVC *VC = [[LoginVC alloc] init];
        BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:VC];
        appDelegate.window.rootViewController = nav;
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
    //ZWWLog(@"音视频邀请声音播放对象已移除");
}
- (void)startMonitoringNetwork
{
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    __weak __typeof(&*self) weakSelf = self;
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                if (weakSelf.connectState != -1) {
                    [ZWSocketManager DisConnectSocket];//没有网,就断开连接
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
            default:
                break;
        }
    }];
}
@end
