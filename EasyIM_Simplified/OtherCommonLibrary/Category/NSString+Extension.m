//
//  NSString+Extension.m
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/9/27.
//  Copyright © 2016年 gxz. All rights reserved.
//

#import "NSString+Extension.h"

#define EmojiCodeToSymbol(c) ((((0x808080F0 | (c & 0x3F000) >> 4) | (c & 0xFC0) << 10) | (c & 0x1C0000) << 18) | (c & 0x3F) << 24)

@implementation NSString (Extension)

- (NSString *)emoji
{
    return [NSString emojiWithStringCode:self];
}

+ (NSString *)emojiWithStringCode:(NSString *)stringCode
{
    char *charCode = (char *)stringCode.UTF8String;
    long intCode = strtol(charCode, NULL, 16);
    return [self emojiWithIntCode:(int)intCode];
}

+ (NSString *)emojiWithIntCode:(int)intCode {
    int symbol = EmojiCodeToSymbol(intCode);
    NSString *string = [[NSString alloc] initWithBytes:&symbol length:sizeof(symbol) encoding:NSUTF8StringEncoding];
    if (string == nil) { // 新版Emoji
        string = [NSString stringWithFormat:@"%C", (unichar)intCode];
    }
    return string;
}

- (CGSize)sizeWithMaxWidth:(CGFloat)width andFont:(UIFont *)font
{
    CGSize maxSize = CGSizeMake(width, MAXFLOAT);
    NSDictionary *dict = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin| NSStringDrawingUsesFontLeading attributes:dict context:nil].size;
}

- (NSString *)originName
{
    NSArray *list = [self componentsSeparatedByString:@"_"];
    NSMutableString *orgName = [NSMutableString string];
    NSUInteger count = list.count;
    if (list.count > 1) {
        for (int i = 1; i < count; i ++) {
            [orgName appendString:list[i]];
            if (i < count-1) {
                [orgName appendString:@"_"];
            }
        }
    } else {  // 防越狱的情况下，本地改名字
        orgName = list[0];
    }
    return orgName;
}

+ (NSString *)currentName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMddHHMMss"];
    NSString *currentDate = [dateFormatter stringFromDate:[NSDate date]];
    return currentDate;
}

- (NSString *)firstStringSeparatedByString:(NSString *)separeted
{
    NSArray *list = [self componentsSeparatedByString:separeted];
    return [list firstObject];
}

//时间戳变为格式时间
+ (NSString *)ConvertStrToTime:(NSString *)timeStr

{
    
    long long time=[timeStr longLongValue];
    //    如果服务器返回的是13位字符串，需要除以1000，否则显示不正确(13位其实代表的是毫秒，需要除以1000)
    //    long long time=[timeStr longLongValue] / 1000;
    
    NSDate *date = [[NSDate alloc]initWithTimeIntervalSince1970:time];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString*timeString=[formatter stringFromDate:date];
    
    return timeString;
    
}

- (NSDictionary *)stringToJsonDictionary {
    
    if (!self.length) {
        return nil;
    }
    
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        MMLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}


//MARK: - 信息验证
/**!
 * 验证文本是否为空
 * @return true 通过验证
 */
- (BOOL)checkTextEmpty{
    if (self == nil) return NO;
    if ([self isEqualToString:@"(null)"]) return NO;
    if ([self isEqualToString:@""]) return NO;
    if ([self length] <= 0) return NO;
    if ([[self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet] length] <= 0) return NO;
    
    return YES;
}

/**!
 * 验证用户名(数字字母)
 * @params maxLen 最大长度
 * @return true 通过验证
 */
- (BOOL)checkUsername:(NSInteger)maxLen{
    
    if (!self || [self isEqualToString:@""]) {
        return NO;
    }
    
    //长度限制
    NSUInteger length = self.length;
    if (length < 6 || length > maxLen) {
        return NO;
    }
    
    NSString *strRegex = [NSString stringWithFormat:@"^[A-Za-z0-9]{6,%lD}$",maxLen];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",strRegex];
    return [predicate evaluateWithObject:self];
}

/**!
 * 验证姓名(字母或中文)
 * @params strName NSString
 * @params len     NSInteger 长度
 * @return true 通过验证
 */
- (BOOL)checkCNameAndEName:(NSString *)strName AndLength:(NSInteger)len {
    
    if (!strName || [strName isEqualToString:@""]) {
        return NO;
    }
    
    //长度限制
    NSUInteger length = strName.length;
    if (length > len) {
        return NO;
    }
    
    NSString *strRegex = [NSString stringWithFormat:@"^[A-Za-z\\u4e00-\\u9fa5]{2,%ld}$",(long)len];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",strRegex];
    return [predicate evaluateWithObject:strName];
}


/**!
 * 验证手机号
 * @return true 通过验证
 */
- (BOOL)checkPhoneNo {
    
    if (!self || [self isEqualToString:@""]) {
        return NO;
    }
    
    NSString *strRegex = @"^1[34578]([0-9]{9})$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",strRegex];
    
    return [predicate evaluateWithObject:self];
}


/**!
 * 验证邮箱
 * @return true 通过验证
 */
- (BOOL)checkEmail{
    
    if (!self || [self isEqualToString:@""]) {
        return NO;
    }
    
    NSString *strRegex = @"^([a-zA-Z0-9_\\.-]){2,}+@([a-zA-Z0-9-]){2,}+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z0-9]{2,6}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",strRegex];
    
    return [predicate evaluateWithObject:self];
}

/**!
 * 是否含有Emoji 表情(true 含有)
 */
- (BOOL)stringContainsEmoji{
    
    __block BOOL returnValue = FALSE;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length)
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                                
                                unichar hs = [substring characterAtIndex:0];
                                // surrogate pair
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        unichar ls =[substring characterAtIndex:1];
                                        
                                        NSInteger uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f){
                                            returnValue = YES;
                                        }
                                    }
                                }
                                else if (substring.length > 1) {
                                    unichar ls =[substring characterAtIndex:1];
                                    if (ls == 0x20e3){
                                        returnValue = YES;
                                    }
                                }
                                else {
                                    // non surrogate
                                    if (0x2100 <= hs && hs <= 0x27ff){
                                        returnValue = YES;
                                    }
                                    else if (0x2B05 <= hs && hs <= 0x2b07){
                                        returnValue = YES;
                                    }
                                    else if (0x2934 <= hs && hs <= 0x2935){
                                        returnValue = YES;
                                    }
                                    else if (0x3297 <= hs && hs <= 0x3299){
                                        returnValue = YES;
                                    }
                                    else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50){
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

/**!
 * 验证身份证(15/18位)
 * @return true 通过验证
 */
- (BOOL)checkIDCardNumber{
    
    NSString *value = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger length = 0;
    if (!value) return NO;
    else {
        length = value.length;
        //不满足15位和18位，即身份证错误
        if (length != 15 && length != 18) return NO;
    }
    
    // 省份代码
    NSArray *areasArray = @[@"11",@"12", @"13",@"14", @"15",@"21", @"22",@"23", @"31",@"32", @"33",@"34", @"35",@"36", @"37",@"41", @"42",@"43", @"44",@"45", @"46",@"50", @"51",@"52", @"53",@"54", @"61",@"62", @"63",@"64", @"65",@"71", @"81",@"82", @"91"];
    
    // 检测省份身份行政区代码
    NSString *valueStart2 = [value substringToIndex:2];
    BOOL areaFlag = NO; //标识省份代码是否正确
    for (NSString *areaCode in areasArray) {
        if ([areaCode isEqualToString:valueStart2]) {
            areaFlag = YES;
            break;
        }
    }
    
    if (!areaFlag) return NO;
    
    NSRegularExpression *regularExpression;
    NSUInteger numberofMatch;
    int year = 0;
    
    //分为15位、18位身份证进行校验
    switch (length) {
            case 15:
            //获取年份对应的数字
            year = [value substringWithRange:NSMakeRange(6,2)].intValue +1900;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                //创建正则表达式 NSRegularExpressionCaseInsensitive：不区分字母大小写的模式
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|[1-2][0-9]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }
            else{
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^[1-9][0-9]{5}[0-9]{2}((01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)|02(0[1-9]|1[0-9]|2[0-8]))[0-9]{3}$"
                                                                        options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }
            //使用正则表达式匹配字符串 NSMatchingReportProgress:找到最长的匹配字符串后调用block回调
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            if(numberofMatch >0) return YES;
            else return NO;
            case 18:
            year = [value substringWithRange:NSMakeRange(6,4)].intValue;
            if (year %4 ==0 || (year %100 ==0 && year %4 ==0)) {
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$"
                                                                        options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
                
            }
            else{
                regularExpression = [[NSRegularExpression alloc]initWithPattern:@"^((1[1-5])|(2[1-3])|(3[1-7])|(4[1-6])|(5[0-4])|(6[1-5])|71|(8[12])|91)\\d{4}(((19|20)\\d{2}(0[13-9]|1[012])(0[1-9]|[12]\\d|30))|((19|20)\\d{2}(0[13578]|1[02])31)|((19|20)\\d{2}02(0[1-9]|1\\d|2[0-8]))|((19|20)([13579][26]|[2468][048]|0[048])0229))\\d{3}(\\d|X|x)?$"
                                                                        options:NSRegularExpressionCaseInsensitive error:nil];//测试出生日期的合法性
            }
            
            numberofMatch = [regularExpression numberOfMatchesInString:value
                                                               options:NSMatchingReportProgress
                                                                 range:NSMakeRange(0, value.length)];
            if(numberofMatch >0) {
                //1：校验码的计算方法 身份证号码17位数分别乘以不同的系数。从第一位到第十七位的系数分别为：7－9－10－5－8－4－2－1－6－3－7－9－10－5－8－4－2。将这17位数字和系数相乘的结果相加。
                int S = [value substringWithRange:NSMakeRange(0,1)].intValue*7 + [value substringWithRange:NSMakeRange(10,1)].intValue *7 + [value substringWithRange:NSMakeRange(1,1)].intValue*9 + [value substringWithRange:NSMakeRange(11,1)].intValue *9 + [value substringWithRange:NSMakeRange(2,1)].intValue*10 + [value substringWithRange:NSMakeRange(12,1)].intValue *10 + [value substringWithRange:NSMakeRange(3,1)].intValue*5 + [value substringWithRange:NSMakeRange(13,1)].intValue *5 + [value substringWithRange:NSMakeRange(4,1)].intValue*8 + [value substringWithRange:NSMakeRange(14,1)].intValue *8 + [value substringWithRange:NSMakeRange(5,1)].intValue*4 + [value substringWithRange:NSMakeRange(15,1)].intValue *4 + [value substringWithRange:NSMakeRange(6,1)].intValue*2 + [value substringWithRange:NSMakeRange(16,1)].intValue *2 + [value substringWithRange:NSMakeRange(7,1)].intValue *1 + [value substringWithRange:NSMakeRange(8,1)].intValue *6 + [value substringWithRange:NSMakeRange(9,1)].intValue *3;
                
                //2：用加出来和除以11，看余数是多少？余数只可能有0－1－2－3－4－5－6－7－8－9－10这11个数字
                int Y = S %11;
                NSString *M =@"F";
                NSString *JYM =@"10X98765432";
                M = [JYM substringWithRange:NSMakeRange(Y,1)];
                
                // 3：获取校验位
                NSString *lastStr = [value substringWithRange:NSMakeRange(17,1)];
                NSLog(@"%@",M);
                NSLog(@"%@",[value substringWithRange:NSMakeRange(17,1)]);
                
                //4：检测ID的校验位
                if ([lastStr isEqualToString:@"x"]) {
                    if ([M isEqualToString:@"X"]) return YES;
                    else return NO;
                }
                else{
                    if ([M isEqualToString:[value substringWithRange:NSMakeRange(17,1)]]) return YES;
                    else return NO;
                }
            }
            else return NO;
        default:
            return NO;
    }
}


//MARK: - 文本转换
/**!
 * Unicod 转UTF-8
 */
- (NSString*)replaceUnicode{
    
   NSString *tempStr1 = [self stringByReplacingOccurrencesOfString:@"\\u"withString:@"\\U"];
   NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""];
    
   NSString *tempStr3 = [[@"\""stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
   NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    
   id temp = [NSPropertyListSerialization propertyListWithData:tempData
                                                       options:NSPropertyListImmutable
                                                        format:NULL
                                                         error:NULL];
    
    NSString *returnStr = temp?[NSString stringWithFormat:@"%@",temp]:@"";
    return [returnStr stringByReplacingOccurrencesOfString:@"\\r\\n"withString:@"\n"];
}

- (NSString *)urlEncode{
    if (self && self.checkTextEmpty) {
        return [self stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    return @"";
}

- (NSString *)urlDcode{
    if (self && self.checkTextEmpty) {
        return [self stringByRemovingPercentEncoding];
    }
    return self;
}
@end
