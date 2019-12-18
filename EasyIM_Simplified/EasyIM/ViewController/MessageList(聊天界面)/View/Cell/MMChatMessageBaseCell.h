//
//  MMChatMessageBaseCell.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMMessageFrame.h"
#import "UIResponder+GXRouter.h"
#import "MMMessageConst.h"
#import "MMHeadImageView.h"


NS_ASSUME_NONNULL_BEGIN

@class MMChatMessageBaseCell;

@protocol BaseCellDelegate <NSObject>

- (void)longPress:(UILongPressGestureRecognizer *)longRecognizer;

@optional
/**
 * 消息图像点击
 * @param eId 当前消息用户Id
 */
- (void)headImageClicked:(NSString *)eId;

- (void)reSendMessage:(MMChatMessageBaseCell *)baseCell;

@end


@interface MMChatMessageBaseCell : UITableViewCell

@property (nonatomic, weak) id<BaseCellDelegate> longPressDelegate;

// 消息模型
@property (nonatomic, strong) MMMessageFrame *modelFrame;
// 头像
@property (nonatomic, strong) MMHeadImageView *headImageView;
// 内容气泡视图
@property (nonatomic, strong) UIImageView *bubbleView;
// 菊花视图所在的view
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
// 重新发送
@property (nonatomic, strong) UIButton *retryButton;
// 昵称显示
@property (nonatomic, strong) UILabel *nameLabel;

- (void)updateSendStatus:(MessageDeliveryState)status;

@end

NS_ASSUME_NONNULL_END
