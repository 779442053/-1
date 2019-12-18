//
//  YKUnit.m
//  hjqinspection
//
//  Created by 源库 on 2017/3/29.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "YKUnit.h"
#import <UIKit/UIKit.h>

@implementation YKUnit

/**
 *  过滤html标签
 *
 *  @param html 含有html标记的字符串
 *
 *  @return 过滤后的
 */
+ (NSString *)removeHTML:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"<(.[^>]*)>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"([\r\n])[\\s]+" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"../" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\\n"];
    html = [html stringByReplacingOccurrencesOfString:@"<br />" withString:@"\\n"];
    html = [html stringByReplacingOccurrencesOfString:@"<br>" withString:@"\\n"];
    
    return html;
}

/*! @brief 计算多文本高度
 *
 *@param textArray 多个文本内容
 *@param singleLineHeight 单行文本框高度
 *@param textWith 文本框宽度
 *@result float 返回文本高度
 */
+ (float)heightForTexts:(NSArray *)textArray singleLineHeight:(float)singleLineHeight fontSize:(float)fontSize textWith:(float)textWith {
    float totalHeight = 0.0;
    for (NSString *text in textArray) {
        float height = [self heightForText:text fontSize:fontSize textWith:textWith];
        totalHeight = (height > totalHeight) ? height :totalHeight;
    }
    return totalHeight + singleLineHeight - [self heightForText:@" " fontSize:fontSize textWith:textWith];
}

/*! @brief 计算文本高度(设置单行高度)
 *
 *@param text 多个文本内容
 *@param singleLineHeight 单行文本框高度
 *@param textWith 文本框宽度
 *@result float 返回文本高度
 */
+ (float)heightForText:(NSString *)text singleLineHeight:(float)singleLineHeight fontSize:(float)fontSize textWith:(float)textWith {
    float height = [self heightForText:text fontSize:fontSize textWith:textWith];
    return height + singleLineHeight - [self heightForText:@" " fontSize:fontSize textWith:textWith];
}

/*! @brief 计算文本是否为单行
 *
 *@param text 文本内容
 *@result float 返回文本高度
 */
+ (BOOL)isSingleForText:(NSString *)text fontSize:(float)fontSize textWith:(float)textWith {
    float height = [self heightForText:text fontSize:fontSize textWith:textWith];
    return height <= [self heightForText:@" " fontSize:fontSize textWith:textWith];
}

/*! @brief 计算文本高度
 *
 *@param text 文本内容
 *@param textWith 文本框宽度
 *@result float 返回文本高度
 */
+ (float)heightForText:(NSString *)text fontSize:(float)fontSize textWith:(float)textWith
{
    if (!text.length) return 0;
    CGSize constraint = CGSizeMake(textWith, 20000.0f);
    
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size.height;
}

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForTextTure:(NSString *)text fontSize:(float)fontSize
{
    return [self widthForTextTure:text font:[UIFont systemFontOfSize:fontSize]];
}

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForTextTure:(NSString *)text font:(UIFont *)font
{
    if (!text.length) return 0;
    
    UILabel *label = [UILabel new];
    label.text = text;
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize size=[label.text sizeWithAttributes:attrs];
    float uiWith = ([UIScreen mainScreen].bounds.size.width<414)?[UIScreen mainScreen].bounds.size.width-30:[UIScreen mainScreen].bounds.size.width-40;
    if(size.width > uiWith) return uiWith;
    return size.width;
}

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForText:(NSString *)text fontSize:(float)fontSize
{
    return [self widthForText:text font:[UIFont systemFontOfSize:fontSize]];
}

/*! @brief 计算文本宽度
 *
 *@param text 文本内容
 *@result float 返回文本宽度
 */
+ (float)widthForText:(NSString *)text font:(UIFont *)font
{
    if (!text.length) return 44;
    
    UILabel *label = [UILabel new];
    label.text = text;
    NSDictionary *attrs = @{NSFontAttributeName : font};
    CGSize size=[label.text sizeWithAttributes:attrs];
    if (size.width < 34) return 44;
    float uiWith = ([UIScreen mainScreen].bounds.size.width<414)?[UIScreen mainScreen].bounds.size.width-30:[UIScreen mainScreen].bounds.size.width-40;
    if(size.width+10 > uiWith) return uiWith;
    return size.width+10;
}

/**
 *  计算文本高度
 *
 *  @param value    文本内容
 *  @param fontSize 字体大小
 *  @param width    文本框宽度
 *
 *  @return 高度
 */
+ (float)heightForString:(NSString *)value fontSize:(float)fontSize andWidth:(float)width
{
    UITextView *detailTextView = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, width, 0)];
    detailTextView.font = [UIFont systemFontOfSize:fontSize];
    detailTextView.text = value;
    CGSize deSize = [detailTextView sizeThatFits:CGSizeMake(width,CGFLOAT_MAX)];
    return deSize.height;
}

@end
