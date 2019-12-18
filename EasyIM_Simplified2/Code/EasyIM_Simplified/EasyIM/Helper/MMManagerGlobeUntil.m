//
//  MMManagerGlobeUntil.m
//  EasyIM
//
//  Created by momo on 2019/5/8.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMManagerGlobeUntil.h"

@implementation MMManagerGlobeUntil

+ (instancetype)sharedManager {
    static MMManagerGlobeUntil *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[MMManagerGlobeUntil alloc] init];
    });
    
    return _sharedManager;
}

- (instancetype)init
{
    
    self = [super init];
    if (self) {
        self.isNetConnect = YES;
        self.isWIFI = NO;
    }
    
    return self;
}


- (void)managerReachability
{
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager startMonitoring];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                NSLog(@"未知网络状态");
                [MMManagerGlobeUntil sharedManager].isNetConnect = YES;
                [MMManagerGlobeUntil sharedManager].isWIFI = NO;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                NSLog(@"无网络");
                [MMManagerGlobeUntil sharedManager].isNetConnect = NO;
                [MMManagerGlobeUntil sharedManager].isWIFI = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                NSLog(@"蜂窝数据网");
                [MMManagerGlobeUntil sharedManager].isNetConnect = YES;
                [MMManagerGlobeUntil sharedManager].isWIFI = NO;
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WiFi网络");
                [MMManagerGlobeUntil sharedManager].isNetConnect = YES;
                [MMManagerGlobeUntil sharedManager].isWIFI = YES;
                break;
            default:
                
                break;
        }
        if(status ==AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            NSLog(@"有网");
        } else {
            NSLog(@"没有网");
            
        }
    }];
}

//
// 参考: AFHTTPRequestIOperation.m
//
NSString* MMDescriptionForError(NSError* error) {
    // TODO: 优化错误的处理方式:
    // 1. 服务器错误
    // 2. 网络错误
    
    // 如果服务器返回了错误，那么就直接显示服务器返回的错误，如果服务器没有返回错误，就使用之前默认的错误文案
    if ([error.userInfo[@"error_msg"] isEqualToString:@""]) {
        return error.userInfo[@"error_msg"];
    }
    
#ifdef IN_SPEAKOUT
    NSString *networkUnreachableMessage = @"无网络，请检查网络设置";
#else
    NSString *networkUnreachableMessage = @"网络失踪了，请检查你的网络环境";
#endif
    
    if ([error.domain isEqualToString:NSURLErrorDomain]) {
        // Note: If new error codes are added here, be sure to document them in the header.
        if (error.code == NSURLErrorTimedOut) {
#ifdef IN_FIVEONETALK
            return @"网络连接失败，请重试";
#else
            return @"连接超时";
#endif
            
        } else if (error.code == NSURLErrorNotConnectedToInternet) {
            return networkUnreachableMessage;
        }else if(error.code == NSURLErrorCannotConnectToHost){
            return networkUnreachableMessage;
        }else if(error.code == 0){
            return error.userInfo[@"NSLocalizedDescription"];
        }else {
            return networkUnreachableMessage;
        }
    } else if ([error.domain isEqualToString: AFURLResponseSerializationErrorDomain]) {
        if (error.code == NSURLErrorBadURL) {
            return @"URL格式错误";
        } else if (error.code == NSURLErrorBadServerResponse) {
            return @"服务器错误";
        } else if (error.code == NSURLErrorCannotDecodeContentData) {
            return @"服务器返回数据格式错误";
        }
    }
    return networkUnreachableMessage;
}

@end
