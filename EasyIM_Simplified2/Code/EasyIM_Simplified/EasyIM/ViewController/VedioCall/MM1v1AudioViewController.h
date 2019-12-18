//
//  MM1v1AudioViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/8.
//  Copyright © 2019年 Looker. All rights reserved.
//

/*
 *音频
 */
#import "MM1v1CallViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MM1v1AudioViewController : MM1v1CallViewController

/** 群语音收邀请的用户信息 */
@property (nonatomic, copy, nullable) NSArray *arrUserDatas;

@end

NS_ASSUME_NONNULL_END
