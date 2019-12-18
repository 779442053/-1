//
//  MMErrorManager.h
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMErrorManager : NSObject
// 服务器定义错误信息
#define MM_REQUEST_TIMEOUT                @"请求超时"
#define MM_REQUEST_PARAM_ERROR            @"入参错误"
#define MM_REQUEST_ERROR                  @"请求失败"
#define MM_SERVER_MAINTENANCE_UPDATES     @"用户状态丢失"
// SDK内定义错误信息
#define MM_NETWORK_DISCONNECTED           @"网络断开"
#define MM_LOCAL_REQUEST_TIMEOUT          @"本地请求超时"
#define MM_JSON_PARSE_ERROR               @"JSON 解析错误"
#define MM_LOCAL_PARAM_ERROR              @"socket 链接中断"

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode;
@end

NS_ASSUME_NONNULL_END
