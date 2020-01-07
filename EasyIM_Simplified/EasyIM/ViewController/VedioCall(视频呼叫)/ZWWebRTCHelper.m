//
//  ZWWebRTCHelper.m
//  EasyIM
//
//  Created by step_zhang on 2020/1/7.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWWebRTCHelper.h"
static NSString *const RTCSTUNServerURL = @"stun:stun.l.google.com:19302";
static NSString *const RTCSTUNServerURL2 = @"stun:23.21.150.121";
@interface ZWWebRTCHelper()<RTCPeerConnectionDelegate,RTCVideoCapturerDelegate>
{
    RTCPeerConnectionFactory *_factory;
    RTCMediaStream *_localStream;
    NSString *_myId;
    NSMutableDictionary *_connectionDic;
    NSMutableArray *_connectionIdArray;
    NSString * _connectId;
    NSMutableArray *ICEServers;
    //判断是显示前摄像头还是显示后摄像头（yes为前摄像头。false为后摄像头）
    BOOL _usingFrontCamera;
    //是否显示我的视频流（默认为yes，显示；no为不显示）
    BOOL _usingCamera;
}
@end
@implementation ZWWebRTCHelper
static ZWWebRTCHelper * instance = nil;
+(instancetype)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
        [instance initData];
    });
    return instance;
}
-(void)initData{
    _connectionDic = [NSMutableDictionary dictionary];
    _connectionIdArray = [NSMutableArray array];
    _usingFrontCamera = YES;
    _usingCamera = YES;
}
#pragma mark -提供给外部的方法
/**与服务起建立连接,交给z封装的socket*/
- (void)connectServer:(NSString *)server port:(NSString *)port room:(NSString *)room{
    ZWWLog(@"开始于服务器l建立连接 = %@",room)
}
/**
 *  加入房间
 *
 *  @param room 房间号
 */
- (void)joinRoom:(NSString *)room{
    ZWWLog(@"我接受或者别人接受我的音视频邀请")
    //发送请求,得到房间id
}
/**
 *  退出房间
 */
- (void)exitRoom{
    ZWWLog(@"挂断或者别人挂断正在进行的音视频请求")
    //在这个时候,告诉后台,挂断了
     _localStream = nil;
    //里面是模型
    [_connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
           [self closePeerConnection:obj];
       }];
}
/**
 * 切换摄像头
 */
- (void)swichCamera{
    _usingFrontCamera = !_usingFrontCamera;
    [self createLocalStream];
}
/**
 * 是否显示本地摄像头
 */
- (void)showLocaolCamera{
    _usingCamera = !_usingCamera;
    //如果为空，则创建点对点工厂
    if (!_factory)
    {
        //设置SSL传输
        [RTCPeerConnectionFactory initialize];
        _factory = [[RTCPeerConnectionFactory alloc] init];
    }
    //如果本地视频流为空
    if (!_localStream)
    {
        //创建本地流
        [self createLocalStream];
    }
    //创建连接
    [self createPeerConnections];
    
    //添加
    [self addStreams];
    [self createOffers];
}
- (void)closePeerConnection:(NSString *)connectionId{
    RTCPeerConnection *peerConnection = [_connectionDic objectForKey:connectionId];
    if (peerConnection)
    {
        [peerConnection close];
    }
    [_connectionIdArray removeObject:connectionId];
    [_connectionDic removeObjectForKey:connectionId];
    //通过代理,告诉外面,退出成功
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self->_delegate respondsToSelector:@selector(webRTCHelper:closeWithUserId:)])
        {
            [self->_delegate webRTCHelper:self closeWithUserId:connectionId];
        }
    });
}
//创建点对点连接
- (RTCPeerConnection *)createPeerConnection:(NSString *)connectionId
{
    //如果点对点工厂为空
    if (!_factory)
    {
        //先初始化工厂
        _factory = [[RTCPeerConnectionFactory alloc] init];
    }
    //得到ICEServer
    if (!ICEServers) {
        ICEServers = [NSMutableArray array];
        [ICEServers addObject:[self defaultSTUNServer]];
    }
    
    //用工厂来创建连接
    RTCConfiguration *configuration = [[RTCConfiguration alloc] init];
    configuration.iceServers = ICEServers;
    RTCPeerConnection *connection = [_factory peerConnectionWithConfiguration:configuration constraints:[self creatPeerConnectionConstraint] delegate:self];
    return connection;
}
- (RTCMediaConstraints *)creatPeerConnectionConstraint
{
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:@{kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue} optionalConstraints:nil];
    return constraints;
}
- (RTCIceServer *)defaultSTUNServer{
    return [[RTCIceServer alloc] initWithURLStrings:@[RTCSTUNServerURL,RTCSTUNServerURL2]];
}
/**
 *  为所有连接添加流
 */
- (void)addStreams
{
    //给每一个点对点连接，都加上本地流
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if (!self->_localStream)
        {
            [self createLocalStream];
        }
        [obj addStream:self->_localStream];
    }];
}
/**
 *  创建所有连接
 */
- (void)createPeerConnections
{
    //从我们的连接数组里快速遍历
    [_connectionIdArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //根据连接ID去初始化 RTCPeerConnection 连接对象
        RTCPeerConnection *connection = [self createPeerConnection:obj];
        //设置这个ID对应的 RTCPeerConnection对象
        [self->_connectionDic setObject:connection forKey:obj];
    }];
}
/**
* 创建本地视频流
*/
-(void)createLocalStream{
    _localStream = [_factory mediaStreamWithStreamId:@"ARDAMS"];
    //音频
    RTCAudioTrack * audioTrack = [_factory audioTrackWithTrackId:@"ARDAMSa0"];
    [_localStream addAudioTrack:audioTrack];
    NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
    AVCaptureDevicePosition position = _usingFrontCamera ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
    AVCaptureDevice * device = captureDevices[0];
    for (AVCaptureDevice *obj in captureDevices) {
        if (obj.position == position) {
            device = obj;
            break;
        }
    }
    //检测摄像头权限
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
    {
        ZWWLog(@"相机访问受限");
        if ([_delegate respondsToSelector:@selector(webRTCHelper:setLocalStream:userId:)])
        {
            [_delegate webRTCHelper:self setLocalStream:nil userId:_myId];
        }
    }
    else
    {
        if (device)
        {
            RTCVideoSource *videoSource = [_factory videoSource];
            RTCCameraVideoCapturer * capture = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
            AVCaptureDeviceFormat * format = [[RTCCameraVideoCapturer supportedFormatsForDevice:device] lastObject];
            CGFloat fps = [[format videoSupportedFrameRateRanges] firstObject].maxFrameRate;
            RTCVideoTrack *videoTrack = [_factory videoTrackWithSource:videoSource trackId:@"ARDAMSv0"];
            __weak RTCCameraVideoCapturer *weakCapture = capture;
            __weak RTCMediaStream * weakStream = _localStream;
            __weak NSString * weakMyId = _myId;
            [weakCapture startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * error) {
                ZWWLog(@"11111111");
                [weakStream addVideoTrack:videoTrack];
                if ([self->_delegate respondsToSelector:@selector(webRTCHelper:setLocalStream:userId:)])
                {
                    [self->_delegate webRTCHelper:self setLocalStream:weakStream userId:weakMyId];
                    [self->_delegate webRTCHelper:self capturerSession:weakCapture.captureSession];
                }
            }];
//            [videoSource adaptOutputFormatToWidth:640 height:480 fps:30];
        }
        else
        {
            ZWWLog(@"该设备不能打开摄像头");
            if ([_delegate respondsToSelector:@selector(webRTCHelper:setLocalStream:userId:)])
            {
                [_delegate webRTCHelper:self setLocalStream:nil userId:_myId];
            }
        }
    }
}
/**
 *  视频的相关约束
 */
- (RTCMediaConstraints *)localVideoConstraints
{
    NSDictionary *mandatory = @{kRTCMediaConstraintsMaxWidth:@640,kRTCMediaConstraintsMinWidth:@640,kRTCMediaConstraintsMaxHeight:@480,kRTCMediaConstraintsMinHeight:@480,kRTCMediaConstraintsMinFrameRate:@15};
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatory optionalConstraints:nil];
    return constraints;
}
/**
 * 创建offer
 */
-(void)createOffer:(RTCPeerConnection *)peerConnection{
    if (peerConnection == nil) {
        peerConnection = [self createPeerConnection:nil];
    }
    [peerConnection offerForConstraints:[self offerOranswerConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error == nil) {
            __weak RTCPeerConnection * weakPeerConnction = peerConnection;
            [weakPeerConnction setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                if (error == nil) {
                    [self setSessionDescriptionWithPeerConnection:weakPeerConnction];
                }
            }];
        }
    }];

}
/**
 *  为所有连接创建offer
 */
- (void)createOffers
{
    //给每一个点对点连接，都去创建offer
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        [self createOffer:obj];
    }];
}
/**
 *  设置offer/answer的约束
 */
- (RTCMediaConstraints *)offerOranswerConstraint
{
    NSMutableDictionary * dic = [@{kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue} mutableCopy];
    [dic setObject:(_usingCamera ? kRTCMediaConstraintsValueTrue : kRTCMediaConstraintsValueFalse) forKey:kRTCMediaConstraintsOfferToReceiveVideo];
    RTCMediaConstraints *constraints = [[RTCMediaConstraints alloc] initWithMandatoryConstraints:dic optionalConstraints:nil];
    return constraints;
}
//当一个远程或者本地的SDP被设置就会调用
- (void)setSessionDescriptionWithPeerConnection:(RTCPeerConnection *)peerConnection
{
    NSLog(@"%s",__func__);
    NSString *currentId = [self getKeyFromConnectionDic:peerConnection];
    
    //判断，当前连接状态为，收到了远程点发来的offer，这个是进入房间的时候，尚且没人，来人就调到这里
    if (peerConnection.signalingState == RTCSignalingStateHaveRemoteOffer)
    {
        //创建一个answer,会把自己的SDP信息返回出去
        [peerConnection answerForConstraints:[self offerOranswerConstraint] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
            __weak RTCPeerConnection *obj = peerConnection;
            [peerConnection setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
                [self setSessionDescriptionWithPeerConnection:obj];
            }];
        }];
    }
    //判断连接状态为本地发送offer
    else if (peerConnection.signalingState == RTCSignalingStateHaveLocalOffer)
    {
        if (peerConnection.localDescription.type == RTCSdpTypeAnswer)
        {
            NSDictionary *dic = @{@"eventName": @"__answer", @"data": @{@"sdp": @{@"type": @"answer", @"sdp": peerConnection.localDescription.sdp}, @"socketId": currentId}};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            //[_socket send:data]; /需要将数据发送到远端
        }
        //发送者,发送自己的offer
        else if(peerConnection.localDescription.type == RTCSdpTypeOffer)
        {
            NSDictionary *dic = @{@"eventName": @"__offer", @"data": @{@"sdp": @{@"type": @"offer", @"sdp": peerConnection.localDescription.sdp}, @"socketId": currentId}};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            //[_socket send:data]; /需要将数据发送到远端
        }
    }
    else if (peerConnection.signalingState == RTCSignalingStateStable)
    {
        if (peerConnection.localDescription.type == RTCSdpTypeAnswer)
        {
            NSDictionary *dic = @{@"eventName": @"__answer", @"data": @{@"sdp": @{@"type": @"answer", @"sdp": peerConnection.localDescription.sdp}, @"socketId": currentId}};
            NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
            //[_socket send:data];
            //需要将数据发送到远端
        }
    }
    
}
#pragma mark RTCPeerConnectionDelegate
/**获取远程视频流*/
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didAddStream:(nonnull RTCMediaStream *)stream {
    NSString * userId = [self getKeyFromConnectionDic:peerConnection];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self->_delegate respondsToSelector:@selector(webRTCHelper:addRemoteStream:userId:)]) {
            [self->_delegate webRTCHelper:self addRemoteStream:stream userId:userId];
        }
    });
}
/**RTCIceConnectionState 状态变化*/
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState {
    ZWWLog(@"%s",__func__);
    NSString * connectId = [self getKeyFromConnectionDic:peerConnection];
    if (newState == RTCIceConnectionStateDisconnected) {
        //断开connection的连接
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self->_delegate respondsToSelector:@selector(webRTCHelper:closeWithUserId:)]) {
                [self->_delegate webRTCHelper:self closeWithUserId:connectId];
            }
            [self closePeerConnection:connectId];
        });
    }
}
/**获取到新的candidate*/
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate{
    ZWWLog(@"%s",__func__);
    
    NSString *currentId = [self getKeyFromConnectionDic: peerConnection];
    
    NSDictionary *dic = @{@"eventName": @"__ice_candidate", @"data": @{@"id":candidate.sdpMid,@"label": [NSNumber numberWithInteger:candidate.sdpMLineIndex], @"candidate": candidate.sdp, @"socketId": currentId}};
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    //[_socket send:data];
    //需要将服务器的数据 发送到远端
}
/**删除某个视频流*/
- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveStream:(nonnull RTCMediaStream *)stream {
    NSLog(@"%s",__func__);
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection{
    NSLog(@"%s,line = %d object = %@",__FUNCTION__,__LINE__,peerConnection);
}

- (void)peerConnection:(nonnull RTCPeerConnection *)peerConnection didRemoveIceCandidates:(nonnull NSArray<RTCIceCandidate *> *)candidates {
    NSLog(@"%s,line = %d object = %@",__FUNCTION__,__LINE__,candidates);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged{
    NSLog(@"stateChanged = %ld",(long)stateChanged);
}
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceGatheringState:(RTCIceGatheringState)newState{
    NSLog(@"newState = %ld",newState);
}


#pragma mark -消息相关
-(void)peerConnection:(RTCPeerConnection *)peerConnection didOpenDataChannel:(RTCDataChannel *)dataChannel{
    
}

#pragma mark -视频分辨率代理
- (void)capturer:(nonnull RTCVideoCapturer *)capturer didCaptureVideoFrame:(nonnull RTCVideoFrame *)frame {
    
}
- (NSString *)getKeyFromConnectionDic:(RTCPeerConnection *)peerConnection
{
    //find socketid by pc
    static NSString *socketId;
    [_connectionDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, RTCPeerConnection *obj, BOOL * _Nonnull stop) {
        if ([obj isEqual:peerConnection])
        {
            ZWWLog(@"%@",key);
            socketId = key;
        }
    }];
    return socketId;
}
//根据外界传递过来的 信息,在本地做相应的处理
-(void)dealWithMessageWithModel:(NSString *)Model{
    ZWWLog(@"外界需要我做些什么事情呢? =%@",Model)
}
@end
