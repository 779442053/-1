//
//  MMThemeViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/24.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 修改个性签名
 */
@interface MMThemeViewController : MMBaseViewController

@property (nonatomic, copy) void (^changeTheme)(NSString *theme);

@property (nonatomic, strong) NSString *theme;

@end

NS_ASSUME_NONNULL_END
