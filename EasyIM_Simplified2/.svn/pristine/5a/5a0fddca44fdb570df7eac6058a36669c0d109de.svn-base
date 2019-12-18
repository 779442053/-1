//
//  MMVedioCallManager.h
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMVedioCallManager : NSObject

+ (instancetype)sharedManager;

//挂断
- (void)endCallWithId:(NSString *)aCallId
             callType:(NSInteger)callType
             webrtcId:(NSString *)webrtcId
         isNeedHangup:(BOOL)aIsNeedHangup;

//拒绝
- (void)refuseCallWithId:(NSString *)aCallId
             callType:(NSInteger)callType
             webrtcId:(NSString *)webrtcId;

- (void)stopCallTimeoutTimer;

@end

NS_ASSUME_NONNULL_END
