//
//  MM1v1CallViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MM1v1CallViewController.h"


@class MM1v1CallViewController;

@interface ARDConfEvents ()

- (instancetype)initWithVC:(MM1v1CallViewController*)controller;

@property(copy) NSString* currentFullscreen;

@end


@interface MM1v1CallViewController ()

@property (nonatomic, strong) NSTimer *callDurationTimer;
@property (nonatomic) int callDuration;
@property (nonatomic, assign) BOOL needRefuseUp;

/** WebRTC Party*/
@property (nonatomic, strong) ARDSettingsModel  *settingsModel;
@property (nonatomic, strong) ARDConfEvents *confEvents;
@property (nonatomic, strong) NSString *uid;

@property (nonatomic, assign) long long roomId;
@property (nonatomic, assign) BOOL configured;


@end

@implementation MM1v1CallViewController

- (instancetype)initWithCallSession:(MMCallSessionModel *)aCallSession
{
    self = [super init];
    if (self) {
        _callSessionModel = aCallSession;
        _callStatus = MMCallStatus_disconnected;//记录此时处于未连接状态
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//设置不锁屏
    
    [self setup1v1CallControllerSubviews];//创建UI
    
    self.timeLabel.hidden = YES;//隐藏计时器
    self.answerButton.enabled = NO;//反应按钮不可用
    self.callStatus = self.callSessionModel.callStatus;
    
    if (self.callSessionModel.callParty == MMCallParty_Called) {
        self.remoteNameLabel.text = self.callSessionModel.nickName.length ? self.callSessionModel.nickName:self.callSessionModel.fromName;
    }else{
        self.remoteNameLabel.text = [MMManagerGlobeUntil sharedManager].userName;
    }
    
    //监测耳机状态，如果是插入耳机状态，不显示扬声器按钮
    self.speakerButton.hidden = isHeadphone();
}

#pragma mark - Subviews

- (void)setup1v1CallControllerSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.statusLabel.text = @"正在建立连接...";
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:25];
    self.timeLabel.textColor = [UIColor blackColor];
    self.timeLabel.textAlignment = NSTextAlignmentRight;
    self.timeLabel.text = @"00:00";
    [self.view addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    self.remoteNameLabel = [[UILabel alloc] init];
    self.remoteNameLabel.backgroundColor = [UIColor clearColor];
    self.remoteNameLabel.font = [UIFont systemFontOfSize:15];
    self.remoteNameLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.remoteNameLabel];
    [self.remoteNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusLabel.mas_bottom).offset(15);
        make.left.equalTo(self.statusLabel.mas_left).offset(5);
        make.right.equalTo(self.view).offset(-15);
    }];
    
    //最小化
    [self.minButton setImage:[UIImage imageNamed:@"minimize_gray"] forState:UIControlStateNormal];
    [self.minButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-30);
        make.right.equalTo(self.view).offset(-25);
        make.width.height.equalTo(@40);
    }];
    
    //判断是否为主叫方 根据状态绘制UI
    if (self.callSessionModel.callParty == MMCallParty_Calling) {
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-40);
            make.width.height.equalTo(@60);
        }];
        
    } else {
        CGFloat size = 60;
        CGFloat padding = ([UIScreen mainScreen].bounds.size.width - size * 2) / 3;
        
        [self.hangupButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.view).offset(-40);
            make.right.equalTo(self.view).offset(-padding);
            make.width.height.mas_equalTo(size);
        }];
        
        self.answerButton = [[UIButton alloc] init];
        self.answerButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.answerButton setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(answerAction) forControlEvents:UIControlEventTouchUpInside];
        self.answerButton.enabled = NO;
        [self.view addSubview:self.answerButton];
        [self.answerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.hangupButton);
            make.left.equalTo(self.view).offset(padding);
            make.width.height.mas_equalTo(size);
        }];
    }
    
}

#pragma mark - Status

- (void)setCallStatus:(MMCallStatus)callStatus
{
    
    if (_callStatus>=callStatus) {//如果大于当前状态直接返回
        return;
    }
    
    switch (callStatus) {
        case MMCallStatus_callIng:
        {
            self.statusLabel.text = @"正在建立连接...";
        }
            break;
        case MMCallStatus_ringBack:
        {
            self.statusLabel.text = @"等待接听...";
            
            //此时显示自己的视频
            //初始化默认设置
            ARDSettingsModel* settingModel = [[ARDSettingsModel alloc] init];
            
            //初始化config
            [self initForRoom:self.callSessionModel.webrtcId
                      roomUrl:[settingModel currentRoomUrlSettingFromStore]];
            
            //加入房间
            [_avConf join:[self.callSessionModel.webrtcId longLongValue]];
        }
            break;
        case MMCallStatus_talkIng:
        {
            self.statusLabel.text = @"通话中...";
            self.needRefuseUp = YES;
            [self startCallDurationTimer];
            [self startVedio];
            self.timeLabel.hidden = NO;
        }
            break;
        case MMCallStatus_busyIng:
        {
            self.statusLabel.text = @"对方忙...";
        }
            break;
        case MMCallStatus_ring:
        {
            self.statusLabel.text = @"等待接听...";
            self.answerButton.enabled = YES;
            
        }
            break;
        case MMCallStatus_jinHua:
        {
            
        }
            break;
            
        case MMCallStatus_hangUp:
        {
            
        }
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Timer

- (void)updateCallDuration
{
    self.callDuration += 1;
    int hour = self.callDuration / 3600;
    int m = (self.callDuration - hour * 3600) / 60;
    int s = self.callDuration - hour * 3600 - m * 60;
    
    if (hour > 0) {
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i:%i", hour, m, s];
    }
    else if(m > 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i", m, s];
    }
    else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%i", s];
    }
}

- (void)startCallDurationTimer
{
    [self stopCallDurationTimer];
    
    self.callDuration = 0;
    self.callDurationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCallDuration) userInfo:nil repeats:YES];
}

- (void)stopCallDurationTimer
{
    if (self.callDurationTimer) {
        [self.callDurationTimer invalidate];
        self.callDurationTimer = nil;
    }
}

#pragma mark - Action
//接受邀请
- (void)answerAction
{
    
//    [MMRequestManager acceptCallWithModel:self.callSessionModel
//                                 callType:self.callSessionModel.callType
//                                 aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
//        
//        NSLog(@"接受RSP%@",dic);
//        
//        self.callStatus = MMCallStatus_talkIng;
//        self.callSessionModel.callStatus = MMCallStatus_talkIng;
//        ARDSettingsModel* settingModel = [[ARDSettingsModel alloc] init];
//        
//        [self initForRoom:dic[@"webrtcId"]
//                  roomUrl:[settingModel currentRoomUrlSettingFromStore]];
//        [self.avConf join:[dic[@"webrtcId"] longLongValue]];
//    }];
    
}


#pragma mark - Private

- (void)startVedio
{
    //如果不是主叫方 UI状态
    if (self.callSessionModel.callParty != MMCallParty_Calling) {
        [self.answerButton removeFromSuperview];
        [self.hangupButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-40);
            make.width.height.equalTo(@60);
        }];
    }
    
    if (self.microphoneButton.isSelected) {//暂停语音传输
        //                [self.callSessionModel pauseVoice];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!self.microphoneButton.isSelected && self.speakerButton.isSelected) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            [audioSession setActive:YES error:nil];
        }
    });
    
}

- (void)clearDataAndView
{
    [self stopCallDurationTimer];
}

- (void)dealloc
{
    [self clearDataAndView];
}

- (void)hangupAction
{
    
    [self clearDataAndView];
    
    //挂断或者拒绝请求
    
    if (self.callSessionModel.callParty == MMCallParty_Called && self.needRefuseUp != YES ) {//如果是被叫方,拒绝
        
        //拒绝
        [[MMVedioCallManager sharedManager] refuseCallWithId:self.callSessionModel.fromId callType:self.callSessionModel.callType webrtcId:self.callSessionModel.webrtcId];
        
    }else{
        //挂断
        NSString *toId = @"";
        if (self.callSessionModel.callParty == MMCallParty_Called) {
            toId = self.callSessionModel.fromId;
        }else{
            toId = self.callSessionModel.toId;
        }
        [[MMVedioCallManager sharedManager] endCallWithId:toId
                                                 callType:self.callSessionModel.callType
                                                 webrtcId:self.callSessionModel.webrtcId
                                             isNeedHangup:YES];
    }
    
    
    _callSessionModel = nil;
    [_avConf leave];
}


- (void)microphoneButtonAction
{
    if (self.microphoneButton.isSelected) {
//        [_avConf setVideoEnabled:_uid enabled:1];
        [_avConf setAudioEnabled:_uid enabled:0];
//        AVAudioSession *AV = [AVAudioSession sharedInstance];
//        [AV setActive:NO error:nil];
        
    }else{
//        [_avConf setVideoEnabled:_uid enabled:0];
        [_avConf setAudioEnabled:_uid enabled:1];
//        AVAudioSession *AV = [AVAudioSession sharedInstance];
//        [AV setActive:YES error:nil];

    }
}


#pragma mark - WebRtcInit

- (void)initForRoom:(NSString*)room
            roomUrl:(NSString*)roomUrl
{
    
    MMLog(@"roomUrl=============%@",roomUrl);
    
    self.settingsModel = [[ARDSettingsModel alloc] init];
    self.uid = [_settingsModel currentUidSettingFromStore];
    self.roomId = room.longLongValue;
    
    int videoWidth = [_settingsModel currentVideoResolutionWidthFromStore];
    int videoHeight = [_settingsModel currentVideoResolutionHeightFromStore];
    
    CFConfConfigBuilder* configBuilder = [CFConfConfig builder];
    
    //Room Server URL 地址
    [configBuilder rs_url:roomUrl];
    
    /*
     *运行模式
     *MODE_APPRTC
     *MODE_JANUS_VIDEO_ROOM  默认:SFU 模式,所有音视频数据都经过 server中转
     */
    [configBuilder mode:MODE_JANUS_VIDEO_ROOM];
    
    //最大推流者人数,默认是4
    [configBuilder max_peers:CALL_VEDIO1VM_MAX];
    
    //视频采集宽度,高度(无论横竖屏,宽始终要大于高)
    [configBuilder video_capture_width:videoWidth];
    [configBuilder video_capture_height:videoHeight];
    
    //视频推送宽度,高度
    [configBuilder video_publish_width:videoWidth];
    [configBuilder video_publish_height:videoHeight];
    
    //视频推送帧率
    [configBuilder video_fps:30];
    
    //连接 server 超时时间,单位秒,默认8秒
    [configBuilder rs_connect_timeout:8];
    
    //连续最多失败重连次数,默认7次,这个重连会有指数退避延迟策略,初始延迟1s,之后倍增,最多延迟8s
    [configBuilder retry_times:7];
    
    [configBuilder
     start_bitrate:[[_settingsModel currentMaxBitrateSettingFromStore] intValue]];
    CFConfConfig* config = [configBuilder build];
    
    _confEvents = [[ARDConfEvents alloc] initWithVC:self];
    _avConf = [[CFAvConf alloc] initWithUid:_uid
                                  andConfig:config
                                  andEvents:_confEvents];
    
    MMLog(@"%ld",self.callSessionModel.callType);
    
    //3 群聊语音 4 群聊视频
    if (self.callSessionModel.callType == MMCallTypeVoice ||
        self.callSessionModel.callType == 3) {
        [_avConf setVideoEnabled:_uid enabled:0];
    }else{
        //设置音频
        [_avConf setAudioEnabled:_uid enabled:1];
        //设置视频
        [_avConf setVideoEnabled:_uid enabled:1];
    }
    
    //创建视频窗口
    [self setupUIs];

}


/**
 生命周期:
 viewDidLoad -> viewWillAppear -> viewWillLayoutSubviews -> viewDidLayoutSubviews -> viewDidAppear -> viewWillDisappear -> viewDidDisappear
 */
- (void)setupUIs
{
    
    if (_configured) {
        return;
    }
    _configured = true;
    
    int videoWidth = [_settingsModel currentVideoResolutionWidthFromStore];
    int videoHeight = [_settingsModel currentVideoResolutionHeightFromStore];
    
    CGSize fullscreen = [UIScreen mainScreen].bounds.size;
    int horizontalMargin = fullscreen.width / 20;
    int bottomMargin = fullscreen.width / 5;
    int smallWindowWidth = (fullscreen.width - horizontalMargin * 4) / 3;
    int smallWindowHeight = smallWindowWidth * videoWidth / videoHeight;
    int smallWindowTop = bottomMargin;
    
    CFLayoutConfig* layoutConfig = [[CFLayoutConfig alloc] init];
    
    if (self.callSessionModel.callType == MMCallTypeVoice ||
        self.callSessionModel.callType == 3) {
        layoutConfig.rootLayout = self.view;
        layoutConfig.windows = @[[[CFUserWindow alloc] initWithTop:0
                                                          withLeft:0
                                                         withWidth:1
                                                        withHeight:1
                                                        withZIndex:0]];
    }else{
        layoutConfig.rootLayout = self.view;
        layoutConfig.windows = @[
                                 [[CFUserWindow alloc] initWithTop:0
                                                          withLeft:0
                                                         withWidth:fullscreen.width
                                                        withHeight:fullscreen.height
                                                        withZIndex:0],//大屏幕
                                 
                                 [[CFUserWindow alloc] initWithTop:smallWindowTop
                                                          withLeft:horizontalMargin * 3 + smallWindowWidth * 2
                                                         withWidth:smallWindowWidth
                                                        withHeight:smallWindowHeight
                                                        withZIndex:1],//小屏幕1
                                 
                                 [[CFUserWindow alloc] initWithTop:smallWindowTop
                                                          withLeft:horizontalMargin * 2 + smallWindowWidth
                                                         withWidth:smallWindowWidth
                                                        withHeight:smallWindowHeight
                                                        withZIndex:2],//小屏幕2
                                 
                                 [[CFUserWindow alloc] initWithTop:smallWindowTop
                                                          withLeft:horizontalMargin
                                                         withWidth:smallWindowWidth
                                                        withHeight:smallWindowHeight
                                                        withZIndex:3],//小屏幕3
                                 ];
    }
    
    
    CFPeerConnectionFactoryOption* option = [[CFPeerConnectionFactoryOption alloc] init];
    option.preferredVideoCodec = [_settingsModel currentVideoCodecSettingFromStore];
    [_avConf configure:layoutConfig factoryOption:option];
}

@end




@implementation ARDConfEvents
{
    
    __weak MM1v1CallViewController *_controller;
    
}

- (instancetype)initWithVC:(MM1v1CallViewController*)controller
{
    self = [super init];
    if (self) {
        _controller = controller;
        _currentFullscreen = nil;
    }
    return self;
}

- (void)onPeerJoinedWithNSString:(NSString*)uid
{
    
    MM1v1CallViewController* callVc = _controller;
    if (callVc == nil) {
        return;
    }
    UIView* wrapper = [callVc.avConf getRendererWrapper:uid];
    if (wrapper != nil) {
        if (self.currentFullscreen == nil) {
            self.currentFullscreen = uid;
        }
        UITapGestureRecognizer* singleFingerTap =
        [[UITapGestureRecognizer alloc]
         initWithTarget:self
         action:@selector(handleSingleTap:)];
        [wrapper addGestureRecognizer:singleFingerTap];
    }
    
}

- (void)handleSingleTap:(UITapGestureRecognizer*)recognizer
{
    
    MM1v1CallViewController* callVc = _controller;
    if (callVc == nil) {
        return;
    }
    
    self.currentFullscreen = recognizer.view.userWindow.uid;
    [callVc.avConf toggleFullscreen:self.currentFullscreen];
}


- (void)onErrorWithInt:(jint)code withNSString:(NSString*)data
{
    
    __weak MM1v1CallViewController* weakVC = _controller;
    MM1v1CallViewController* callVc = weakVC;
    if (callVc == nil) {
        return;
    }
    
    if (code == ERR_RETRYING) {
        
        [MMProgressHUD showHUD:@"重连"];
        return;
    }
    
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:@"Connection error"
                                message:[CFLogUtil confErr:code]
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction* action) {
                                        MM1v1CallViewController* callVc2 = weakVC;
                                        if (callVc2 == nil) {
                                            return;
                                        }
                                        [callVc2.avConf leave];
                                    }];
    
    [alert addAction:defaultAction];
    [callVc presentViewController:alert animated:YES completion:nil];
}


@end
