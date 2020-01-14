//
//  ZWSocketConfig.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWSocketConfig.h"

@interface ZWSocketConfig()
@property(nonatomic,readwrite)NSString * ip;
@property(nonatomic,readwrite)uint16_t port;
@property(nonatomic,readwrite)NSTimeInterval timeout;
@property(nonatomic,readwrite)float pingTimeInterval;
@property(nonatomic,readwrite)int reconnectTime;
@property(nonatomic,readwrite)float reconnectTimeInterval;
@end
static ZWSocketConfig * _instance = nil;
@implementation ZWSocketConfig
+ (instancetype)ShareInstance{
    return [self ConfigWithSocketIp:[ZWUserModel currentUser].IP port:[ZWUserModel currentUser].port];
}
+ (instancetype)ConfigWithSocketIp:(NSString*)ip port:(uint16_t)port{
    return [self ConfigWithSocketIp:ip port:port timeout:SG_Socket_Timeout pingTimeInterval:SG_Socket_PingTimeInterval reconnectTime:SG_Socket_ReconnectTime reconnectTimeInterval:SG_Socket_ReconnectTimeInterval];
}
+ (instancetype)ConfigWithSocketIp:(NSString*)ip port:(uint16_t)port timeout:(NSTimeInterval)timeout{
    return [self ConfigWithSocketIp:ip port:port timeout:timeout pingTimeInterval:SG_Socket_PingTimeInterval reconnectTime:SG_Socket_ReconnectTime reconnectTimeInterval:SG_Socket_ReconnectTimeInterval];
}
+ (instancetype)ConfigWithSocketIp:(NSString*)ip port:(uint16_t)port timeout:(NSTimeInterval)timeout pingTimeInterval:(float)pingTimeInterval reconnectTime:(int)reconnectTime reconnectTimeInterval:(float)reconnectTimeInterval{
    if(![self p_checkStringVaildWithStr:ip]){
        return nil;
    }
    if(!port || port <= 0){
        return nil;
    }
    if(timeout <= 0){
        return nil;
    }
    if(pingTimeInterval <= 0){
        return nil;
    }
    if(reconnectTime < 0){
        return nil;
    }
    if(reconnectTimeInterval < 0){
        return nil;
    }
    if(_instance){
        return _instance;
    }else{
        ZWSocketConfig * configM = [[self alloc]init];
        if(!configM.ip){
            configM.ip = ip;
            configM.port = port;
            configM.timeout = timeout;
            configM.pingTimeInterval = pingTimeInterval;
            configM.reconnectTime = reconnectTime;
            configM.reconnectTimeInterval = reconnectTimeInterval;
        }
        return configM;
    }
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    });
    return _instance;
}
// 为了严谨，也要重写copyWithZone 和 mutableCopyWithZone
-(id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}
+ (BOOL)p_checkStringVaildWithStr:(NSString*)str{
    if (!str || [str isEqualToString:@""]) {
        return NO;
    }else{
        return YES;
    }
}

@end
