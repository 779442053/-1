//
//  MMTools.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMTools : NSObject

+(BOOL)hasPermissionToGetCamera;

/**! 开启设置权限 */
+(void)openSetting;

@end

NS_ASSUME_NONNULL_END
