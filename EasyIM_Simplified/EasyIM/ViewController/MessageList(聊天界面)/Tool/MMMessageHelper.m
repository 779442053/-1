//
//  MMMessageHelper.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMMessageHelper.h"
#import "MMMessageFrame.h"
#import "MMMessageConst.h"
#import "MMRecordManager.h"
#import "MMMediaManager.h"
#import "MMVideoManager.h"
#import "MMFileTool.h"
#import "NSDate+Extension.h"
#import "VoiceConverter.h"
#import "MMReceiveMessageModel.h"
#define lastUpdateKey [NSString stringWithFormat:@"%@-%@",[MMUser currentUser].eId,@"LastUpdate"]
#define groupInfoLastUpdateKey [NSString stringWithFormat:@"%@-%@",[MMUser currentUser].eId,@"groupInfoLastUpdate"]
#define directLastUpdateKey [NSString stringWithFormat:@"%@-%@",[MMUser currentUser].eId,@"directLastUpdate"]
@implementation MMMessageHelper
// 获取语音消息时长
+ (CGFloat)getVoiceTimeLengthWithPath:(NSString *)path
{
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:path] options:nil];
    CMTime audioDuration = audioAsset.duration;
    CGFloat audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    return audioDurationSeconds;
}
+ (CGRect)photoFramInWindow:(UIButton *)photoView
{
    return [photoView convertRect:photoView.bounds toView:[UIApplication sharedApplication].keyWindow];
}
+ (CGRect)photoLargerInWindow:(UIButton *)photoView
{
    //    CGSize imgSize     = photoView.imageView.image.size;
    CGSize  imgSize    = photoView.currentBackgroundImage.size;
    CGFloat appWidth   = [UIScreen mainScreen].bounds.size.width;
    CGFloat appHeight  = [UIScreen mainScreen].bounds.size.height;
    CGFloat height     = imgSize.height / imgSize.width * appWidth;
    CGFloat photoY     = 0;
    if (height < appHeight) {
        photoY         = (appHeight - height) * 0.5;
    }
    return CGRectMake(0, photoY, appWidth, height);
}

//根据消息类型返回MsgID
+ (NSString *)msgIDWithType:(NSString *)type andToUserID:(NSString *)toUserID{
    NSString *dateStr = [self timeFormatWithDate2:[self currentMessageTime]];
    int x = arc4random() % 100000;
    NSString *msgID = [NSString stringWithFormat:@"%@_%05d_%@_%@",dateStr,x,[ZWUserModel currentUser].userId,toUserID];
    return msgID;
}

// 根据消息类型得到cell的标识
+ (NSString *)cellTypeWithMessageType:(NSString *)type{
    NSInteger tag = [type integerValue];
    switch (tag) {
        case 1:
            return TypeText;
            break;
        case 2:
            return TypeVoice;
            break;
        case 3:
            return TypePic;
            break;
        case 4:
            return TypeVideo;
            break;
        case 5:
            return TypeFile;
            break;
        default:
            return type;
            break;
    }
}

// current message time
+ (NSInteger)currentMessageTime
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSInteger iTime     = (NSInteger)(time * 1000);
    return iTime;
}

// time format
+ (NSString *)timeFormatWithDate:(NSInteger)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSString *date = [formatter stringFromDate:currentDate];
    return date;
}


+ (NSString *)timeFormatWithDate2:(NSInteger)time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyMMdd-HHmmss"];
    NSDate * currentDate = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSString *date = [formatter stringFromDate:currentDate];
    return date;
    
}

+ (NSDictionary *)fileTypeDictionary
{
    NSDictionary *dic = @{
                          @"mp3":@1,@"mp4":@2,@"mpe":@2,@"docx":@5,
                          @"amr":@1,@"avi":@2,@"wmv":@2,@"xls":@6,
                          @"wav":@1,@"rmvb":@2,@"mkv":@2,@"xlsx":@6,
                          @"text":@8,@"rm":@2,@"vob":@2,@"ppt":@7,
                          @"aac":@1,@"asf":@2,@"html":@3,@"pptx":@7,
                          @"wma":@1,@"divx":@2,@"htm":@3,@"png":@8,
                          @"ogg":@1,@"mpg":@2,@"pdf":@4,@"jpg":@8,
                          @"ape":@1,@"mpeg":@2,@"doc":@5,@"jpeg":@8,
                          @"gif":@8,@"bmp":@8,@"tiff":@8,@"svg":@8
                          };
    return dic;
}

+ (NSNumber *)fileType:(NSString *)type
{
    NSDictionary *dic = [self fileTypeDictionary];
    return [dic objectForKey:type];
}

+ (UIImage *)allocationImage:(MMFileType)type
{
    switch (type) {
        case MMFileType_Audio:
            return [UIImage imageNamed:@"yinpin"];
            break;
        case MMFileType_Video:
            return [UIImage imageNamed:@"shipin"];
            break;
        case MMFileType_Html:
            return [UIImage imageNamed:@"html"];
            break;
        case MMFileType_Pdf:
            return  [UIImage imageNamed:@"pdf"];
            break;
        case MMFileType_Doc:
            return  [UIImage imageNamed:@"word"];
            break;
        case MMFileType_Xls:
            return [UIImage imageNamed:@"excerl"];
            break;
        case MMFileType_Ppt:
            return [UIImage imageNamed:@"ppt"];
            break;
        case MMFileType_Img:
            return [UIImage imageNamed:@"zhaopian"];
            break;
        case MMFileType_Txt:
            return [UIImage imageNamed:@"txt"];
            break;
        default:
            return [UIImage imageNamed:@"iconfont-wenjian"];
            break;
    }
}


+ (NSString *)timeDurationFormatter:(NSUInteger)duration
{
    float M = duration/60.0;
    float S = duration - (int)M * 60;
    NSString *timeFormatter = [NSString stringWithFormat:@"%02.0lf:%02.0lf",M,S];
    return  timeFormatter;
    
}

@end
