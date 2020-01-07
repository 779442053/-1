//
//  MMCallSessionModel.h
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMVedioCallEnum.h"
NS_ASSUME_NONNULL_BEGIN

@interface MMCallSessionModel : NSObject

@property (nonatomic, copy) NSString *fromId;
@property (nonatomic, copy) NSString *toId;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *webrtcId;
@property (nonatomic, copy) NSString *startId;
@property (nonatomic, copy) NSString *timeStamp;

@property (nonatomic, copy) NSString *fromName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *fromPhoto;

@property (nonatomic, assign) NSInteger result;//0 呼叫失败，1呼叫成功
@property (nonatomic, assign) NSInteger callType;
@property (nonatomic, assign) MMCallParty callParty;//主叫和被叫
@property (nonatomic, assign) NSInteger toStatus;
@property (nonatomic, assign) NSInteger toCallStatus;
@property (nonatomic) MMCallStatus callStatus;//呼叫状态(与服务器相对应)

@end

NS_ASSUME_NONNULL_END
