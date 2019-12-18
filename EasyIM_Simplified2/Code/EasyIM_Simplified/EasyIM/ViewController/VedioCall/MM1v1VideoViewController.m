//
//  MM1v1VideoViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/8.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MM1v1VideoViewController.h"

#import "MMButton.h"


@interface MM1v1VideoViewController ()

@property (nonatomic, strong) MMButton *switchCameraButton;

@end

@implementation MM1v1VideoViewController

@synthesize callStatus = _callStatus;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubviews];
    if (!isHeadphone()) {
        [self speakerButtonAction];
    }

}

#pragma mark - Subviews

- (void)setupSubviews
{
    CGFloat color = 51 / 255.0;
    self.view.backgroundColor = [UIColor colorWithRed:color green:color blue:color alpha:1.0];
    
    self.statusLabel.textColor = [UIColor whiteColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.remoteNameLabel.textColor = [UIColor whiteColor];
    
    CGFloat width = 80;
    CGFloat height = 50;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - width * 3) / 4;
    
    self.switchCameraButton = [[MMButton alloc] initWithTitle:@"切换摄像头" target:self action:@selector(switchCameraButtonAction:)];
    [self.switchCameraButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.switchCameraButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_white"] forState:UIControlStateNormal];
    [self.switchCameraButton setImage:[UIImage imageNamed:@"switchCamera_gray"] forState:UIControlStateSelected];
    [self.view addSubview:self.switchCameraButton];
    [self.switchCameraButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
    }];
    
    [self.microphoneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.microphoneButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_white"] forState:UIControlStateNormal];
    [self.microphoneButton setImage:[UIImage imageNamed:@"micphone_gray"] forState:UIControlStateSelected];
    [self.microphoneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchCameraButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [self.speakerButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.speakerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_gray"] forState:UIControlStateNormal];
    [self.speakerButton setImage:[UIImage imageNamed:@"speaker_white"] forState:UIControlStateSelected];
    [self.speakerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.microphoneButton.mas_right).offset(padding);
        make.bottom.equalTo(self.switchCameraButton);
    }];
    
    [@[self.switchCameraButton, self.microphoneButton, self.speakerButton] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
        make.height.mas_equalTo(height);
    }];
    
}

#pragma mark - Action

- (void)switchCameraButtonAction:(UIButton *)sender
{
    //切换摄像头
     [self.avConf switchCamera];
}

#pragma mark - Super Public

- (void)setCallStatus:(MMCallStatus)callStatus
{
    [super setCallStatus:callStatus];
    
    if (callStatus == MMCallStatus_talkIng) {
//        if (!self.callSession.remoteVideoView) {
//            [self _setupRemoteVideoView];
//        }
    }
}

- (void)minimizeAction
{
    MMLog(@"%@",@"最小化");
}


@end
