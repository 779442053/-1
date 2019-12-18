//
//  MMChatMessageVideoCell.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatMessageVideoCell.h"

#import "UIImage+Extension.h"
#import "MMVideoManager.h"
#import "MMMediaManager.h"
#import "ZacharyPlayManager.h"
#import "ICAVPlayer.h"
#import "MMFileTool.h"

@interface MMChatMessageVideoCell ()

@property (nonatomic, strong) UIButton *imageBtn;

@property (nonatomic, strong) UIButton *topBtn;


@end

@implementation MMChatMessageVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imageBtn];
        [self.imageBtn addSubview:self.topBtn];
    }
    return self;
}

- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    [super setModelFrame:modelFrame];
    MMMediaManager *manager = [MMMediaManager sharedManager];
    
    NSString *path          = [[MMVideoManager shareManager] receiveVideoPathWithFileKey:[modelFrame.aMessage.slice.content.lastPathComponent stringByDeletingPathExtension]];
    UIImage *videoArrowImage = [manager videoConverPhotoWithVideoPath:path size:modelFrame.picViewF.size isSender:modelFrame.aMessage.isSender];
    
    self.imageBtn.frame = modelFrame.picViewF;
    self.bubbleView.userInteractionEnabled = videoArrowImage != nil;
    self.bubbleView.image = nil;
    [self.imageBtn setImage:videoArrowImage forState:UIControlStateNormal];
    self.topBtn.frame = CGRectMake(0, 0, _imageBtn.width, _imageBtn.height);
}



- (void)imageBtnClick:(UIButton *)btn
{
    __block NSString *path = [[MMVideoManager shareManager] videoPathForMP4:self.modelFrame.aMessage.slice.content];
    [self videoPlay:path];
}

- (void)videoPlay:(NSString *)path
{
    ICAVPlayer *player = [[ICAVPlayer alloc] initWithPlayerURL:[NSURL fileURLWithPath:path]];
    [player presentFromVideoView:self.imageBtn toContainer:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:YES completion:nil];
}

#pragma mark - videoPlay

- (void)firstPlay
{
    __block NSString *path = [[MMVideoManager shareManager] videoPathForMP4:self.modelFrame.aMessage.slice.content];
    if ([MMFileTool fileExistsAtPath:path]) {
        [self reloadStart];
        _topBtn.hidden = YES;
    }
}

-(void)reloadStart {
    __weak typeof(self) weakSelf=self;
    NSString *path = [[MMVideoManager shareManager] videoPathForMP4:self.modelFrame.aMessage.slice.content];
    [[ZacharyPlayManager sharedInstance] startWithLocalPath:path WithVideoBlock:^(UIImage *imageData, NSString *filePath,CGImageRef tpImage) {
        if ([filePath isEqualToString:path]) {
            [self.imageBtn setImage:imageData forState:UIControlStateNormal];
        }
    }];
    
    [[ZacharyPlayManager sharedInstance] reloadVideo:^(NSString *filePath) {
        MAIN(^{
            if ([filePath isEqualToString:path]) {
                [weakSelf reloadStart];
            }
        });
    } withFile:path];
}

-(void)stopVideo {
    _topBtn.hidden = NO;
    [[ZacharyPlayManager sharedInstance] cancelVideo:[[MMVideoManager shareManager] videoPathForMP4:self.modelFrame.aMessage.slice.content]];
}

-(void)dealloc {
    [[ZacharyPlayManager sharedInstance] cancelAllVideo];
}

#pragma mark - Getter

- (UIButton *)imageBtn
{
    if (nil == _imageBtn) {
        _imageBtn = [[UIButton alloc] init];
        [_imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _imageBtn.layer.masksToBounds = YES;
        _imageBtn.layer.cornerRadius = 5;
        _imageBtn.clipsToBounds = YES;
    }
    return _imageBtn;
}

- (UIButton *)topBtn
{
    if (!_topBtn) {
        _topBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_topBtn addTarget:self action:@selector(firstPlay) forControlEvents:UIControlEventTouchUpInside];
        _topBtn.layer.masksToBounds = YES;
        _topBtn.layer.cornerRadius = 5;
    }
    return _topBtn;
}


@end
