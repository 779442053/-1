//
//  YKUnit.h
//  hjqinspection
//
//  Created by 源库 on 2017/3/29.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YKUnit : NSObject



/*! @brief 计算多文本高度
 *
 *@param textArray 多个文本内容
 *@param singleLineHeight 单行文本框高度
 *@param textWith 文本框宽度
 *@result float 返回文本高度
 */
+ (float)heightForTexts:(NSArray *)textArray singleLineHeight:(float)singleLineHeight fontSize:(float)fontSize textWith:(float)textWith;

/*! @brief 计算文本高度(设置单行高度)
 *
 *@param text 多个文本内容
 *@param singleLineHeight 单行文本框高度
 *@param textWith 文本框宽度
 *@result float 返回文本高度
 */
+ (float)heightForText:(NSString *)text singleLineHeight:(float)singleLineHeight fontSize:(float)fontSize textWith:(float)textWith;

/*! @brief 计算文本是否为单行
 *
 *@param text 文本内容
 *@result float 返回文本高度
 */
+ (BOOL)isSingleForText:(NSString *)text fontSize:(float)fontSize textWith:(float)textWith;

/*! @brief 计算文本高度
 *
 *@param text 文本内容
 *@param textWith 文本框宽度
 *@result float 返回文本高度
 */
+ (float)heightForText:(NSString *)text fontSize:(float)fontSize textWith:(float)textWith;

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForTextTure:(NSString *)text fontSize:(float)fontSize;

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForTextTure:(NSString *)text font:(UIFont *)font;

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForText:(NSString *)text fontSize:(float)fontSize;

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForText:(NSString *)text font:(UIFont *)font;
@end
