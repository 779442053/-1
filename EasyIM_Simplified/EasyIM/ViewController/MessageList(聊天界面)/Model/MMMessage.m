//
//  MMMessage.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMMessage.h"

@implementation MMMessage
{
    int msgid ;
}
- (instancetype)initWithToUser:(NSString *)toUser
                    toUserName:(NSString *)toUserName
                      fromUser:(NSString *)fromUser
                  fromUserName:(NSString *)fromUserName
                      chatType:(NSString *)chatType
                      isSender:(BOOL)isSender
                           cmd:(NSString *)cmd
                         cType:(MMConversationType)cType
                   messageBody:( MMChatContentModel *)body{
    
    if (self = [super init]) {
        
        NSString *sessionId =  [ZWUserModel currentUser].sessionID;
        
        _toID = toUser;
        _toUserName = toUserName;
        _fromUserName = fromUserName;
        _fromID = fromUser;
        _type = chatType;//单聊,群聊,视频,语音
        _sessionID = sessionId;
        //张威威  在这里,配置messid  因为进到聊天界面,会创建当前message 对象,保证唯一性和全局性
        _msgID = [self messageIDWithFromid:fromUser ToId:toUser];
        _isSender = isSender;
        _cType = cType;
        self.cmd = cmd;
        self.slice = body;
    }
    return self;

}
-(NSString *)messageIDWithFromid:(NSString *)fromid ToId:(NSString *)toid{
     msgid ++;
    NSString *timestamp = [MMDateHelper getMessageNowTime];
    NSString *sequence = [NSString stringWithFormat:@"%05d",msgid];
    ZWWLog(@"生成的有规律的五位数字=%@",sequence)
    NSString *mid = [NSString stringWithFormat:@"%@_%@_%@_%@",timestamp,sequence,fromid,toid];
    ZWWLog(@"生成的mid=%@",mid)
    return mid;
}

@end


@implementation MMChatContentModel

- (NSString *)content{
    
    if (!_content) return @"";
    else{
        if ([_content hasPrefix:@"<!"] || [_content hasPrefix:@"u"] || [_content hasPrefix:@"[u"]) {
            NSString *strTemp = [[_content stringByReplacingOccurrencesOfString:@"<![CDATA[" withString:@""] stringByReplacingOccurrencesOfString:@"]]>" withString:@""];
            
            if ([strTemp hasPrefix:@"[u"]) {
                NSMutableString *nsstrmutable = [NSMutableString stringWithString:strTemp];
                [nsstrmutable replaceOccurrencesOfString:@"[" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, nsstrmutable.length)];
                [nsstrmutable replaceOccurrencesOfString:@"u" withString:@"\\U" options:NSCaseInsensitiveSearch range:NSMakeRange(0, nsstrmutable.length)];
                [nsstrmutable replaceOccurrencesOfString:@"]" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, nsstrmutable.length)];
                
                strTemp = [nsstrmutable copy];
            }
            
            return [strTemp replaceUnicode];
        }
        else return _content;
    }
}

@end
