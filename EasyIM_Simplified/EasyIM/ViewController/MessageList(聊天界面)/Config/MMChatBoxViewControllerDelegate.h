
//
//  MMChatBoxViewControllerDelegate.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMChatBoxViewController;
@class MMVideoView;

@protocol MMChatBoxViewControllerDelegate <NSObject>

@optional
// change chatBox height
- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
        didChangeChatBoxHeight:(CGFloat)height;
/**
 *  send 文字 message
 *
 *  @param chatboxViewController chatboxViewController
 *  @param messageStr            text
 */
- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
               sendTextMessage:(NSString *_Nullable)messageStr;
/**
 *  send 图片 message
 *
 *  @param chatboxViewController MMChatBoxViewController
 *  @param image                 image
 *  @param imgPath               image path
 */
- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
              sendImageMessage:(UIImage *_Nullable)image
                     imagePath:(NSString *_Nullable)imgPath;

/**
 *  send 语音 message
 *
 *  @param chatboxViewController MMChatBoxViewController
 *  @param voicePath             voice path
 */
- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
              sendVoiceMessage:(NSString *_Nullable)voicePath;


/**
 发送联系人(名片)信息

 @param chatboxViewController MMChatBoxViewController
 @param strUserId 联系人编号
 @param uName 用户名
 @param nName 昵称
 @param strPurl 图像
 */
- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
            sendLinkmanMessage:(NSString *_Nonnull)strUserId
                   AndUserName:(NSString *_Nonnull)uName
                   AndNickname:(NSString *_Nullable)nName
                      AndPhoto:(NSString *_Nullable)strPurl;

- (void) voiceDidStartRecording;
// voice太短
- (void) voiceRecordSoShort;

- (void) voiceWillDragout:(BOOL)inside;

- (void) voiceDidCancelRecording;


- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
          didVideoViewAppeared:(MMVideoView *_Nullable)videoView;

- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
              sendVideoMessage:(NSString *_Nullable)videoPath;

- (void) chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController
               sendFileMessage:(NSString *_Nullable)fileName;
//发送位置信息
- (void)chatBoxViewController:(MMChatBoxViewController *_Nullable)chatboxViewController sendLocation:(CLLocationCoordinate2D)locationCoordinate locationText:(NSString *_Nullable)locationText;


@end
