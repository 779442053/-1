//
//  MMChatLinkManCell.h
//  EasyIM
//
//  Created by apple on 2019/8/19.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMChatMessageBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 联系人 自定义列
 */
@interface MMChatLinkManCell : MMChatMessageBaseCell

/** 联系人(名片)点击 */
@property(nonatomic, copy, nullable) void(^cellUserClick)(NSString *strUserId);

@end

NS_ASSUME_NONNULL_END
