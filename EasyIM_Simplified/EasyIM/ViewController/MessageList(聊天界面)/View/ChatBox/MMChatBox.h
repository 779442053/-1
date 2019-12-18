//
//  MMChatBox.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMChatConst.h"

NS_ASSUME_NONNULL_BEGIN

@class MMChatBox;
@protocol MMChatBoxDelegate <NSObject>
/**
 *  输入框状态(位置)改变
 *
 *  @param chatBox    chatBox
 *  @param fromStatus 起始状态
 *  @param toStatus   目的状态
 */
- (void)chatBox:(MMChatBox *)chatBox changeStatusForm:(MMChatBoxStatus)fromStatus to:(MMChatBoxStatus)toStatus;

/**
 *  发送消息
 *
 *  @param chatBox     chatBox
 *  @param textMessage 消息
 */
- (void)chatBox:(MMChatBox *)chatBox sendTextMessage:(NSString *)textMessage;

/**
 *  输入框高度改变
 *
 *  @param chatBox chatBox
 *  @param height  height
 */
- (void)chatBox:(MMChatBox *)chatBox changeChatBoxHeight:(CGFloat)height;

/**
 *  开始录音
 *
 *  @param chatBox chatBox
 */
- (void)chatBoxDidStartRecordingVoice:(MMChatBox *)chatBox;
- (void)chatBoxDidStopRecordingVoice:(MMChatBox *)chatBox;
- (void)chatBoxDidCancelRecordingVoice:(MMChatBox *)chatBox;
- (void)chatBoxDidDrag:(BOOL)inside;


@end

@interface MMChatBox : UIView

/** 保存状态 */
@property (nonatomic, assign) MMChatBoxStatus status;

@property (nonatomic, weak) id<MMChatBoxDelegate>delegate;

/** 输入框 */
@property (nonatomic, strong) UITextView *textView;


@end

NS_ASSUME_NONNULL_END
