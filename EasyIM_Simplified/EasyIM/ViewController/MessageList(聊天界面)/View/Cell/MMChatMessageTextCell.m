//
//  MMChatMessageTextCell.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatMessageTextCell.h"

#import "MMFaceManager.h"
#import "YJProgressHUD.h"

@implementation MMChatMessageTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.chatLabel];
        __weak typeof(self) weadSelf = self;
        _chatLabel.urlLinkTapHandler = ^(KILabel *label, NSString *string, NSRange range) {
            [weadSelf urlSkip:[NSURL URLWithString:string]];
        };
    }
    return self;
}




#pragma mark - Private Method


- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    [super setModelFrame:modelFrame];
    
    self.chatLabel.frame = modelFrame.chatLabelF;
    self.nameLabel.frame = modelFrame.nameLabelF;
    if (modelFrame.aMessage.slice.content.length) {
        [self.chatLabel setAttributedText:[MMFaceManager transferMessageString:modelFrame.aMessage.slice.content font:self.chatLabel.font lineHeight:self.chatLabel.font.lineHeight]];
    }
    //    self.chatLabel.text = modelFrame.model.content;
}
- (void)attemptOpenURL:(NSURL *)url
{
    BOOL safariCompatible = [url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"];
    if (safariCompatible && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        [YJProgressHUD showError:@"您的链接无效"];
    }
}
- (void)urlSkip:(NSURL *)url
{
    [self routerEventWithName:GXRouterEventURLSkip
                     userInfo:@{@"url"   : url
                                }];
}
- (KILabel *)chatLabel
{
    if (nil == _chatLabel) {
        _chatLabel = [[KILabel alloc] init];
        _chatLabel.numberOfLines = 0;
        _chatLabel.font = MessageFont;
        _chatLabel.textColor = ICRGB(0x282724);
    }
    return _chatLabel;
}
@end
