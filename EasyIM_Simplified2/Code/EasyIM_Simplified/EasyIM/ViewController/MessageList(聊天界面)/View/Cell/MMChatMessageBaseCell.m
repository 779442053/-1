//
//  MMChatMessageBaseCell.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatMessageBaseCell.h"
#import "MMMessageTopView.h"
#import "ZWUserModel.h"
@implementation MMChatMessageBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
        longRecognizer.minimumPressDuration = 0.8;//定义按的时间
        
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:longRecognizer];
    }
    return self;
}

#pragma mark - UI

- (void)setupUI {
    [self.contentView addSubview:self.bubbleView];
    [self.contentView addSubview:self.headImageView];
    [self.contentView addSubview:self.activityView];
    [self.contentView addSubview:self.retryButton];
    [self.contentView addSubview:self.nameLabel];
}

#pragma mark - Getter and Setter

- (MMHeadImageView *)headImageView {
    if (_headImageView == nil) {
        _headImageView = [[MMHeadImageView alloc] init];
        [_headImageView setColor:MMColor(219, 220, 220) bording:0.0];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headClicked:)];
        [_headImageView addGestureRecognizer:tapGes];
    }
    return _headImageView;
}

- (UIImageView *)bubbleView {
    if (_bubbleView == nil) {
        _bubbleView = [[UIImageView alloc] init];
    }
    return _bubbleView;
}

- (UIActivityIndicatorView *)activityView {
    if (_activityView == nil) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _activityView;
}

- (UIButton *)retryButton {
    if (_retryButton == nil) {
        _retryButton = [[UIButton alloc] init];
        [_retryButton setImage:[UIImage imageNamed:@"button_retry_comment"] forState:UIControlStateNormal];
        [_retryButton addTarget:self action:@selector(retryButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _retryButton;
}

- (UILabel *)nameLabel{
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        [_nameLabel setTextColor:[UIColor grayColor]];
        [_nameLabel setFont:[UIFont systemFontOfSize:13]];
        [_nameLabel setHidden:YES];
    }
    return _nameLabel;
}

#pragma mark - Respond Method

- (void)retryButtonClick:(UIButton *)btn {
    if ([self.longPressDelegate respondsToSelector:@selector(reSendMessage:)]) {
        [self.longPressDelegate reSendMessage:self];
    }
}

- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    _modelFrame = modelFrame;
    
    MMMessage *aMessage = modelFrame.aMessage;
    self.headImageView.frame     = modelFrame.headImageViewF;
    self.bubbleView.frame        = modelFrame.bubbleViewF;
    
    if (![modelFrame.aMessage.type isEqualToString:@"chat"]) {
        self.nameLabel.hidden = NO;
    }else{
        self.nameLabel.hidden = YES;
    }

    //MARK:发送者
    if (aMessage.isSender) {
        self.headImageView.tag   = [[ZWUserModel currentUser].userId integerValue];
        
        self.activityView.frame  = modelFrame.activityF;
        self.retryButton.frame   = modelFrame.retryButtonF;
        [self updateSendStatus:modelFrame.aMessage.deliveryState];
        [self.nameLabel setTextAlignment:NSTextAlignmentRight];
        [self.nameLabel setText:modelFrame.aMessage.fromUserName];
        if ([aMessage.slice.type isEqualToString:TypeFile] ||[aMessage.slice.type isEqualToString:TypePicText]) {
            self.bubbleView.image = [UIImage imageNamed:@"liaotianfile"];
        } else {
            self.bubbleView.image = [UIImage imageNamed:@"liaotianbeijing2"];
        }
        [self.headImageView.imageView sd_setImageWithURL:[NSURL URLWithString:[ZWUserModel currentUser].photoUrl] placeholderImage:[UIImage imageNamed:@"chat_manOnline_icon"]];
    }
    //MARK:接收者
    else {
        self.headImageView.tag   = [modelFrame.aMessage.fromID integerValue];
        
        self.retryButton.hidden  = YES;
        self.bubbleView.image    = [UIImage imageNamed:@"liaotianbeijing1"];
        [self.headImageView.imageView sd_setImageWithURL:[NSURL URLWithString:modelFrame.aMessage.fromPhoto] placeholderImage:[UIImage imageNamed:@"chat_manOnline_icon"]];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setText:modelFrame.aMessage.toUserName];
    }
}

- (void)headClicked:(UITapGestureRecognizer *)sender
{
    if (self.longPressDelegate && [self.longPressDelegate respondsToSelector:@selector(headImageClicked:)]) {
        NSString *strUserId = [NSString stringWithFormat:@"%ld",sender.view.tag];
        
        [self.longPressDelegate headImageClicked:strUserId];
    }
}

- (void)updateSendStatus:(MessageDeliveryState)status
{
    
    // 发送状态
    switch (status) {
        case MMMessageDeliveryState_Delivering:
        {
            [self.activityView setHidden:NO];
            [self.retryButton setHidden:YES];
            [self.activityView startAnimating];
        }
            break;
        case MMMessageDeliveryState_Delivered:
        {
            [self.activityView stopAnimating];
            [self.activityView setHidden:YES];
            [self.retryButton setHidden:YES];
        }
            break;
        case MMMessageDeliveryState_Failure:
        {
            [self.activityView stopAnimating];
            [self.activityView setHidden:YES];
            [self.retryButton setHidden:NO];
        }
            break;
        default:
            break;
    }

}

#pragma mark - longPress delegate

- (void)longPressRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    if (self.longPressDelegate && [self.longPressDelegate respondsToSelector:@selector(longPress:)]) {
        [self.longPressDelegate longPress:recognizer];
    }
}

@end
