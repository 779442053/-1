//
//  ZWChatLocationMessageCell.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "MMChatMessageBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWChatLocationMessageCell : MMChatMessageBaseCell
/** 地址点击 */
@property(nonatomic, copy, nullable) void(^AddeesscellUserClick)(NSString *address,float jingdu ,float weidu);
@end

NS_ASSUME_NONNULL_END
