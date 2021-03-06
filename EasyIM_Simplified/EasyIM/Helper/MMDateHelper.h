//
//  MMDateHelper.h
//  EasyIM
//
//  Created by momo on 2019/4/18.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

#define D_MINUTE    60
#define D_HOUR      3600
#define D_DAY       86400
#define D_WEEK      604800
#define D_YEAR      31556926

NS_ASSUME_NONNULL_BEGIN

@interface MMDateHelper : NSObject

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)aMilliSecond;

+ (NSString *)formattedTimeFromTimeInterval:(NSString *)aTimeInterval;

+ (NSString *)formattedTime:(NSDate *)aDate;

+ (NSString *)getNowTime;

+ (NSString *)getMessageNowTime;
+ (NSString *)getExpectTimestamp:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day date:(NSDate *)currentDate;

@end

NS_ASSUME_NONNULL_END
