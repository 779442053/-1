//
//  NSString+Extension.h
//  XZ_WeChat
//
//  Created by 郭现壮 on 16/9/27.
//  Copyright © 2016年 gxz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)

- (NSString *)emoji;

- (CGSize)sizeWithMaxWidth:(CGFloat)width andFont:(UIFont *)font;

- (NSString *)originName;

+ (NSString *)currentName;

- (NSString *)firstStringSeparatedByString:(NSString *)separeted;

//时间戳变为格式时间
+ (NSString *)ConvertStrToTime:(NSString *)timeStr;

/** 字符串转字典 */
- (NSDictionary *)stringToJsonDictionary;


//MARK: - 信息验证
/**!
 * 验证文本是否为空
 * @return true 通过验证
 */
- (BOOL)checkTextEmpty;

/**!
 * 验证用户名(密码为[6,?]位的数字字母)
 * @params maxLen 最大长度
 * @return true 通过验证
 */
- (BOOL)checkUsername:(NSInteger)maxLen;

/**!
 * 验证姓名(字母或中文)
 * @params strName NSString
 * @params len     NSInteger 长度
 * @return true 通过验证
 */
- (BOOL)checkCNameAndEName:(NSString *)strName AndLength:(NSInteger)len;

/**!
 * 验证手机号
 * @return true 通过验证
 */
- (BOOL)checkPhoneNo;

/**!
 * 验证邮箱
 * @return true 通过验证
 */
- (BOOL)checkEmail;

/**!
 * 验证身份证(15/18位)
 * @return true 通过验证
 */
- (BOOL)checkIDCardNumber;


/**!
 * 是否含有Emoji 表情(true 含有)
 */
- (BOOL)stringContainsEmoji;

//MARK: - 文本转换
/** Unicod 转UTF-8 */
- (NSString*)replaceUnicode;

/** urlEncode(编码) */
- (NSString *)urlEncode;

/** urlDcode(解码) */
- (NSString *)urlDcode;
@end
