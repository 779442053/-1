//
//  MMChatMessageImageCell.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatMessageImageCell.h"

#import "MMMediaManager.h"
#import "MMFileTool.h"
#import "MMMessageHelper.h"
#import <UIButton+WebCache.h>

@interface MMChatMessageImageCell ()

@property (nonatomic, strong) UIButton *imageBtn;

@end


@implementation MMChatMessageImageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.imageBtn];
    }
    return self;
}


#pragma mark - Private Method

- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    [super setModelFrame:modelFrame];
    //自己发送的图片,可以在本地拿到图片的路径
    MMMediaManager *manager = [MMMediaManager sharedManager];
    UIImage *image = [manager imageWithLocalPath:[manager imagePathWithName:modelFrame.aMessage.slice.filePath.lastPathComponent]];
    self.imageBtn.frame = modelFrame.picViewF;
    self.bubbleView.userInteractionEnabled = _imageBtn.imageView.image != nil;
    self.bubbleView.image = nil;
    if (modelFrame.aMessage.isSender&&image) {    // 发送者
        ZWWLog(@"我是发送图片者")
        UIImage *arrowImage = [manager arrowMeImage:image size:modelFrame.picViewF.size mediaPath:modelFrame.aMessage.slice.filePath isSender:modelFrame.aMessage.isSender];
        [self.imageBtn setBackgroundImage:arrowImage forState:UIControlStateNormal];
    } else {//接受别人的图片,将图片裁剪成别人图片箭头的样子
//        [self.imageBtn sd_setImageWithURL:[NSURL URLWithString:modelFrame.aMessage.slice.content] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"zhaopian"]];
        NSData *iamgeData = [NSData dataWithContentsOfURL:[NSURL URLWithString:modelFrame.aMessage.slice.content]];
        UIImage *image = [UIImage imageWithData:iamgeData];
        [self.imageBtn setBackgroundImage:image forState:UIControlStateNormal];
    }
}

- (void)imageBtnClick:(UIButton *)btn
{
    if (btn.currentBackgroundImage == nil) {
        ZWWLog(@"点击的图片为空")
        return;
    }
    CGRect smallRect = [MMMessageHelper photoFramInWindow:btn];
    CGRect bigRect   = [MMMessageHelper photoLargerInWindow:btn];
    NSValue *smallValue = [NSValue valueWithCGRect:smallRect];
    NSValue *bigValue   = [NSValue valueWithCGRect:bigRect];
    [self routerEventWithName:GXRouterEventImageTapEventName
                     userInfo:@{MessageKey   : self.modelFrame,
                                @"smallRect" : smallValue,
                                @"bigRect"   : bigValue
                                }];
}



#pragma mark - Getter

- (UIButton *)imageBtn
{
    if (nil == _imageBtn) {
        _imageBtn = [[UIButton alloc] init];
        [_imageBtn addTarget:self action:@selector(imageBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        _imageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _imageBtn.layer.masksToBounds = YES;
        _imageBtn.layer.cornerRadius = 5;
        _imageBtn.clipsToBounds = YES;
    }
    return _imageBtn;
}


@end
