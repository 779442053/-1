//
//  MMMessageHelper.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MMMessageFrame;
@class MMChatContentModel;
@class MMReceiveMessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface MMMessageHelper : NSObject


+ (CGFloat)getVoiceTimeLengthWithPath:(NSString *)path;


// 坐标转换到窗口中的位置
+ (CGRect)photoFramInWindow:(UIButton *)photoView;

// 放大后的图片按钮在窗口中的位置
+ (CGRect)photoLargerInWindow:(UIButton *)photoView;

// 根据消息类型得到cell的标识
+ (NSString *)cellTypeWithMessageType:(NSString *)type;


// time format
+ (NSString *)timeFormatWithDate:(NSInteger)time;
+ (NSString *)timeFormatWithDate2:(NSInteger)time;

+ (NSNumber *)fileType:(NSString *)type;
+ (UIImage *)allocationImage:(MMFileType)type;

+ (NSString *)timeDurationFormatter:(NSUInteger)duration;

/// 当前时间
+ (NSInteger)currentMessageTime;

@end

NS_ASSUME_NONNULL_END
