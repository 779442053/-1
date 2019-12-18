//
//  MMRecentConVersationModel.m
//  EasyIM
//
//  Created by momo on 2019/5/14.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMRecentConVersationModel.h"
#import "MMMessageConst.h"

@implementation MMRecentConVersationModel

- (void)setLatestMessage:(MMMessage *)latestMessage {
    
    self.latestMsgTimeStamp = latestMessage.timestamp;
    self.latestMsgStr = [MMRecentConVersationModel getMessageStrWithMessage:latestMessage];
    
}

- (instancetype)initWithMessageModel:(MMMessage *)message conversationId:(NSString *)conversationId{
    if (self = [super init]) {
        
        self.latestMessage = message;
        self.userName = conversationId;
    }
    return self;
}


+ (NSString *)getMessageStrWithMessage:(MMMessage *)message {
    
    NSString *latestMsgStr;
    switch (message.messageType) {
        case MMMessageType_Text:
            latestMsgStr = message.slice.content;
            break;
            
        case MMMessageType_Image:
            latestMsgStr = @"[图片]";
            break;
            
        case MMMessageType_Location:
            latestMsgStr = @"[定位]";
            break;
            
        case MMMessageType_Voice:
            latestMsgStr = @"[语音]";
            break;
            
        case MMMessageType_Video:
            latestMsgStr = @"[视频]";
            break;
            
        case MMMessageType_Doc:
            latestMsgStr = @"[文件]";
            break;
        
        case MMMessageType_NTF:
             latestMsgStr = @"[系统]";
            break;
        case MMMessageType_Emp:
            latestMsgStr = @"";
            NSLog(@"没有消息");
            break;
        default:
            latestMsgStr = @"错误";
            break;
    }
    return latestMsgStr;
}

+ (MMMessageType)getMessageType:(NSString *)type
{
    if ([type isEqualToString:@"text"]) {
        return MMMessageType_Text;
    }else if ([type isEqualToString:@"pic"]){
        return MMMessageType_Image;
    }else if ([type isEqualToString:@"loc"]){
        return MMMessageType_Location;
    }else if ([type isEqualToString:@"voice"]){
        return MMMessageType_Voice;
    }else if ([type isEqualToString:@"video"]){
        return MMMessageType_Video;
    }else if ([type isEqualToString:@"file"]){
        return MMMessageType_Doc;
    }else if ([type isEqualToString:@"sys"]){
        return MMMessageType_NTF;
    }else{
        return 0;
    }
}

@end
