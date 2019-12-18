//
//  MMCallViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

//Helper
#import "MMButton.h"

NS_ASSUME_NONNULL_BEGIN

static bool isHeadphone()
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([desc.portType isEqualToString:AVAudioSessionPortBluetoothA2DP]
            || [desc.portType isEqualToString:AVAudioSessionPortHeadphones]
            || [desc.portType isEqualToString:AVAudioSessionPortBluetoothLE]
            || [desc.portType isEqualToString:AVAudioSessionPortBluetoothHFP]) {
            return YES;
        }
    }
    
    return NO;
}


@interface MMCallViewController : UIViewController

@property (nonatomic, strong) UILabel *statusLabel;//连接状态

@property (nonatomic, strong) MMButton *microphoneButton;//静音
@property (nonatomic, strong) MMButton *speakerButton;//扬声器

@property (nonatomic, strong) UIButton *hangupButton;//挂断
@property (nonatomic, strong) UIButton *minButton;//最小化

// Button Action

- (void)microphoneButtonAction;

- (void)speakerButtonAction;

- (void)minimizeAction;

- (void)hangupAction;

@end

NS_ASSUME_NONNULL_END
