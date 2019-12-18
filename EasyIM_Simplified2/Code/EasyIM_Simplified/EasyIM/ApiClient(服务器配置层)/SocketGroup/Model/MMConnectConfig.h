//
//  MMConnectConfig.h
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMConnectConfig : NSObject

/**
  通信地址
 */
@property (nonatomic, strong) NSString *host;
/**
  通信端口号
 */
@property (nonatomic, assign) NSInteger port;

@end

NS_ASSUME_NONNULL_END
