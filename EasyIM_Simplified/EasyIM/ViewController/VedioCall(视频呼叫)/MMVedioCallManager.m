//
//  MMVedioCallManager.m
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMVedioCallManager.h"

//头文件
#import "MMDefines.h"
#import "MMGlobalVariables.h"
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
 
    MMLog(@"我销毁了......");
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRequestCall:) name:CALL_Vedio_Request object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAcceptCall:) name:CALL_Vedio_Accept object:nil];
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
    if (!notify.object) {
        return;
    }
    //2.如果正在通话中给出提示
    if (isCalling) {
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
    [MMRequestManager checkUserOnlineWithUserId:chatter callBack:^(NSInteger status, NSError * _Nonnull error) {
        if (!error && status == 1) {
            //6.1发起邀请
            [self sendVedioRequestWithType:type chatter:chatter];
        }else{
            [self endCallWithId:@"对方不在线" callType:0 webrtcId:@"" isNeedHangup:NO];
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
    if (isCalling) {
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
        /**
         {
         callType = 3;
         cmd = CallGroup;
         frmUid = 10023440;
         groupId = 1348;
         sessionID = B8FC1D3AB3244B76B11F4647303855E3;
         startId = 10023440;
         timeStamp = 1562674013;
         type = rsp;
         webrtcId = 10023440;
         xns = "xns_group";
         }
         */
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
        /**
         {
         callType = 0;
         cmd = callUser;
         desc = "呼叫已发出！";
         fromId = 10023440;
         fromName = 190528;
         fromNick = "贝贝";
         fromPhoto = "http://103.240.142.115/user_files/10023440/20190709/5d2475b0471e2.png";
         result = 1;
         sessionID = B8FC1D3AB3244B76B11F4647303855E3;
         startId = 10023440;
         timeStamp = 1562674557;
         toId = 10063483;
         type = rsp;
         webrtcId = 10023440;
         xns = "xns_user";
         }

         */
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
    
    //1.如果通知没有object 直接返回
    if (!notify.userInfo) {
        return;
    }

    //2.给当前的Model赋值
    NSDictionary *dic = (NSDictionary *) notify.userInfo;
    self.currenSession = [MMCallSessionModel yy_modelWithDictionary:dic];
    self.currenSession.callParty = MMCallParty_Calling;
    self.currenSession.callStatus = MMCallStatus_talkIng;
    self.currenViewCtr.callStatus = MMCallStatus_talkIng;

    //3.倒计时结束
    [self stopCallTimeoutTimer];
}

//被拒绝
- (void)handleRefuseCall:(NSNotification *)notify
{
    
    //1.如果通知没有object 直接返回
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
    //NSArray *arrChatter = [notify.object valueForKey:CALL_CHATTER];// 被叫方ID，userId 数组
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
    
    //6.1发起邀请
    [self sendVedioRequestWithType:type
                           groupId:strGroupId];
}


#pragma mark - Request

//Request
- (void)sendVedioRequestWithType:(MMCallType)type
                         chatter:(NSString *)chatter
{
    
    [MMRequestManager sendVedioRequestWithToId:chatter
                                      callType:type
                                      callBack:^(MMCallSessionModel * _Nonnull session, NSError * _Nonnull error) {
        if (!error) {
            MMLog(@"音视频邀请，session:%@",session);
            
            //邀请成功
            if (session.result == 1) {
                //6.2改变状态
                self.currenViewCtr.callSessionModel = session;
                self.currenSession = session;
                self.currenSession.callStatus = MMCallStatus_ringBack;
                self.currenViewCtr.callStatus = MMCallStatus_ringBack;//回铃中(等待对方摘机)
                //6.3超时倒计时开启
                [self startCallTimeoutTimer];
            }else{
                MMLog(@"请求失败 =>session:%@,result:%ld",session,(long)session.result);
                //6.4延迟调用 不至于闪屏
                /**
                 延迟调用

                 @param DISPATCH_TIME_NOW 时间参照,从此刻开始计时
                 @param int64_t 延时多久,此处为秒级
                 @return
                 */
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [MMProgressHUD showHUD:@"请求失败"];
                });
            }
        }else{
            MMLog(@"音视频邀请异常！详见：%@",error);
        }
    }];
    
}

/** 群音视频邀请 */
- (void)sendVedioRequestWithType:(MMCallType)type
                         groupId:(NSString *)strGroup
{
    
    __block typeof(self) blockSelf = self;
    __weak typeof(self) weakSelf = self;
    [MMRequestManager sendVideoOrAudioWithGroupId:strGroup
                                      andCallType:type
                                         callBack:^(MMCallSessionModel * _Nonnull session, NSError * _Nonnull error) {
                                             
                                             
                                             if (session.webrtcId.checkTextEmpty) {
                                                 
                                                 //6.2改变状态
                                                 blockSelf.currenViewCtr.callSessionModel = session;
                                                 blockSelf.currenSession = session;
                                                 blockSelf.currenSession.callStatus = MMCallStatus_ringBack;
                                                 blockSelf.currenViewCtr.callStatus = MMCallStatus_ringBack;//回铃中(等待对方摘机)
                                                 
                                                 //6.3超时倒计时开启
                                                 if (!weakSelf.isEnter) {
                                                     weakSelf.isEnter = YES;
                                                     [weakSelf startCallTimeoutTimer];
                                                 }
                                                 
                                             }else{
                                                 
                                                 if (!error) {
                                                     
                                                 }else{
                                                     
                                                     MMLog(@"请求失败 =>session:%@,result:%ld",session,(long)session.result);
                                                     //6.4延迟调用 不至于闪屏
                                                     /**
                                                      延迟调用
                                                      
                                                      @param DISPATCH_TIME_NOW 时间参照,从此刻开始计时
                                                      @param int64_t 延时多久,此处为秒级
                                                      @return
                                                      */
                                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                         [MMProgressHUD showHUD:@"群音视频请求失败"];
                                                     });
                                                     
                                                 }
                                                
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
    
    isCalling = NO;
    [self stopCallTimeoutTimer];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    if (aIsNeedHangup) {
        //请求挂断
        [MMRequestManager hangUpCallWithToId:aCallId webrtcId:webrtcId callType:callType callBack:^(MMCallSessionModel * _Nonnull session, NSError * _Nonnull error) {
            self.currenSession = nil;
            [self.currenViewCtr clearDataAndView];
            [self.currenViewCtr dismissViewControllerAnimated:NO completion:nil];
            self.currenViewCtr = nil;
            
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
            [audioSession setActive:YES error:nil];

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
    [self stopCallTimeoutTimer];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    
    [MMRequestManager rejectCallWithToId:aCallId webrtcId:webrtcId callType:callType callBack:^(MMCallSessionModel * _Nonnull session, NSError * _Nonnull error) {
        MMLog(@"%@",session);
        [MMProgressHUD showHUD:@"已拒绝"];
        
        [self.currenViewCtr clearDataAndView];
        [self.currenViewCtr dismissViewControllerAnimated:NO completion:nil];
        
        self.currenSession = nil;
        self.currenViewCtr = nil;
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
        [audioSession setActive:YES error:nil];

        
    }];

    
    
}

@end


