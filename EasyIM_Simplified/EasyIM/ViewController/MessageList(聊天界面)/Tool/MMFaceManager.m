//
//  MMFaceManager.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMFaceManager.h"
#import "MJExtension.h"
#import "MMEmotion.h"
#import "MMFaceManager.h"

#define ICBundle [NSBundle mainBundle]

@implementation MMFaceManager

static NSArray * _emojiEmotions,*_custumEmotions,*gifEmotions;

+ (NSArray *)emojiEmotion
{
    if (_emojiEmotions) {
        return _emojiEmotions;
    }
    NSString *path  = [ICBundle pathForResource:@"emoji.plist" ofType:nil];
    _emojiEmotions  = [MMEmotion mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    return _emojiEmotions;
}

+ (NSArray *)customEmotion
{
    if (_custumEmotions) {
        return _custumEmotions;
    }
    NSString *path  = [ICBundle pathForResource:@"normal_face.plist" ofType:nil];
    _custumEmotions = [MMEmotion mj_objectArrayWithKeyValuesArray:[NSArray arrayWithContentsOfFile:path]];
    return _custumEmotions;
}

+ (NSArray *)gifEmotion
{
    return nil;
}

+ (NSMutableAttributedString *)transferMessageString:(NSString *)message
                                                font:(UIFont *)font
                                          lineHeight:(CGFloat)lineHeight
{
        
    //1.创建可变的字符串
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:message];
    
    //2.通过正则表达式来匹配字符串
    NSString *regEmj  = @"\\[[a-zA-Z0-9\\/\\u4e00-\\u9fa5]+\\]";// [微笑]、[哭]等自定义表情处理
    NSError *error    = nil;
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern:regEmj options:NSRegularExpressionCaseInsensitive error:&error];
    if (!expression) {
        NSLog(@"%@",error);
        return attributeStr;
    }
    [attributeStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, attributeStr.length)];
    NSArray *resultArray = [expression matchesInString:message options:0 range:NSMakeRange(0, message.length)];
    
    //3.获取所有的表情以及位置
    //3.1用来存放字典，字典中存储的是图片和图片对应的位置
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:resultArray.count];
    //3.2根据匹配范围来用图片进行相应的替换
    for (NSTextCheckingResult *match in resultArray) {
        //3.3获取数组元素中得到range
        NSRange range    = match.range;
        //3.4获取原字符串中对应的值
        NSString *subStr = [message substringWithRange:range];
        NSArray *faceArr = [MMFaceManager customEmotion];
        for (MMEmotion *face in faceArr) {
            if ([face.face_name isEqualToString:subStr]) {
                NSTextAttachment *attach   = [[NSTextAttachment alloc] init];
                attach.image               = [UIImage imageNamed:face.face_name];
                //3.5调整一下图片的位置,如果你的图片偏上或者偏下，调整一下bounds的y值即可
                attach.bounds              = CGRectMake(0, -4, lineHeight, lineHeight);
                //3.6把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:attach];
                //3.7把图片和图片对应的位置存入字典中
                NSMutableDictionary *imagDic   = [NSMutableDictionary dictionaryWithCapacity:2];
                [imagDic setObject:imgStr forKey:@"image"];
                [imagDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                //3.8把字典存入数组中
                [mutableArray addObject:imagDic];
            }
        }
    }
    
    //4.从后往前替换，否则会引起位置问题
    for (int i =(int) mutableArray.count - 1; i >= 0; i --) {
        NSRange range;
        [mutableArray[i][@"range"] getValue:&range];
        //4.1进行替换
        [attributeStr replaceCharactersInRange:range withAttributedString:mutableArray[i][@"image"]];
    }
    return attributeStr;
}

@end
