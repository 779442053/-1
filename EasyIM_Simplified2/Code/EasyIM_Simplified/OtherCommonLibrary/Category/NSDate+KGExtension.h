//
//  NSDate+KGExtension.h
//  deals
//
//  Created by  on 15/6/22.
//  Copyright (c) 2015年 yikang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (KGExtension)
- (NSString *)dy_MMdd;
- (NSString *)dy_yyyyMMdd;
- (NSString *)dy_yyyyMMddHHmmss;
- (NSString *)dy_yyyyMMddHHmm;
- (NSString *)dy_HHmm;
- (NSString *)dy_readable;

- (NSString *)dy_yyyy;
- (NSString *)dy_MM;
- (NSString *)dy_dd;

+ (NSDate *)dy_dateFromZone:(NSString *)dateString;
+ (NSDate *)dy_dateFromCST:(NSString *)dateString;

/**
 * 比较from和self的时间差值
 */
- (NSDateComponents *)deltaFrom:(NSDate *)from;

/**
 * 是否为今年
 */
- (BOOL)isThisYear;

/**
 * 是否为今天
 */
- (BOOL)isToday;

/**
 * 是否为昨天
 */
- (BOOL)isYesterday;

// 判断时间是今天/昨天
+ (NSString *)checkTheDate:(NSString *)string;

@end
