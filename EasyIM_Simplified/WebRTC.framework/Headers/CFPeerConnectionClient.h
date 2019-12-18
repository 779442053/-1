//
/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2018 Piasy
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
//


#import <Foundation/Foundation.h>

#import "RTCMacros.h"

@class RTCIceCandidate;
@class RTCIceServer;
@class RTCLegacyStatsReport;
@class RTCSessionDescription;
@class RTCVideoCapturer;
@class RTCVideoSource;
@protocol RTCVideoRenderer;

@class CFPeerConnectionFactoryOption;

#define CF_PC_CLIENT_VERSION "1.0.1-25821"

typedef NS_ENUM(NSInteger, CFPeerConnectionDir) {
    CF_DIR_INACTIVE = 0,
    CF_DIR_RECV_ONLY = 1,
    CF_DIR_SEND_ONLY = 2,
    CF_DIR_SEND_RECV = 3,
};

typedef NS_ENUM(NSInteger, CFPeerConnectionError) {
    ERR_NO_FACTORY = 1000,
    ERR_NO_SENDING_TRACK = 1001,
    ERR_CREATE_PC_FAIL = 1002,
    ERR_ICE_FAIL = 1003,
    ERR_CREATE_MULTIPLE_SDP = 1004,
    ERR_CREATE_SDP_FAIL = 1005,
    ERR_SET_SDP_FAIL = 1006,
};

RTC_OBJC_EXPORT
@protocol CFPeerConnectionClientDelegate<NSObject>

- (void)onLocalDescription:(NSString*)peerUid
                  localSdp:(RTCSessionDescription*)localSdp;

- (void)onIceCandidate:(NSString*)peerUid candidate:(RTCIceCandidate*)candidate;

- (void)onIceCandidatesRemoved:(NSString*)peerUid
                    candidates:(NSArray<RTCIceCandidate*>*)candidates;

- (void)onPeerConnectionStatsReady:(NSString*)peerUid
                           reports:(NSArray<RTCLegacyStatsReport*>*)reports;

- (void)onIceConnected:(NSString*)peerUid;

- (void)onIceDisconnected:(NSString*)peerUid;

- (void)onError:(NSString*)peerUid code:(CFPeerConnectionError)code;
@end

RTC_OBJC_EXPORT
@interface CFPeerConnectionClient : NSObject

+ (int32_t)initialize:(bool)debug;

+ (bool)send:(CFPeerConnectionDir)dir;
+ (bool)receive:(CFPeerConnectionDir)dir;
+ (int32_t)createPeerConnectionFactory:
    (CFPeerConnectionFactoryOption*)factoryOption;

+ (int32_t)createLocalSources:(bool)hasVideo isScreencast:(bool)isScreencast;
+ (RTCVideoSource*)getLocalVideoSource;

+ (int32_t)createLocalTracks:(id<RTCVideoRenderer>)preview
                     preload:(bool)preload;

+ (int32_t)destroyPeerConnectionFactory;


- (instancetype)initWithUid:(NSString*)uid
                        dir:(CFPeerConnectionDir)dir
                   hasVideo:(bool)hasVideo
                   delegate:(id<CFPeerConnectionClientDelegate>)delegate
        remoteTrackRenderer:(id<RTCVideoRenderer>)remoteTrackRenderer
                    preload:(bool)preload
               startBitrate:(int32_t)startBitrate;

- (void)createPeerConnection:(NSArray<RTCIceServer*>*)iceServers;

- (void)finishPreload;

- (void)enableStatsEvents:(bool)enable periodMs:(int32_t)periodMs;

- (void)setAudioSendingEnabled:(bool)enable;
- (void)setVideoSendingEnabled:(bool)enable;
- (void)setAudioReceivingEnabled:(bool)enable;
- (void)setVideoReceivingEnabled:(bool)enable;

- (void)createOffer;
- (void)createAnswer;

- (void)addIceCandidate:(RTCIceCandidate*)candidate;
- (void)removeIceCandidates:(NSArray<RTCIceCandidate*>*)candidates;

- (void)setRemoteDescription:(RTCSessionDescription*)sdp;

- (bool)send;
- (bool)receive;

- (bool)statsEnabled;

- (void)close;

@end
