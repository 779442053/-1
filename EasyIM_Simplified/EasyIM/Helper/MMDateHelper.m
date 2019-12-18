//
//  MMDateHelper.m
//  EasyIM
//
//  Created by momo on 2019/4/18.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMDateHelper.h"

#define DATE_COMPONENTS (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)

#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@interface MMDateHelper ()

@property (nonatomic, strong) NSDateFormatter *dfYMD;
@property (nonatomic, strong) NSDateFormatter *dfHM;
@property (nonatomic, strong) NSDateFormatter *dfYMDHM;
@property (nonatomic, strong) NSDateFormatter *dfYesterdayHM;

@property (nonatomic, strong) NSDateFormatter *dfBeforeDawnHM;
@property (nonatomic, strong) NSDateFormatter *dfAAHM;
@property (nonatomic, strong) NSDateFormatter *dfPPHM;
@property (nonatomic, strong) NSDateFormatter *dfNightHM;
@end

static MMDateHelper *shared = nil;
@implementation MMDateHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MMDateHelper alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

#pragma mark - Getter

- (NSDateFormatter *)_getDateFormatterWithFormat:(NSString *)aFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = aFormat;
    return dateFormatter;
}

- (NSDateFormatter *)dfYMD
{
    if (_dfYMD == nil) {
        _dfYMD = [self _getDateFormatterWithFormat:@"YYYY/MM/dd"];
    }
    
    return _dfYMD;
}

- (NSDateFormatter *)dfHM
{
    if (_dfHM == nil) {
        _dfHM = [self _getDateFormatterWithFormat:@"HH:mm"];
    }
    
    return _dfHM;
}

- (NSDateFormatter *)dfYMDHM
{
    if (_dfYMDHM == nil) {
        _dfYMDHM = [self _getDateFormatterWithFormat:@"yyyy/MM/dd HH:mm"];
    }
    
    return _dfYMDHM;
}

- (NSDateFormatter *)dfYesterdayHM
{
    if (_dfYesterdayHM == nil) {
        _dfYesterdayHM = [self _getDateFormatterWithFormat:@"昨天HH:mm"];
    }
    
    return _dfYesterdayHM;
}

- (NSDateFormatter *)dfBeforeDawnHM
{
    if (_dfBeforeDawnHM == nil) {
        _dfBeforeDawnHM = [self _getDateFormatterWithFormat:@"凌晨hh:mm"];
    }
    
    return _dfBeforeDawnHM;
}

- (NSDateFormatter *)dfAAHM
{
    if (_dfAAHM == nil) {
        _dfAAHM = [self _getDateFormatterWithFormat:@"上午hh:mm"];
    }
    
    return _dfAAHM;
}

- (NSDateFormatter *)dfPPHM
{
    if (_dfPPHM == nil) {
        _dfPPHM = [self _getDateFormatterWithFormat:@"下午hh:mm"];
    }
    
    return _dfPPHM;
}

- (NSDateFormatter *)dfNightHM
{
    if (_dfNightHM == nil) {
        _dfNightHM = [self _getDateFormatterWithFormat:@"晚上hh:mm"];
    }
    
    return _dfNightHM;
}

#pragma mark - Class Methods

+ (NSDate *)dateWithTimeIntervalInMilliSecondSince1970:(double)aMilliSecond
{
    double timeInterval = aMilliSecond;
    // judge if the argument is in secconds(for former data structure).
    if(aMilliSecond > 140000000000) {
        timeInterval = aMilliSecond / 1000;
    }
    NSDate *ret = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    
    return ret;
}

+ (NSString *)formattedTimeFromTimeInterval:(NSString *)aTimeInterval
{
    long long time = [aTimeInterval longLongValue];
    NSDate *date = [MMDateHelper dateWithTimeIntervalInMilliSecondSince1970:time];
    return [MMDateHelper formattedTime:date];
}

+ (NSString *)formattedTime:(NSDate *)aDate
{
    MMDateHelper *helper = [MMDateHelper shareHelper];
    
    NSString *dateNow = [helper.dfYMD stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8, 2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5, 2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0, 4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:components];
    
    NSInteger hour = [MMDateHelper hoursFromDate:aDate toDate:date];
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    
    //If hasAMPM==TURE, use 12-hour clock, otherwise use 24-hour clock
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    if (!hasAMPM) { //24-hour clock
        if (hour <= 24 && hour >= 0) {
            dateFormatter = helper.dfHM;
        } else if (hour < 0 && hour >= -24) {
            dateFormatter = helper.dfYesterdayHM;
        } else {
            dateFormatter = helper.dfYMDHM;
        }
    } else {
        if (hour >= 0 && hour <= 6) {
            dateFormatter = helper.dfBeforeDawnHM;
        } else if (hour > 6 && hour <= 11 ) {
            dateFormatter = helper.dfAAHM;
        } else if (hour > 11 && hour <= 17) {
            dateFormatter = helper.dfPPHM;
        } else if (hour > 17 && hour <= 24) {
            dateFormatter = helper.dfNightHM;
        } else if (hour < 0 && hour >= -24) {
            dateFormatter = helper.dfYesterdayHM;
        } else {
            dateFormatter = helper.dfYMDHM;
        }
    }
    
    ret = [dateFormatter stringFromDate:aDate];
    return ret;
}

#pragma mark --- 获取当前时间戳---10位
+ (NSString *)getNowTime
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *timeSp = [NSString stringWithFormat:@"%.0f", time];
    return timeSp;
}

#pragma mark Retrieving Intervals

+ (NSInteger)hoursFromDate:(NSDate *)aFromDate
                    toDate:(NSDate *)aToDate
{
    NSTimeInterval ti = [aFromDate timeIntervalSinceDate:aToDate];
    return (NSInteger) (ti / D_HOUR);
}


///< 获取当前时间的: 前一周(day:-7)丶前一个月(month:-30)丶前一年(year:-1)的时间戳
+ (NSString *)getExpectTimestamp:(NSInteger)year month:(NSUInteger)month day:(NSUInteger)day date:(NSDate *)currentDate{
    
//    /< 当前时间
//    NSDate *currentdata = [NSDate date];
    
    ///< NSCalendar -- 日历类，它提供了大部分的日期计算接口，并且允许您在NSDate和NSDateComponents之间转换
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    /*
     ///<  NSDateComponents：时间容器，一个包含了详细的年月日时分秒的容器。
     ///< 下例：获取指定日期的年，月，日
     NSDateComponents *comps = nil;
     comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentdata];
     NSLog(@"年 year = %ld",comps.year);
     NSLog(@"月 month = %ld",comps.month);
     NSLog(@"日 day = %ld",comps.day);*/
    
    
    NSDateComponents *datecomps = [[NSDateComponents alloc] init];
    [datecomps setYear:year?:0];
    [datecomps setMonth:month?:0];
    [datecomps setDay:day?:0];
    
    ///< dateByAddingComponents: 在参数date基础上，增加一个NSDateComponents类型的时间增量
    NSDate *calculatedate = [calendar dateByAddingComponents:datecomps toDate:currentDate options:0];
    
    ///< 打印推算时间
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd_hh:mm:ss"];
    NSString *calculateStr = [formatter stringFromDate:calculatedate];
    
    DDLog(@"calculateStr 推算时间: %@",calculateStr );
    
    ///< 预期的推算时间
//    NSString *result = [NSString stringWithFormat:@"%ld", (long)[calculatedate timeIntervalSince1970]];
    
    return calculateStr;
}
+ (NSString *)getMessageNowTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyMMdd-HHmmss"];
    NSDate *currentdata = [NSDate date];
    NSString *calculateStr = [formatter stringFromDate:currentdata];
    ZWWLog(@"当前消息时间格式=%@",calculateStr)
    return calculateStr;
}

@end
