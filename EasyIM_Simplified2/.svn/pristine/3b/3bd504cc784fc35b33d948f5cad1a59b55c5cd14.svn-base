//
//  MMRecentConVersationModel.h
//  EasyIM
//
//  Created by momo on 2019/5/14.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMRecentConVersationModel : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) long long latestMsgTimeStamp;
@property (nonatomic, copy) NSString *imageStr;
@property (nonatomic, copy) NSString *latestMsgStr;
@property (nonatomic, assign) NSInteger unReadCount;

- (instancetype)initWithMessageModel:(MMMessage *)message conversationId:(NSString *)conversationId;
- (void)setLatestMessage:(MMMessage *)latestMessage;

+ (NSString *)getMessageStrWithMessage:(MMMessage *)message;
+ (MMMessageType)getMessageType:(NSString *)type;

@end

NS_ASSUME_NONNULL_END
