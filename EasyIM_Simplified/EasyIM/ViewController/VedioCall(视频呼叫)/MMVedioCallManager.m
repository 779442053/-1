//
//  MMVedioCallManager.m
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMVedioCallManager.h"
#import "ZWCallViewModel.h"
#import "MMVedioCallEnum.h"
//系统
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

//ViewController
#import "MM1v1AudioViewController.h"
#import "MM1v1VideoViewController.h"

static MMVedioCallManager *vedioCallManager = nil;
@interface MMVedioCallManager ()
@property (strong, nonatomic) MMCallSessionModel *currenSession;
@property (strong, nonatomic) MM1v1CallViewController *currenViewCtr;
@property (strong, nonatomic) NSTimer *timeoutTimer;
@property (assign, nonatomic) BOOL isEnter;
@property (assign, nonatomic) BOOL isCalling;
@property(nonatomic,strong)ZWCallViewModel *ViewModel;
@end

@implementation MMVedioCallManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initManager];
    }
    return self;
}
//单例--->在Appdelegate中调用 并调用init初始化
+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vedioCallManager = [[MMVedioCallManager alloc] init];
    });
    return vedioCallManager;
}

- (void)dealloc
{
    ZWWLog(@"我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......我销毁了......");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_Vedio1V1 object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_Vedio1VM object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_Vedio_Accept object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_Vedio_Request object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CALL_Vedio_Refuse object:nil];

}
#pragma mark - Private
- (void)initManager
{
    //当前Model,当前VC初始化
    _currenSession = nil;
    _currenViewCtr = nil;
    _isEnter = NO;

    //监听实时视频消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMake1v1Call:) name:CALL_Vedio1V1 object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMake1vMCall:) name:CALL_Vedio1VM object:nil];
    //别人呼叫我的   一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestCall:) name:CALL_Vedio_Request object:nil];
    //别人接受我的呼叫的一个通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAcceptCall:) name:CALL_Vedio_Accept object:nil];
    //别人拒绝我的呼叫的一个通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRefuseCall:) name:CALL_Vedio_Refuse object:nil];
}
- (void)presentViewController:(MM1v1CallViewController *)viewContro
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (viewContro) {
            viewContro.modalPresentationStyle = UIModalPresentationOverFullScreen;
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            UIViewController *rootViewController = window.rootViewController;
            [rootViewController presentViewController:viewContro animated:NO completion:nil];
        }
    });
}

#pragma mark - NSNotification
//MARK:1v1视频请求
- (void)handleMake1v1Call:(NSNotification *)notify
{
    //1.如果通知没有object 直接返回
    ZWWLog(@"开始进行视频通话==%@",notify)
    if (!notify.object) {
        return;
    }
    //2.如果正在通话中给出提示
    if (self.isCalling) {
        [MMProgressHUD showHUD:@"有通话正在进行"];
        return;
    }
    //3.接收通知过来的消息
    MMCallParty callParty = (MMCallParty)[notify.object[CALL_CALLPARTY] integerValue];// 主叫方与被叫方
    MMCallType type = (MMCallType)[notify.object[CALL_TYPE] integerValue];// 通话类型
    NSString *chatter = [notify.object valueForKey:CALL_CHATTER] ;// 被叫方ID
    //4.给当前的会话Model赋值
    self.currenSession = [[MMCallSessionModel alloc] init];
    self.currenSession.callParty = callParty;
    self.currenSession.toId = chatter;
    NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    self.currenSession.fromId = userID;
    self.currenSession.callStatus = MMCallStatus_callIng;//正在呼叫对方
    self.currenSession.callParty = MMCallParty_Calling;
    //5.视频和语音调起不同的页面
    if (type == MMCallTypeVideo) {
        //5.1如果是视频
        self.currenViewCtr = [[MM1v1VideoViewController alloc] initWithCallSession:self.currenSession];
    }else{
        //5.2否则则是音频
        MM1v1AudioViewController *audioVC = [[MM1v1AudioViewController alloc] initWithCallSession:self.currenSession];
        audioVC.arrUserDatas = notify.object[CALL_USER_DETAILS];
        self.currenViewCtr = audioVC;
    }
    [self presentViewController:_currenViewCtr];
    self.currenViewCtr.callStatus = MMCallStatus_callIng;
    //6.判断对方是否在线:不在线则给出提示,在前就发起视频请求,同时更改从 (正在连接中)-->(呼叫等待中)
    //0-离线；1-在线；2-忙碌；3-离开；4-隐身
    [[self.ViewModel.GetFriendStatedCommand execute:chatter] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            NSDictionary *dict = x[@"res"];
            if ([dict[@"status"] intValue] == 1) {
                [self sendVedioRequestWithType:type chatter:chatter];
            }else{
                [self endCallWithId:@"对方不在线" callType:0 webrtcId:@"" isNeedHangup:NO];
            }
        }
    }];
}

//接收到对方视频邀请
- (void)handleRequestCall:(NSNotification *)notify
{
    //1.如果通知没有userInfo 直接返回
    if (!notify.userInfo) {
        return;
    }
    //2.如果正在通话中给出提示
    if (self.isCalling) {
        [MMProgressHUD showHUD:@"有通话正在进行"];
        return;
    }
    //3.给当前的Model赋值
    NSDictionary *dic = (NSDictionary *) notify.userInfo;
    NSString *strCMD = [NSString stringWithFormat:@"%@",dic[@"cmd"]];
    self.currenSession = [MMCallSessionModel yy_modelWithDictionary:dic];
    self.currenSession.callParty = MMCallParty_Called;
    self.currenSession.callStatus = MMCallStatus_ring;
    //MARK:群音视频
    if ([strCMD isEqualToString:@"CallGroup"]) {
        if ([dic.allKeys containsObject:@"frmUid"])
            self.currenSession.fromId = dic[@"frmUid"];
        if ([dic.allKeys containsObject:@"groupId"])
            self.currenSession.toId = dic[@"groupId"];
        
        //4.2判断当前的是视频请求还是语音请求
        if (self.currenSession.callType == 4) {
            //4.2.1如果是视频(callType 4)
            self.currenViewCtr = [[MM1v1VideoViewController alloc] initWithCallSession:self.currenSession];
        }else{
            //4.2.2如果是音频(callType 3)
            self.currenViewCtr = [[MM1v1AudioViewController alloc] initWithCallSession:self.currenSession];
        }
    }
    //MARK:1v1音视频
    else{
        //4.1判断当前的是视频请求还是语音请求
        if (self.currenSession.callType == MMCallTypeVideo) {
            //4.1.1如果是视频
            self.currenViewCtr = [[MM1v1VideoViewController alloc] initWithCallSession:self.currenSession];
        }else{
            //4.1.2如果是音频
            self.currenViewCtr = [[MM1v1AudioViewController alloc] initWithCallSession:self.currenSession];
        }
    }
    //5.调起视频或语音UI
    [self presentViewController:self.currenViewCtr];
}

//A-B  B接受 通知A
- (void)handleAcceptCall:(NSNotification *)notify
{
    if (!notify.userInfo) {
        return;
    }
    //2.给当前的Model赋值
    NSDictionary *dic = (NSDictionary *) notify.userInfo;
    ZWWLog(@"manager里面的别人接受我的音视频邀请方法=\n %@",dic)
    self.currenSession = [MMCallSessionModel yy_modelWithDictionary:dic];
    self.currenSession.callParty = MMCallParty_Calling;
    self.currenSession.callStatus = MMCallStatus_talkIng;
    self.currenViewCtr.callStatus = MMCallStatus_talkIng;
    //3.倒计时结束
    [self stopCallTimeoutTimer];
}
//拒绝啦,有可能是我主动拒绝或者别人主动拒绝
- (void)handleRefuseCall:(NSNotification *)notify
{
    ZWWLog(@"我被别人拒绝啦我的音视频请求")
    if (!notify.userInfo) {
        return;
    }
    if (self.currenViewCtr.avConf) {
        [self.currenViewCtr.avConf leave];
    }
    NSDictionary *dic = (NSDictionary *) notify.userInfo;
    [self stopCallTimeoutTimer];
    self.currenSession = nil;
    [self.currenViewCtr clearDataAndView];
    [self.currenViewCtr dismissViewControllerAnimated:NO completion:nil];
    self.currenViewCtr = nil;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    [MMProgressHUD showHUD:dic[@"desc"]];

}

//MARK:1VM群聊音视频请求
-(void)handleMake1vMCall:(NSNotification *)notify{
    //1.如果通知没有object 直接返回
    if (!notify.object) {
        return;
    }
    //3.接收通知过来的消息
    MMCallParty callParty = (MMCallParty)[notify.object[CALL_CALLPARTY] integerValue];// 主叫方与被叫方
    MMCallType type = (MMCallType)[notify.object[CALL_TYPE] integerValue];// 通话类型
    NSString *strGroupId = [NSString stringWithFormat:@"%@",[notify.object valueForKey:CALL_GROUPID]];
    //4.给当前的会话Model赋值
    self.currenSession = [[MMCallSessionModel alloc] init];
    self.currenSession.callParty = callParty;
    self.currenSession.toId = strGroupId;
    NSString *userID = [NSString stringWithFormat:@"%@",[ZWUserModel currentUser].userId];
    self.currenSession.fromId = userID;
    self.currenSession.callStatus = MMCallStatus_callIng;//正在呼叫对方
    self.currenSession.callParty = MMCallParty_Calling;
    //5.视频和语音调起不同的页面
    if (type == MMCallTypeVideo) {
        //5.1如果是视频
        self.currenViewCtr = [[MM1v1VideoViewController alloc] initWithCallSession:self.currenSession];
    }else{
        //5.2否则则是音频
        MM1v1AudioViewController *audioVC = [[MM1v1AudioViewController alloc] initWithCallSession:self.currenSession];
        audioVC.arrUserDatas = notify.object[CALL_USER_DETAILS];
        self.currenViewCtr = audioVC;
    }
    [self presentViewController: self.currenViewCtr];
    self.currenViewCtr.callStatus = MMCallStatus_callIng;
    //6.1发起邀请 群里面的邀请
    [self sendVedioRequestWithType:type
                           groupId:strGroupId];
}
//我在主动呼叫t对方
- (void)sendVedioRequestWithType:(MMCallType)type
                         chatter:(NSString *)chatter
{
    //1v1视频呼叫 视频或者语音呼叫
    NSInteger tagEnumLwCallType;
    if (type == MMCallTypeVoice) {
        ZWWLog(@"适时语音")
        tagEnumLwCallType = 0;
    }else{
        ZWWLog(@"适时视频")
        tagEnumLwCallType = 1;
    }
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"type"] = @"req";
    parma[@"xns"] = @"xns_user";
    parma[@"timeStamp"] = [MMDateHelper getNowTime];
    parma[@"cmd"] = @"callUser";
    parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    parma[@"fromId"] = self.currenSession.fromId;
    parma[@"startId"] = self.currenSession.webrtcId;
    parma[@"toId"] = self.currenSession.toId;
    parma[@"callType"] = @(tagEnumLwCallType);
    parma[@"media"] = @"本地的音视频编码信息，要告知对方";
    [ZWSocketManager SendDataWithData:parma complation:^(NSError * _Nullable error, id  _Nullable data) {
        if (!error) {
            ZWWLog(@"=====%@",data)
            MMCallSessionModel *session = [MMCallSessionModel yy_modelWithDictionary:data];
            if (session.result == 1){
                //对方接收到了我的消息正在响铃
                self.currenViewCtr.callSessionModel = session;
                self.currenSession = session;
                self.currenSession.callStatus = MMCallStatus_ringBack;//回零中,等待对方接听
                self.currenViewCtr.callStatus = MMCallStatus_ringBack;//回铃中(等待对方摘机)
                 [self startCallTimeoutTimer];
            }else{
                ZWWLog(@"请求失败 =>session:%@,result:%ld",session,(long)session.result);
                //6.4延迟调用 不至于闪屏
                /**
                 延迟调用
                 */
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MMProgressHUD showHUD:@"请求失败"];
                });
            }
        }else{
            [YJProgressHUD showError:@"呼叫出现未知错误"];
        }
    }];
}

/** 群音视频邀请 */
- (void)sendVedioRequestWithType:(MMCallType)type
                         groupId:(NSString *)strGroup
{
    __block typeof(self) blockSelf = self;
    __weak typeof(self) weakSelf = self;
    ZWWLog(@"群里面的音视频邀请")
    NSInteger tagEnumLwCallType;
    if (type == MMCallTypeVoice) {
        ZWWLog(@"适时语音")
        tagEnumLwCallType = 3;
    }else{
        ZWWLog(@"适时视频")
        tagEnumLwCallType = 5;
    }
    NSMutableDictionary *Parma = [[NSMutableDictionary alloc]init];
    Parma[@"type"] = @"req";
    Parma[@"xns"] = @"xns_group";
    Parma[@"timeStamp"] = [MMDateHelper getNowTime];
    Parma[@"cmd"] = @"CallGroup";
    Parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    Parma[@"fromId"] = [ZWUserModel currentUser].userId;
    Parma[@"startId"] = @"req";
    Parma[@"groupId"] = strGroup;
    Parma[@"callType"] = @(tagEnumLwCallType);//calltype — 语音 3 , 视频 4 ，音视频 5
    [ZWSocketManager SendDataWithData:Parma complation:^(NSError * _Nullable error, id  _Nullable data) {
        if (!error) {
            NSDictionary *dicTemp = (NSDictionary *)data;
            MMCallSessionModel *session = [MMCallSessionModel yy_modelWithDictionary:dicTemp];
            if ([dicTemp.allKeys containsObject:@"frmUid"]) {
                session.fromId = dicTemp[@"frmUid"];
                session.startId = dicTemp[@"frmUid"];
            }
            if ([dicTemp.allKeys containsObject:@"groupId"]) {
                session.toId = dicTemp[@"groupId"];
            }
            if (session.webrtcId.checkTextEmpty){
                blockSelf.currenViewCtr.callSessionModel = session;
                blockSelf.currenSession = session;
                blockSelf.currenSession.callStatus = MMCallStatus_ringBack;
                blockSelf.currenViewCtr.callStatus = MMCallStatus_ringBack;//回铃中(等待对方摘机)
                if (!weakSelf.isEnter){
                     weakSelf.isEnter = YES;
                    [weakSelf startCallTimeoutTimer];
                }
            }else{
                [YJProgressHUD showError:@"缺少视频通信必要的webrtcid"];
            }
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MMProgressHUD showHUD:@"群音视频请求失败"];
            });
        }
    }];
}

#pragma mark - Call Timeout Before Answered
- (void)timeoutBeforeCallAnswered
{
    [self endCallWithId:self.currenSession.toId
               callType:self.currenSession.callType
               webrtcId:self.currenSession.webrtcId
           isNeedHangup:YES];
    
    //时间结束前请求
    [MMProgressHUD showHUD:@"对方无应答"];
}

- (void)startCallTimeoutTimer
{
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(timeoutBeforeCallAnswered) userInfo:nil repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timeoutTimer forMode:NSRunLoopCommonModes];
}

- (void)stopCallTimeoutTimer
{
    if (self.timeoutTimer == nil) {
        return;
    }
    
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

//挂断
- (void)endCallWithId:(NSString *)aCallId
             callType:(NSInteger)callType
             webrtcId:(NSString *)webrtcId
         isNeedHangup:(BOOL)aIsNeedHangup
{
    self.isCalling = NO;
    [self stopCallTimeoutTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    if (aIsNeedHangup) {
        //请求挂断
        NSMutableDictionary *Parma = [[NSMutableDictionary alloc]init];
           Parma[@"type"] = @"req";
           Parma[@"xns"] = @"xns_user";
           Parma[@"cmd"] = @"HangUpCall";
           Parma[@"timeStamp"] = [MMDateHelper getNowTime];
           Parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
           Parma[@"fromId"] = [ZWUserModel currentUser].userId;
           Parma[@"toId"] = aCallId;
           Parma[@"webrtcId"] = webrtcId;
           Parma[@"media"] = @"本地的音视频编码信息，要告知对方";
           Parma[@"callType"] = @(callType);
        [ZWSocketManager SendDataWithData:Parma complation:^(NSError * _Nullable error, id  _Nullable data) {
            if (!error) {
                self.currenSession = nil;
                [self.currenViewCtr clearDataAndView];
                [self.currenViewCtr dismissViewControllerAnimated:NO completion:nil];
                self.currenViewCtr = nil;
                 AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
                [audioSession setActive:YES error:nil];
            }else{
                [YJProgressHUD showError:@"按理说,无论如何,应该秒退的."];
            }
        }];
    }
    else{
        [MMProgressHUD showHUD:aCallId];
        self.currenSession = nil;
        [self.currenViewCtr clearDataAndView];
        [self.currenViewCtr dismissViewControllerAnimated:NO completion:nil];
        self.currenViewCtr = nil;
    }
}

- (void)refuseCallWithId:(NSString *)aCallId
                callType:(NSInteger)callType
                webrtcId:(NSString *)webrtcId
{
    ZWWLog(@"我主动拒绝别人的音视频请求=====================")
    [self stopCallTimeoutTimer];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    //拒绝别人的视屏通话请求
    NSMutableDictionary *Parma = [[NSMutableDictionary alloc]init];
    Parma[@"type"] = @"req";
    Parma[@"xns"] = @"xns_user";
    Parma[@"cmd"] = @"RejectCall";
    Parma[@"timeStamp"] = [MMDateHelper getNowTime];
    Parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;
    Parma[@"fromId"] = [ZWUserModel currentUser].userId;
    Parma[@"toId"] = aCallId;
    Parma[@"startId"] = aCallId;
    Parma[@"webrtcId"] = webrtcId;
    Parma[@"media"] = @"本地的音视频编码信息，要告知对方";
    Parma[@"callType"] = @(callType);
    [ZWSocketManager SendDataWithData:Parma complation:^(NSError * _Nullable error, id  _Nullable data) {
        if (!error) {
            MMCallSessionModel *session = [MMCallSessionModel yy_modelWithDictionary:data];
            ZWWLog(@"拒绝别人的视频请求=%@",session)
            [MMProgressHUD showHUD:@"已拒绝"];
            [self.currenViewCtr clearDataAndView];
            [self.currenViewCtr dismissViewControllerAnimated:NO completion:nil];
            self.currenSession = nil;
            self.currenViewCtr = nil;
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:nil];
        }
    }];
}
-(ZWCallViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWCallViewModel alloc]init];
    }
    return _ViewModel;
}
@end


