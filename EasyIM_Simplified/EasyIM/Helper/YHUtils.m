//
//  HHUtils.m
//  HipHopBattle
//
//  Created by samuelandkevin on 14-6-26.
//  Copyright (c) 2014年 Dope Beats Co.,Ltd. All rights reserved.
//

#import "YHUtils.h"
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import <sys/utsname.h>
#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSDate+LYXCategory.h"

//震动手机
#import <AudioToolbox/AudioToolbox.h>

#define FileHashDefaultChunkSizeForReadingData 1024*512
#define kCommonAlertTag         10



CFStringRef FileMD5HashCreateWithPath(CFStringRef filePath,size_t chunkSizeForReadingData) {
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,(UInt8 *)buffer,(CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,(const void *)buffer,(CC_LONG)readBytesCount);
    }
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    // Compute the string result
    char hash[ 2 * sizeof(digest) + 1 ];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    hash[ 2 * sizeof(digest) ] = '\0';
    result = CFStringCreateWithCString(kCFAllocatorDefault,(const char *)hash,kCFStringEncodingUTF8);
    
done:
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}

@interface AssistObject : NSObject
@property (nonatomic, copy)    HHAlertCallback     callbackForAlert;

@property (nonatomic, copy)     NSString            *title;
@property (nonatomic, copy)     NSString            *message;
@property (nonatomic, weak)     id                  alertView;
//@property (nonatomic, strong)   NSMutableArray      *alertViews;
@end

@interface HHUIAlertView : UIAlertView

@property (nonatomic, strong) HHAlertCallback   dismissCallback;

@end

@implementation HHUIAlertView

@end


static AssistObject *g_assistObj = nil;

@interface YHUtils ()<UIAlertViewDelegate>
{
    
}

@end


@implementation YHUtils

+ (long long)freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    
    return freespace;
}


+(NSString*)getFileMD5WithPath:(NSString*)path
{
    return (__bridge_transfer NSString *)FileMD5HashCreateWithPath((__bridge  CFStringRef)path,FileHashDefaultChunkSizeForReadingData);
}

+ (NSString *)getFileMD5WithData:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
//    MD5_CTX smd5;
//    MD5_Init(&smd5);
//    MD5_Update(&smd5, data.bytes, data.length);
//    MD5_Final(digest, &smd5);
    
    
    CC_MD5( data.bytes, (UInt32)data.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}

+ (UIView *)rotate360DegreeWithView:(UIImageView *)imageView {
    
    
    [imageView.layer removeAnimationForKey:@"rotateView"];
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform.rotation.z" ];
    //    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.fromValue     = @(0.0);
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue       = @(-M_PI);
    //    [ NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.5;
    
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = HUGE_VALF;
    
    [imageView.layer addAnimation:animation forKey:@"rotateView"];
    return imageView;
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg dismiss:(HHAlertCallback)callback {
    
    return [self showAlertWithTitle:title message:msg okTitle:@"确定" cancelTitle:@"取消" dismiss:callback];
}

+ (void)showSingleButtonAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString dismiss:(HHAlertCallback)callback {
    return [self showAlertWithTitle:title message:msg okTitle:okString cancelTitle:nil inViewController:[UIApplication sharedApplication].keyWindow.rootViewController dismiss:callback];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString cancelTitle:(NSString *)cancelString dismiss:(HHAlertCallback)callback {
    
    return [self showAlertWithTitle:title message:msg okTitle:okString cancelTitle:cancelString inViewController:[UIApplication sharedApplication].keyWindow.rootViewController dismiss:callback];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg okTitle:(NSString *)okString cancelTitle:(NSString *)cancelString inViewController:(UIViewController *)vc dismiss:(HHAlertCallback)callback
{
    if (!g_assistObj) {
        g_assistObj = [AssistObject new];
    }
    
    NSString *titleString = title?title:@"提示";
    if ([[UIDevice currentDevice].systemVersion floatValue]< 8.0) {
        HHUIAlertView *alert = [[HHUIAlertView alloc] initWithTitle:titleString message:msg delegate:g_assistObj cancelButtonTitle:cancelString otherButtonTitles:okString, nil];
        alert.dismissCallback = callback;
        alert.tag = kCommonAlertTag;
        [alert show];
        g_assistObj.alertView = alert;
    }
    else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        
        if (cancelString) {
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:cancelString style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback( NO );
                    }
//                    g_assistObj.callbackForAlert(NO);
//                    g_assistObj.callbackForAlert = nil;
                });
                
            }];
            [alert addAction:cancel];
        }
        
        UIAlertAction *ok = [UIAlertAction actionWithTitle:okString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) {
                    callback( YES );
                }
//                g_assistObj.callbackForAlert(YES);
//                g_assistObj.callbackForAlert = nil;
            });
            
        }];
        [alert addAction:ok];
        
        dispatch_async(dispatch_get_main_queue(), ^ {
            [vc presentViewController:alert animated:YES completion:nil];
        });
        
        g_assistObj.alertView = alert;
    }
}

+ (void)dismissAlertWithClickedButtonIndex:(NSInteger)buttonIndex
                             animated:(BOOL)animated {
    if (g_assistObj.alertView) {
        if ([g_assistObj.alertView isKindOfClass:[UIAlertView classForCoder]]) {
            [g_assistObj.alertView dismissWithClickedButtonIndex:buttonIndex animated:animated];
        }
        else if ([g_assistObj.alertView isKindOfClass:[UIAlertController classForCoder]]) {
            [g_assistObj.alertView dismissViewControllerAnimated:animated completion:nil];
        }
    }
}

+ (NSDictionary *)parseUrlParameters:(NSURL *)url {
    NSMutableDictionary *retMd = [NSMutableDictionary dictionary];
    NSString *query = [url query];
    if (!query || query.length == 0) {
        return retMd;
    }
    
    NSArray *parameters = [query componentsSeparatedByString:@"&"];
    for (NSString *str in parameters) {
        NSArray *keyValue   = [str componentsSeparatedByString:@"="];
        [retMd setObject:keyValue[1] forKey:keyValue[0]];
    }
    
    return retMd;
}

+ (void)postTip:(NSString *)tipsTitle RGB16:(int)rgbValue complete:(void(^)())completeCallback {

    [self postTip:tipsTitle RGBcolorRed:((float)((rgbValue & 0xFF0000) >> 16)) \
            green:((float)((rgbValue & 0xFF00) >> 8)) \
             blue:((float)(rgbValue & 0xFF)) \
         keepTime:1.0 \
         complete:completeCallback];
    
}

+ (void)postTip:(NSString *)tipsTitle RGB16:(int)rgbValue keepTime:(NSTimeInterval)interval complete:(void(^)())completeCallback {
    [self postTip:tipsTitle RGBcolorRed:((float)((rgbValue & 0xFF0000) >> 16)) \
            green:((float)((rgbValue & 0xFF00) >> 8)) \
             blue:((float)(rgbValue & 0xFF)) \
         keepTime:interval \
         complete:completeCallback];
}

+ (void)postTip:(NSString *)tipsTitle RGBcolorRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue keepTime:(NSTimeInterval)time complete:(void(^)())completeCallback {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UILabel *labelBanner = [[UILabel alloc] initWithFrame:CGRectMake(0, -20, keyWindow.frame.size.width, 20)];
    labelBanner.font = [UIFont systemFontOfSize:10.0f];
    labelBanner.text = tipsTitle;
    labelBanner.textAlignment = NSTextAlignmentCenter;
    labelBanner.backgroundColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
    labelBanner.textColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
    
    keyWindow.windowLevel = UIWindowLevelStatusBar + 1.0f;
    [keyWindow addSubview:labelBanner];
    
    [UIView animateWithDuration:0.3 animations:^{
        //显示出来
        labelBanner.transform = CGAffineTransformMakeTranslation(0, 20);
        
    } completion:^(BOOL finished) {
        //停留0.5
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //回去
            [UIView animateWithDuration:0.5 animations:^{
                labelBanner.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                keyWindow.windowLevel = UIWindowLevelNormal;
                if (completeCallback) {
                    completeCallback();
                }
                
            }];
            
        });
    }];
}

+ (NSString *)md5HexDigest:(NSString*)input{
    
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)input.length, digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
    
}

+ (NSString *)getDeviceVersion {
    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
    return deviceType;
}

+ (NSString*)phoneType
{
    NSString *platform = getDeviceVersion();
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return@"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return@"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return@"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return@"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return@"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return@"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone4,2"])   return @"iPhone 5 (CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5S";
    
    if ([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5S";
    
    if ([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6";
    
    if ([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return@"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return@"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return@"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return@"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return@"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}

+ (NSString *)phoneSystem{
    return [NSString stringWithFormat:@"%@%@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
}

+ (NSString *)appStoreNumber{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)appBulidNumber{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}


+ (BOOL)compareWithBeginDateString:(NSString *)beginDateString andEndDateString:(NSString *)endDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM"];
    NSDate *beginDate = [dateFormatter dateFromString:beginDateString];
    NSDate *endDate = [dateFormatter dateFromString:endDateString];
    NSComparisonResult result = [beginDate compare:endDate];
    
    if (result == NSOrderedAscending)
    {
        return YES;
    }
    return NO;
}

///**
// *  格式化日期
// *
// *  @param dateFormat 日期格式，etg：@"yyyy-MM-dd HH:mm:ss"
// *
// *  @return 字符串
// */
//- (NSString *)toStringByformat:(NSString *)dateFormat
//{
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:dateFormat];
//    NSString *returnString = [formatter stringFromDate:self];
//    ARC_RELEASE(dateFormatter);
//    return returnString;
//}

#pragma mark - 格式化显示时间 4月12日

+ (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *destDate= [dateFormatter dateFromString:dateString];
    return destDate;
    
}

+ (NSString *)getNormalShowDateString:(NSString *)dateString
{
    NSDate   *nowDate    = [NSDate date];
    NSString *dateStr    = [dateString substringToIndex:9];
    NSString *curDateStr = [nowDate toStringByformat:@"yyyy-MM-dd"];
    if ([dateStr isEqualToString:curDateStr])
    {
        //当天信息
        NSString *hourString = [dateString substringWithRange:NSMakeRange(11, 2)];
        NSInteger hour = [hourString integerValue];
        NSString *strMonment = @"";
        if(hour < 6){
            strMonment = @"凌晨";
        }
        else if (hour < 12){
            strMonment = @"上午";
        }
        else if (hour < 18){
            strMonment = @"下午";
        }
        else{
            strMonment = @"晚上";
        }
        
        NSString *timeString = [dateString substringWithRange:NSMakeRange(11, 5)];
        return [NSString stringWithFormat:@"%@%@",strMonment,timeString];
        
    }
    else
    {
        NSDate *yesterday = [NSDate dateWithTimeIntervalSince1970:[nowDate timeIntervalSince1970]-(24*60*60)];
        
        NSString* yesterdatStr = [yesterday toStringByformat:@"yyyy-MM-dd"];
        
        if ([dateStr isEqualToString:yesterdatStr])//昨天
        {

            NSString *timeString = [dateString substringWithRange:NSMakeRange(11, 5)];
            return [NSString stringWithFormat:@"昨天%@",timeString];
        }
        else
        {
            NSString *dateStr    = [dateString substringToIndex:4];
            NSString *curDateStr = [nowDate toStringByformat:@"yyyy"];
            if ([dateStr isEqualToString:curDateStr])//当年
            {
                //MM月dd日
                return  [dateString substringWithRange:NSMakeRange(5, 5)];
            }
            else//超过一年
            {
                //yyyy年MM月dd日
                return [dateString substringWithRange:NSMakeRange(0, 10)];
            }
        }
    }
}

/** 将Linux时间装换为字符串时间 */
+(NSString *_Nonnull)formatDateToString:(NSTimeInterval)linuxTime
                     WithFormat:(NSString *_Nonnull)format{
    
    long long _timeInterval = linuxTime;
    NSString *_temp = [NSString stringWithFormat:@"%.0f",linuxTime];
    if (_temp.length > 10) {
        _temp = [_temp substringToIndex:10];
        
        _timeInterval = [_temp longLongValue];
    }
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_timeInterval];
    NSDateFormatter *fomatter = [[NSDateFormatter alloc] init];
    [fomatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC+8"]];
    [fomatter setDateFormat:format];
    
    NSString *_strInfo = [fomatter stringFromDate:date];
    return _strInfo;
}


//MARK: - 图片相关处理
/**! 图片不变形处理 */
+(void)imgNoTransformation:(UIImageView *)img{
    img.contentMode = UIViewContentModeScaleAspectFill;
    img.clipsToBounds = YES; //是否剪切掉超出 UIImageView 范围的图片
    img.contentScaleFactor = [UIScreen mainScreen].scale;
}

/** 图片压缩处理 */
+(NSData *)zipNSDataWithImage:(UIImage *)sourceImage{
    //进行图像尺寸的压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    //1.宽高大于1280(宽高比不按照2来算，按照1来算)
    if (width>1280||height>1280) {
        if (width>height) {
            CGFloat scale = height/width;
            width = 1280;
            height = width*scale;
        }else{
            CGFloat scale = width/height;
            height = 1280;
            width = height*scale;
        }
    }
    //2.宽大于1280高小于1280
    else if(width>1280||height<1280){
        CGFloat scale = height/width;
        width = 1280;
        height = width*scale;
    }
    //3.宽小于1280高大于1280
    else if(width<1280||height>1280){
        CGFloat scale = width/height;
        height = 1280;
        width = height*scale;
        
    }
    //4.宽高都小于1280
    else{
        
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //进行图像的画面质量压缩
    NSData *data=UIImageJPEGRepresentation(newImage, 1.0);
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            data=UIImageJPEGRepresentation(newImage, 0.7);
        }else if (data.length>512*1024) {//0.5M-1M
            data=UIImageJPEGRepresentation(newImage, 0.8);
        }else if (data.length>200*1024) {
            //0.25M-0.5M
            data=UIImageJPEGRepresentation(newImage, 0.9);
        }
    }
    return data;
}


//MARK: - 播放声音
/**手机振动,针对群发消息*/
+ (void)ShackTheIphon{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}
/** 新消息声音播放 */
+ (void)playVoiceForMessage{
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("sms-received"), CFSTR("caf"), NULL);
    SystemSoundID soundFileID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileID);
    AudioServicesAddSystemSoundCompletion(soundFileID, NULL, NULL, soundCompletionBlock, (__bridge void*) self);
    AudioServicesPlaySystemSound(soundFileID);
}

+ (void)closeVoiceAudioAndVideo{
    
    CFURLRef soundFileURLRef = CFBundleCopyResourceURL(CFBundleGetMainBundle(), CFSTR("video_audio_close"), CFSTR("mp3"), NULL);
    SystemSoundID soundFileID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundFileID);
    AudioServicesAddSystemSoundCompletion(soundFileID, NULL, NULL, soundCompletionBlock, (__bridge void*) self);
    AudioServicesPlaySystemSound(soundFileID);
}

static void soundCompletionBlock(SystemSoundID SSID, void *mySelf){
    AudioServicesRemoveSystemSoundCompletion(SSID);
}

/**
 * 播放自定义声音文件
 * @param strName 文件名
 * @param strType 后缀(不带点)
 * @param isVibrate YES 振动
 */
+(void)playVoiceForName:(NSString *_Nonnull)strName
                AndType:(NSString *_Nonnull)strType
             AndVibrate:(BOOL)isVibrate{
    //手机振动
    if (isVibrate){
       AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    }
    
    NSError *error;
    AVAudioPlayer *player;
    
    @try {
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:strName withExtension:strType];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
        //player.volume = 1.0;//最大声音
        
        //numberOfLoops 循环次数，如果要单曲循环，设置为负数
        player.numberOfLoops = 1;
        
        [player play];
    } @catch (NSException *exception) {
        MMLog(@"播放自定义声音文件播放异常！详见：%@",exception);
    } @finally {
        if (player) {
            [player stop];
            player = nil;
        }
    }
}

/** 群聊音视频对方加入后振动手机提示 */
+(void)vibratingCellphone{
    //手机振动
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

/** 音视频邀请声音播放 */
+(void)playVoiceForAudioAndVideo:(void(^ _Nonnull)(AVAudioPlayer *_Nullable _avaudio))playerBack{
    
    //手机振动
    AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    
    NSError *error;
    AVAudioPlayer *player;
    
    @try {
        
        NSURL *fileUrl = [[NSBundle mainBundle] URLForResource:@"video_chat_tip_receiver" withExtension:@"m4a"];
        
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileUrl error:&error];
        //player.volume = 1.0;//最大声音
        
        //numberOfLoops 循环次数，如果要单曲循环，设置为负数
        player.numberOfLoops = -1;
        
        [player play];
        
        playerBack(player);
    } @catch (NSException *exception) {
        MMLog(@"音视频邀请声音播放异常！详见：%@",exception);
    } @finally {
        
        //因为音视频邀请是重复播放，当接受或者邀请超时后才关闭播放
        //if (player) {
        //    [player stop];
        //    player = nil;
        //}
    }
}
//MARK: - 设置富文本
/**! 设置富文本 */
+(NSAttributedString *)setAttributeStringText:(NSString *)strFullText
                              andFullTextFont:(UIFont *)textFont
                             andFullTextColor:(UIColor *)textColor
                               withChangeText:(NSString *)changeText
                               withChangeFont:(UIFont *)changFont
                              withChangeColor:(UIColor *)changeColor
                                isLineThrough:(BOOL)lineThrough{
    
    NSDictionary<NSAttributedStringKey,id> *dicAttr;
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:strFullText];
    
    //需要改变的文本
    NSRange range = [strFullText rangeOfString:changeText];
    
    dicAttr = @{
                NSFontAttributeName:changFont,
                NSForegroundColorAttributeName:changeColor
                };
    
    if (lineThrough) {
        [dicAttr setValue:[[NSNumber alloc] initWithInt:1] forKey:NSStrikethroughStyleAttributeName];
    }
    [attributeString addAttributes:dicAttr range:range];
    
    //不需要改变的文本
    NSString *oldText = [strFullText stringByReplacingOccurrencesOfString:changeText withString:@""];
    range = [strFullText rangeOfString:oldText];
    
    dicAttr = @{
                NSFontAttributeName:textFont,
                NSForegroundColorAttributeName:textColor
                };
    [attributeString addAttributes:dicAttr range:range];
    
    return attributeString;
}


//MARK: - 获取文本的宽度
/**!
 * 获取文本的宽度
 */
+(CGFloat)getWidthForString:(NSString *_Nonnull)value
                andFontSize:(UIFont *_Nonnull)font
                  andHeight:(CGFloat)height{
    CGSize sizeToFit = [value sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX, height) lineBreakMode:NSLineBreakByWordWrapping];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    
    return sizeToFit.width;
}

/** 获取文本的高度 */
+(CGFloat)getHeightForString:(NSString *_Nonnull)value
                 andFontSize:(UIFont *_Nonnull)font
                    andWidth:(CGFloat)width{
    CGSize sizeToFit = [value sizeWithFont:font constrainedToSize:CGSizeMake(width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];//此处的换行类型（lineBreakMode）可根据自己的实际情况进行设置
    
    return sizeToFit.height;
}

/**! 获取第一个首字母 */
+(NSString *_Nonnull)getFirstLetter:(NSString *_Nullable)strInput {
    
    if (strInput && ![strInput isEqualToString:@""]){
        NSMutableString *ms = [[NSMutableString alloc] initWithString:strInput];
        CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformMandarinLatin, NO);
        CFStringTransform((__bridge CFMutableStringRef)ms, NULL, kCFStringTransformStripDiacritics, NO);
        NSArray *pyArr = [ms componentsSeparatedByString:@" "];
        if (pyArr && [pyArr count] > 0) {
            NSString *strResult = [[NSString stringWithFormat:@"%@",pyArr.firstObject] substringToIndex:1];
            return [strResult uppercaseString];
        }
    }
    
    return @"#";
}

@end

@implementation AssistObject


#pragma mark - AlertDelegate

- (void)alertView:(HHUIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kCommonAlertTag) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (buttonIndex == 1) {
//                _callbackForAlert( YES );
                alertView.dismissCallback( YES );
            }
            else {
                alertView.dismissCallback( NO );
//                _callbackForAlert( NO );
            }
//            _callbackForAlert = NULL;
        });
    }
    
}

@end

int getFileSize(NSString *path)
{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else
    {
        return -1;
    }
}


NSString* getDeviceVersion()
{

    NSString *deviceType;
    struct utsname systemInfo;
    uname(&systemInfo);
    deviceType = [NSString stringWithCString:systemInfo.machine
                                    encoding:NSUTF8StringEncoding];
    return deviceType;
}

NSString * platformString ()
{
    NSString *platform = getDeviceVersion();
    //iPhone
    if ([platform isEqualToString:@"iPhone1,1"])   return@"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])   return@"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])   return@"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])   return@"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,2"])   return@"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])   return@"iPhone 4 (CDMA)";
    if ([platform isEqualToString:@"iPhone4,1"])   return @"iPhone 4s";
    if ([platform isEqualToString:@"iPhone5,1"])   return @"iPhone 5 (GSM/WCDMA)";
    if ([platform isEqualToString:@"iPhone4,2"])   return @"iPhone 5 (CDMA)";
    
    //iPot Touch
    if ([platform isEqualToString:@"iPod1,1"])     return@"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])     return@"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])     return@"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])     return@"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])     return@"iPod Touch 5G";
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])     return@"iPad";
    if ([platform isEqualToString:@"iPad2,1"])     return@"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])     return@"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])     return@"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])     return@"iPad 2 New";
    if ([platform isEqualToString:@"iPad2,5"])     return@"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad3,1"])     return@"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])     return@"iPad 3 (CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])     return@"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])     return@"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"i386"] || [platform isEqualToString:@"x86_64"])        return@"Simulator";
    
    return platform;
}

BOOL compareStringIdsDiff( NSArray *allphones, NSString *phonesCacheFilePath, NSArray **addlist, NSArray **removelist ) {
    NSMutableArray *cachephones = [NSMutableArray arrayWithContentsOfFile:phonesCacheFilePath];
   
    NSMutableArray *sortedAllPhones = [NSMutableArray arrayWithArray:allphones];
    [sortedAllPhones sortUsingSelector:@selector(compare:)];
    
    NSMutableArray *maAddList = [NSMutableArray array];
    NSMutableArray *maRemoveList = [NSMutableArray array];
    BOOL hasChange = NO;
    if (cachephones) {
        // 有过记录
        NSMutableIndexSet *shouldRemoveIndex = [NSMutableIndexSet indexSet];
        
        int lindx, rindx; lindx = rindx = 0;
        
        do {
            if ( lindx >= cachephones.count) {
                // 左边没有了，右边全部增加到addlist
                NSArray *subarray = [sortedAllPhones subarrayWithRange:NSMakeRange(rindx, sortedAllPhones.count - rindx)];
                [maAddList addObjectsFromArray:subarray];
                break;
            }
            
            if ( rindx >= sortedAllPhones.count) {
                // 右边没有了，左边全部回到removelist
                NSArray *subarray = [cachephones subarrayWithRange:NSMakeRange(lindx, cachephones.count - lindx)];
                [maRemoveList addObjectsFromArray:subarray];
                break;
            }
            
    
            long long lv = [cachephones[lindx] longLongValue];
            long long rv = [sortedAllPhones[rindx] longLongValue];
            if ( lv > rv ) {
                [maAddList addObject:sortedAllPhones[rindx]];
                rindx++;
            }
            else if (lv == rv) {
                lindx++;
                rindx++;
            }
            else {
                [maRemoveList addObject:cachephones[lindx]];
                [shouldRemoveIndex addIndex:lindx];
                lindx++;
            }
        } while (1);
        
        if (maAddList.count > 0 || maRemoveList.count > 0) {
            hasChange = YES;
        }
    }
    else {
        
    }
    
    [sortedAllPhones writeToFile:phonesCacheFilePath atomically:NO];
    
    if (addlist) {
        *addlist = maAddList;
    }
    if (removelist) {
        *removelist = maRemoveList;
    }
    
    return hasChange;
}
