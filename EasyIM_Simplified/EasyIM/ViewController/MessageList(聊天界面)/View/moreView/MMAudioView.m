//
//  MMAudioView.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMAudioView.h"
#import "MMRecordManager.h"

@interface MMAudioView ()<AVAudioPlayerDelegate,MMRecordManagerDelegate>
{
    UILabel * _nameLabel;
    UILabel * _endTimeLabel;
    AVAudioPlayer *_player;
    NSTimer * _timer;
    UIProgressView * _progressV;
    UIButton * _playBtn;
}

@end
@implementation MMAudioView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setSubView:frame];
    }
    return self;
}


- (void)setSubView:(CGRect)frame
{
    UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iconfont-luyin"]];
    imageV.frame = CGRectMake(150, 105, 99, 143);
    imageV.centerX = frame.size.width*0.5;
    [self addSubview:imageV];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, imageV.bottom+27, 250, 20)];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    nameLabel.centerX = frame.size.width*0.5;
    nameLabel.font    = [UIFont systemFontOfSize:15.0];
    nameLabel.textColor = MMRGB(0x535f62);
    nameLabel.text    = _audioName;
    [self addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-kaishianniu"] forState:UIControlStateNormal];
    playBtn.frame = CGRectMake(25,nameLabel.bottom+200, 50, 50);
    [self addSubview:playBtn];
    [playBtn addTarget:self action:@selector(beginPlay:) forControlEvents:UIControlEventTouchUpInside];
    _playBtn = playBtn;
    /*
     UISlider * slider = [[UISlider alloc] initWithFrame:CGRectMake(playBtn.right+16, playBtn.top, frame.size.width-playBtn.right-16-25, 10)];
     slider.centerY = playBtn.centerY;
     slider.thumbTintColor = IColor(13, 103, 135);
     slider.minimumTrackTintColor = IColor(13, 103, 135);
     slider.value = 0.5;
     [self addSubview:slider];
     */
    UIProgressView *progressV = [[UIProgressView alloc] initWithFrame:CGRectMake(playBtn.right+16, playBtn.top, frame.size.width-playBtn.right-16-25, 10)];
    progressV.centerY = playBtn.centerY;
    progressV.progressTintColor =  MMColor(13, 103, 135);
    [self addSubview:progressV];
    _progressV = progressV;
    
    UILabel * endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(progressV.right-100, progressV.bottom+14, 100, 20)];
    endTimeLabel.textAlignment = NSTextAlignmentRight;
    endTimeLabel.font = [UIFont systemFontOfSize:14.0];
    endTimeLabel.textColor = MMRGB(0x535f62);
    [self addSubview:endTimeLabel];
    _endTimeLabel = endTimeLabel;
    
}

- (void)setAudioName:(NSString *)audioName
{
    _audioName = audioName;
    _nameLabel.text = audioName;
}

- (void)setAudioPath:(NSString *)audioPath
{
    _audioPath = audioPath;
    NSUInteger durataion = [[MMRecordManager shareManager] durationWithVideo:[NSURL fileURLWithPath:audioPath]];
    _endTimeLabel.text = [MMMessageHelper timeDurationFormatter:durataion];
}

- (void)beginPlay:(UIButton *)playBtn
{
    MMRecordManager *manager = [MMRecordManager shareManager];
    if (manager.player == nil) {
        [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-zhanting"] forState:UIControlStateNormal];
        manager.playDelegate = self;
        [manager startPlayRecorder:_audioPath];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                                selector:@selector(playProgress)
                                                userInfo:nil repeats:YES];
    } else if ([manager.player isPlaying]) {
        [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-kaishianniu"] forState:UIControlStateNormal];
        [manager pause];
        [_timer setFireDate:[NSDate distantFuture]];
    } else {
        [playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-zhanting"] forState:UIControlStateNormal];
        [manager.player play];
        [_timer setFireDate:[NSDate date]];
    }
    
}

- (void)playProgress
{
    MMRecordManager *manager = [MMRecordManager shareManager];
    _progressV.progress = [[manager player] currentTime]/[[manager player]duration];
}

- (void)timerInvalid
{
    [_timer invalidate];
    _timer = nil;
}

#pragma mark - delegate
// 释放
- (void)voiceDidPlayFinished
{
    [self timerInvalid];
    [[MMRecordManager shareManager] stopPlayRecorder:_audioPath];
    MMRecordManager *manager = [MMRecordManager shareManager];
    [manager stopPlayRecorder:_audioPath];
    manager.playDelegate = nil;
    [_playBtn setBackgroundImage:[UIImage imageNamed:@"iconfont-kaishianniu"] forState:UIControlStateNormal];
}

- (void)releaseTimer
{
    [self timerInvalid];
}

- (void)dealloc
{
    MMRecordManager *manager = [MMRecordManager shareManager];
    [manager stopPlayRecorder:_audioPath];
    manager.playDelegate = nil;
    [self timerInvalid];
}

@end
