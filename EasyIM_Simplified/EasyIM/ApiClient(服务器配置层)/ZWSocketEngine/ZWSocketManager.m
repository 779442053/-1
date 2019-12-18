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

#import "ZWDataManager.h"
//Defines
#import "MMDefines.h"
#import "NSObject+MMAlert.h"
#import "YJProgressHUD.h"
@interface ZWSocketManager()<GCDAsyncSocketDelegate>

@property (nonatomic,strong)GCDAsyncSocket * socket;
@property(nonatomic ,strong)NSTimer  * pingTimer;///心跳定时器
@property(nonatomic ,strong)NSTimer  * reconnectTimer;///断线重连定时器
@property(nonatomic ,assign)int reconnectNum;///当前重连的连接次数
@property(nonatomic,strong)ZWSocketConfig * configM;
@property(nonatomic,assign)SGSocketConnectState connectState;

@property(nonatomic,copy)SocketConnectResponseBlock connectBlock;

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
        }
        if(![[ZWSocketManager shareInstance].socket connectToHost:configM.ip onPort:configM.port withTimeout:configM.timeout error:&error]){
            complation(error);
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
/**
 *  写入数据
 *
 *  @param dic 请求体
 */
+ (void)SendDataWithData:(NSMutableDictionary*)dic{
    ZWWLog(@"发送数据包字典 \n=%@",dic)
    NSInteger SocketrequestTag = ZWGCDSocketTCPCmdTypeEnum(dic[@"cmd"]);
//    ZWWLog(@"本次的请求===%ld \n 对应字符串 = %@",(long)SocketrequestTag,dic[@"cmd"])
    NSString *body = [NSString stringWithFormat:@"<JoyIM>%@</JoyIM>",dic.innerXML];
    //ZWWLog(@"请求包体=\n %@",body)
    NSData *bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    //封装包头
    NSUInteger size = bodyData.length;//数据包的长度
    PacketHeader head = {size, 0, 0};//包头结构体
    NSData *headData = [[NSData alloc] initWithBytes:&head length:4];//包头data
    NSMutableData *mData = [NSMutableData dataWithData:headData];
    [mData appendData:bodyData];//
    [[ZWSocketManager shareInstance].socket writeData:mData withTimeout:-1 tag:SocketrequestTag];
}
+ (void)SendMessageWithMessage:(MMMessage*)message complation:(SocketDidReadBlock)complation;{
    //消息,分为群聊,单聊,语音呼叫,视频呼叫
    NSDictionary *sliceDic = @{
       @"slice":@{
           @"type":message.slice.type,
           @"content":message.slice.content
       }
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
#pragma mark GCDAsyncSocketDelegate
/**
 *  连接成功
 *  连接成功之后,会走这个代理
 *  @param sock  socket
 *  @param host   host
 *  @param port   port
 */
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    ZWWLog(@"多次走这里原因:\n 1.断网 2.主动断开,再次尝试连接 \n 3.初次连接成功,在规定时间内没有发送心跳包.造成断开连接")
    [ZWMessage success:@"测试使用" title:@"socket连接成功!!"];
    [_socket readDataWithTimeout:-1 tag:0];
    _instance.connectState = SGSocketConnectState_ConnectSuccess;
    if(_reconnectTimer){//如果连接成功啦.就暂停定时器的操作
        [self stopReconnectTimer];
    }
    if (self.connectBlock) {//告诉引用着.连接成功啦
        self.connectBlock(nil);
    }
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
        ZWWLog(@"连接失败 - 错误为：%@",error);
         [ZWMessage error:@"连接失败!!" title:[NSString stringWithFormat:@"Socket连接错误-----%@",error]];
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
/**
 *  接受数据
 *    这里如果收到的是消息回执则将数据直接传给业务层做处理，其他回执这里直接处理
 *  @param sock  socket
 *  @param data  data
 *  @param tag   tag
 */
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    //在这里,处理收到的数据,将数据区分,block 出去   ==根据tag 处理相应的数据包
    //1.心跳数据,不作处理
    //2.查询数据,返回查询结果,推送数据,d发送通知
    //收到数据  到下次发送数据,30s 长度.如果没有主动调用发送数据,就开启定时器,
    //发送心跳包.告知服务器,前端一直处于live 状态
    ZWWLog(@"收到数据收到数据收到数据收到数据收到数据收到数据收到数据收到数据")
    ZWWLog(@"=====%@",data)
    [self dealWithData:data];
    [_socket readDataWithTimeout:-1 tag:tag];
}
-(void)dealWithData:(NSData *)data{
    NSData *bodyData = [data subdataWithRange:NSMakeRange(4, data.length-4)];
    NSString *responseMessage = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    ZWWLog(@"newMessage=====%@",responseMessage)
    if ([responseMessage containsString:@"<JoyIM>"] && [responseMessage containsString:@"</JoyIM>"]){
        NSMutableDictionary *jsonDic = [NSDictionary dictionaryWithXMLString:responseMessage].mutableCopy;
        NSString *strCMD = [NSString stringWithFormat:@"%@",jsonDic[@"cmd"]];
        ZWWLog(@"socket 返回数据 = \n %@",jsonDic)
        if ([jsonDic.allKeys containsObject:@"__name"]) {
            [jsonDic removeObjectForKey:@"__name"];
        }
        SocketDidReadBlock MessagedidReadBlock;
        NSInteger type = ZWGCDSocketTCPCmdTypeEnum(strCMD);
        switch (type) {
            case GCDSocketTCPCmdTypeHeartBeat:
                ZWWLog(@"/** heartBeat 心跳包 */")
                return;
            case GCDSocketTCPCmdTypeUpdateuserstate:
                ZWWLog(@"全局通知一个用户下线暂不用直接返回")
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_LINE object:jsonDic];
                return;
            case GCDSocketTCPCmdTypeFriendStatus:
                ZWWLog(@"好友上线通知")
                return;
            case GCDSocketTCPCmdTypeInviteFrd2Group:
                ZWWLog(@"邀请好友入群")
                break;
            case  GCDSocketTCPCmdTypeHasBulletin:
                ZWWLog(@"好友通知")
                [[NSNotificationCenter defaultCenter] postNotificationName:FriendChangeNotifion object:jsonDic];
                return;
            //MARK:视频呼叫返回状态(对方等待通知界面)
            //callUser  1v1音视频呼叫
            //CallGroup 1vM群组音视频呼叫
            case  GCDSocketTCPCmdTypeCallUser:
            {
                ZWWLog(@"视频呼叫返回状态")
            }
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

                }
            }
                return;
            case GCDSocketTCPCmdTypeLogin:
            {
                ZWWLog(@"登录,获取sectionid 开启心跳机制")
            if ([jsonDic[@"result"] isEqualToString:@"1"])
            {
                if ([jsonDic.allKeys containsObject:@"sessionID"]) {
                    [ZWUserModel currentUser].sessionID = jsonDic[@"sessionID"];
                    [ZWDataManager saveUserData];
                    ZWWLog(@"开始心跳连接")
                    [[ZWSocketManager shareInstance]startPingTimer];
                }
            }else{//1.2 处理在别的设备登入你的账号时
                [MMProgressHUD showError:jsonDic[@"err"]];
                }
            }
                break;
            //MARK:2.发送消息回调
            case GCDSocketTCPCmdTypeSendMsg:
            {//消息发送成功==改变消息展示状态//告诉前面,该消息状态改变
                 //MessagedidReadBlock(nil,jsonDic);
            }
                break;
            //MARK:3.读取消息 对方读取了我的消息
            case GCDSocketTCPCmdTypeFetchMsg:
            {
                //播放消息声音
                //MessagedidReadBlock(nil,jsonDic);
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
//                        didReadBlock = self.requestDic[@(MMRequestType_hangUp).description];
//                        if (didReadBlock) {
//                            didReadBlock(nil, jsonDic);
//                        }
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
//                didReadBlock = self.requestDic[@(MMRequestType_checkUserOnline).description];
//                if (didReadBlock) {
//                    didReadBlock(error, jsonDic);
//                }
            }
                break;
            //MARK:9.发群消息回调 groupMsg
            case GCDSocketTCPCmdTypeGroupMsg:
            {

            }
                break;
            //MARK:10.加好友回调 addFriend
            case GCDSocketTCPCmdTypeAddFriend:
            {
                ZWWLog(@"加好友回调 addFriend")
                if ([jsonDic.allKeys containsObject:@"result"]) {
                    if ([jsonDic[@"result"] intValue] == 1) {
                        [YJProgressHUD showSuccess:@"添加好友成功,等待对方确认"];
                    }else{
                        //添加好友失败
                        [YJProgressHUD showError:jsonDic[@"err"]];
                    }
                }
            }
                break;
            //MARK:11.解散群回调 deleteGroup
            case GCDSocketTCPCmdTypeDeleteGroup:
            {
                if (![jsonDic[@"fromID"] isEqualToString:[ZWUserModel currentUser].userId]) {
                    [self showAlertWithMessage:[NSString stringWithFormat:@"群主%@已将%@群解散", jsonDic[@"fromID"],jsonDic[@"groupID"]]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil userInfo:jsonDic];
                }
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
                ZWWLog(@"退出登录 logout")
                [[NSNotificationCenter defaultCenter] postNotificationName:appLoginOut object:nil];
            }
                break;
                
            default:
                NSLog(@"未知类型的cmd:%@",strCMD);
                break;
        }
    }
}

/**
 *  写入数据成功
 *    发送消息之后需要来这里判断消息是否发送成功,但是这里不弄那么复杂了。直接根据回执判断消息的发送情况
 *  @param sock  socket
 *  @param tag   tag
 */
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //，自己调用一下读取数据的方法, 发送数据成功后，接着_socket才会执行下面的方法,
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

#pragma  mark - 心跳定时器
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
    ZWWLog(@"定时发送心跳包,和服务器确认连接状态")
    //[ZWMessage message:@"定时发送心跳包,和服务器确认连接状态" title:@"Socket连接心跳发送"];
    NSMutableDictionary *heartParma = [[NSMutableDictionary alloc]init];
    heartParma[@"cmd"] = @"heartBeat";
    heartParma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    heartParma[@"type"] = @"req";
    heartParma[@"loginType"] = @"410";
    heartParma[@"deviceDesc"] = [UIDevice currentDevice].name;
    [ZWSocketManager  SendDataWithData:heartParma];
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
/** 停止播放并销毁 */
-(void)stopAndReleaseAudioPlayer{
    if (_avAudioPlayer) {
        [_avAudioPlayer stop];
        _avAudioPlayer = nil;
    }
    
    ZWWLog(@"音视频邀请声音播放对象已移除");
}
@end
