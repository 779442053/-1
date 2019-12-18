//
//  NSObject+MMAlert.h
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


/**
 在NSObject中 可直接调用Alert
 */
@interface NSObject (MMAlert)


/**
 弹起提示框

 @param aMsg 提示框信息
 */
- (void)showAlertWithMessage:(NSString *)aMsg;

/**
 弹起提示框

 @param aTitle 提示框标题
 @param aMsg 提示框信息
 */
- (void)showAlertWithTitle:(NSString *)aTitle
                   message:(NSString *)aMsg;

@end

NS_ASSUME_NONNULL_END
