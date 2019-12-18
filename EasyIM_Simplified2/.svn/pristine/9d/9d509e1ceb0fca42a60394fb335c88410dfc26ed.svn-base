//
//  MMRecordManagerDelegate.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define shortRecord @"shortRecord"

@protocol MMRecordManagerDelegate <NSObject>

// voice play finished
- (void)voiceDidPlayFinished;

@end

@interface MMRecordManager : NSObject<AVAudioRecorderDelegate,AVAudioPlayerDelegate>

@property (nonatomic, weak)id <MMRecordManagerDelegate>playDelegate;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) AVAudioPlayer *player;

+ (id)shareManager;

// start recording
- (void)startRecordingWithFileName:(NSString *)fileName
                        completion:(void(^)(NSError *error))completion;
// stop recording
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

// 是否拥有权限
- (BOOL)canRecord;

// 取消当前录制
- (void)cancelCurrentRecording;

- (void)removeCurrentRecordFile:(NSString *)fileName;

/*********-------播放----------************/

- (void)startPlayRecorder:(NSString *)recorderPath;

- (void)stopPlayRecorder:(NSString *)recorderPath;

- (void)pause;

// 录音文件主路径
- (NSString *)recorderMainPath;

// 接收到的语音保存路径(文件以fileKey为名字)
- (NSString *)receiveVoicePathWithFileKey:(NSString *)fileKey;

// 获取语音时长
- (NSUInteger)durationWithVideo:(NSURL *)voiceUrl;


@end

NS_ASSUME_NONNULL_END
