//
//  NSDate+KGExtension.m
//  deals
//
//  Created by  on 15/6/22.
//  Copyright (c) 2015年 yikang. All rights reserved.
//

#import "NSDate+KGExtension.h"

@implementation NSDate (KGExtension)
- (NSString *)dy_MMdd
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM.dd"];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_yyyyMMdd
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_yyyyMMddHHmmss
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_yyyyMMddHHmm
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_HHmm
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_yyyy {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_MM {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_dd {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    
    return [dateFormatter stringFromDate:self];
}

- (NSString *)dy_readable
{
    NSTimeInterval timeInterval = 0 - [self timeIntervalSinceNow];
    if (timeInterval < 60 * 30) {
        int minutes = timeInterval / 60;
        if (minutes <= 0) {
            minutes = 1;
        }
        return [NSString stringWithFormat:@"%d分钟前", minutes];
    } else if ([[self dy_yyyyMMdd] isEqualToString:[[NSDate date] dy_yyyyMMdd]]) {
        return [NSString stringWithFormat:@"今天%@", [self dy_HHmm]];
    } else {
        return [self dy_yyyyMMdd];
    }
}

+ (NSDate *)dy_dateFromZone:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss zzz yyyy"];
    return [dateFormatter dateFromString:dateString];
}

+ (NSDate *)dy_dateFromCST:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    [dateFormatter setDateFormat:@"EEE MMM dd HH:mm:ss 'CST' yyyy"];
    return [dateFormatter dateFromString:dateString];
}


- (NSDateComponents *)deltaFrom:(NSDate *)from
{
    // 日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // 比较时间
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    return [calendar components:unit fromDate:from toDate:self options:0];
}

- (BOOL)isThisYear
{
    // 日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger nowYear = [calendar component:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger selfYear = [calendar component:NSCalendarUnitYear fromDate:self];
    
    return nowYear == selfYear;
}

- (BOOL)isToday
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSString *nowString = [fmt stringFromDate:[NSDate date]];
    NSString *selfString = [fmt stringFromDate:self];
    
    return [nowString isEqualToString:selfString];
}

- (BOOL)isYesterday
{
    // 2014-12-31 23:59:59 -> 2014-12-31
    // 2015-01-01 00:00:01 -> 2015-01-01
    
    // 日期格式化类
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSDate *nowDate = [fmt dateFromString:[fmt stringFromDate:[NSDate date]]];
    NSDate *selfDate = [fmt dateFromString:[fmt stringFromDate:self]];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:selfDate toDate:nowDate options:0];
    
    return cmps.year == 0
    && cmps.month == 0
    && cmps.day == 1;
}

+ (NSString *)checkTheDate:(NSString *)string{
    
    NSDateFormatter *format = [[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [format dateFromString:string];
    BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:date];
    BOOL isYesterday = [[NSCalendar currentCalendar] isDateInYesterday:date];
    
    NSString *strDiff = nil;
    
    NSArray *str = [string componentsSeparatedByString:@" "];
    NSString *s0 = str[0];
    NSString *s1 = str[1];
    NSString *s3 = [s1 substringFromIndex:4];
    
    if(isToday) {
        strDiff= s3;
    }else if (isYesterday) {
        strDiff= [NSString stringWithFormat:@"昨天"];
    }else {
        strDiff = s0;
    }
    return strDiff;
}

@end
