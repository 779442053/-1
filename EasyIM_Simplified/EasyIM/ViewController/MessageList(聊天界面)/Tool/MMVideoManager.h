//
//  MMVideoManager.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^RecordingFinished)(NSString *path);

@interface MMVideoManager : NSObject

+ (instancetype)shareManager;

- (void)setVideoPreviewLayer:(UIView *)videoLayerView;


- (void)startRecordingVideoWithFileName:(NSString *)videoName;

// 录制权限
- (BOOL)canRecordViedo;

// stop recording
- (void)stopRecordingVideo:(RecordingFinished)finished;

- (void)cancelRecordingVideoWithFileName:(NSString *)videoName;

// 退出
- (void)exit;

// 接收到的视频保存路径(文件以fileKey为名字)
- (NSString *)receiveVideoPathWithFileKey:(NSString *)fileKey;

- (NSString *)videoPathWithFileName:(NSString *)videoName;

- (NSString *)videoPathForMP4:(NSString *)namePath;
// 自定义路径
- (NSString *)videoPathWithFileName:(NSString *)videoName fileDir:(NSString *)fileDir;

@end

NS_ASSUME_NONNULL_END
