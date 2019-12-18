//
//  MMTools.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMTools.h"

@implementation MMTools

+(BOOL)hasPermissionToGetCamera
{
    BOOL hasPermission = YES;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        hasPermission = NO;
    }
    return hasPermission;
}


/**! 开启设置权限 */
+(void)openSetting{
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}
@end
