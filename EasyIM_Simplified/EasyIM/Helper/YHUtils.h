//
//  HHUtils.h
//  HipHopBattle
//  CSDN:  http://blog.csdn.net/samuelandkevin
//  Created by samuelandkevin on 14-6-26.
//  Copyright (c) 2014年 Dope Beats Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/param.h>
#include <sys/mount.h>

typedef void(^HHAlertCallback)(BOOL resultYes );

@interface YHUtils : NSObject

/**
 * 获取文件MD5值
 */
+ (NSString *_Nullable)getFileMD5WithPath:(NSString*_Nonnull)path;
+ (NSString *_Nullable)getFileMD5WithData:(NSData *_Nonnull)data;
+ (UIView *_Nullable)rotate360DegreeWithView:(UIView *_Nonnull)imageView;

#pragma mark - 弹窗页面
+ (void)showSingleButtonAlertWithTitle:(NSString *_Nullable)title
                               message:(NSString *_Nullable)msg
                               okTitle:(NSString *_Nullable)okString
                               dismiss:(HHAlertCallback _Nullable )callback;

+ (void)showAlertWithTitle:(NSString *_Nullable)title
                   message:(NSString *_Nullable)msg
                   dismiss:(HHAlertCallback _Nullable )callback;

+ (void)showAlertWithTitle:(NSString *_Nullable)title
                   message:(NSString *_Nullable)msg
                   okTitle:(NSString *_Nullable)okString
               cancelTitle:(NSString *_Nullable)cancelString
          inViewController:(UIViewController *_Nullable)vc
                   dismiss:(HHAlertCallback _Nullable )callback;

+ (void)showAlertWithTitle:(NSString *_Nullable)title
                   message:(NSString *_Nullable)msg
                   okTitle:(NSString *_Nullable)okString
               cancelTitle:(NSString *_Nullable)cancelString
                   dismiss:(HHAlertCallback _Nullable )callback;

+ (NSDictionary *_Nullable)parseUrlParameters:(NSURL *_Nullable)url;

+ (void)postTip:(NSString *_Nullable)tipsTitle
          RGB16:(int)hexColor
       complete:(void(^_Nullable)(void))completeCallback;

+ (void)postTip:(NSString *_Nullable)tipsTitle
          RGB16:(int)rgbValue
       keepTime:(NSTimeInterval)interval
       complete:(void(^_Nullable)(void))completeCallback;

+ (void)postTip:(NSString *_Nullable)tipsTitle
    RGBcolorRed:(CGFloat)red
          green:(CGFloat)green
           blue:(CGFloat)blue
       keepTime:(NSTimeInterval)time
       complete:(void(^_Nullable)(void))completeCallback;

+ (void)dismissAlertWithClickedButtonIndex:(NSInteger)buttonIndex
                                  animated:(BOOL)animated;

+ (long long)freeDiskSpaceInBytes;

/**
 *  MD5加密字符串
 *
 *  @param input 字符串
 *
 *  @return 加密后的字符串
 */
+ (NSString *_Nullable)md5HexDigest:(NSString* _Nullable)input;

/**
 *  获取iPhone机型
 *
 */
+ (NSString* _Nullable)phoneType;

/**
 *  获取iPhone系统
 *
 *  @return eg:iOS8.1
 */
+ (NSString *_Nullable)phoneSystem;

/**
 *  appStore上的版本号
 *
 */
+ (NSString *_Nullable)appStoreNumber;
/**
 *  app开发环境版本号
 *
 */
+ (NSString *_Nullable)appBulidNumber;

+ (BOOL)compareWithBeginDateString:(NSString *_Nullable)beginDateString
                  andEndDateString:(NSString *_Nullable)endDateString;

//MARK: - 时间格式化处理
/** 将Linux时间装换为字符串时间 */
+(NSString *_Nonnull)formatDateToString:(NSTimeInterval)linuxTime
                             WithFormat:(NSString *_Nonnull)format;

+ (NSDate *_Nullable)dateFromString:(NSString *_Nullable)dateString;
+ (NSString *_Nullable)getNormalShowDateString:(NSString *_Nullable)dateString;

//MARK: - 图片相关处理
/**! 图片不变形处理 */
+(void)imgNoTransformation:(UIImageView *_Nullable)img;

/** 图片压缩处理 */
+(NSData *_Nullable)zipNSDataWithImage:(UIImage *_Nullable)sourceImage;

//MARK: - 播放声音
/** 新消息声音播放 */
+ (void)playVoiceForMessage;

/** 音视频关闭或拒绝提示音 */
+ (void)closeVoiceAudioAndVideo;

/**
 * 播放自定义声音文件
 * @param strName 文件名
 * @param strType 后缀(不带点)
 * @param isVibrate YES 振动
 */
+(void)playVoiceForName:(NSString *_Nonnull)strName
                AndType:(NSString *_Nonnull)strType
             AndVibrate:(BOOL)isVibrate;

/** 音视频邀请声音播放 */
+(void)playVoiceForAudioAndVideo:(void(^ _Nonnull)(AVAudioPlayer *_Nullable _avaudio))playerBack;

/** 群聊音视频对方加入后振动手机提示 */
+(void)vibratingCellphone;

//MARK: - 网络请求
+ (void)POSTWithURLString:(NSString *_Nonnull)URLString
               parameters:(id _Nullable)parameters
                  success:(void (^_Nullable)(id _Nullable responseObject))success
                  failure:(void (^_Nullable)(NSError * _Nullable error))failure;

/**! 设置富文本 */
+(NSAttributedString *)setAttributeStringText:(NSString *_Nonnull)strFullText
                              andFullTextFont:(UIFont *_Nonnull)textFont
                             andFullTextColor:(UIColor *_Nonnull)textColor
                               withChangeText:(NSString *_Nonnull)changeText
                               withChangeFont:(UIFont *_Nonnull)changFont
                              withChangeColor:(UIColor *_Nonnull)changeColor
                                isLineThrough:(BOOL)lineThrough;

//MARK: - 获取文本的宽度
/**!
 * 获取文本的宽度
 */
+(CGFloat)getWidthForString:(NSString *_Nonnull)value
                andFontSize:(UIFont *_Nonnull)font
                  andHeight:(CGFloat)height;


/** 获取文本的高度 */
+(CGFloat)getHeightForString:(NSString *_Nonnull)value
                 andFontSize:(UIFont *_Nonnull)font
                    andWidth:(CGFloat)width;

/**! 获取第一个首字母 */
+(NSString *_Nonnull)getFirstLetter:(NSString *_Nullable)strInput ;
@end

#ifdef __cplusplus
extern "C" {
#endif

    
/**
 返回文件长度，以字节为单位
 */
int getFileSize(NSString * _Nullable path);

NSString * _Nullable getDeviceVersion(void);
NSString * _Nullable platformString (void);

/**
 比较不同数组中不同的ID（与上一次的缓存对比）
 @return 返回与是一次是否有变化
 */
    BOOL compareStringIdsDiff( NSArray * _Nonnull allphones, NSString * _Nullable phonesCach_NullableeFilePath, NSArray *_Nonnull* _Nonnull addlist, NSArray *_Nonnull* _Nonnull removelist);

#ifdef __cplusplus
    }
#endif
