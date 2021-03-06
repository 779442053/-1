//
//  EditFriendRemarkController.h
//  EasyIM
//
//  Created by apple on 2019/7/3.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 编辑好友备注信息
 */
@interface EditFriendRemarkController : MMBaseViewController

/** 好友的编号(需要传值指定) */
@property(nonatomic, copy, nonnull) NSString *strRemarkId;
@property(nonatomic, copy, nonnull) NSString *NickNmae;
@end

NS_ASSUME_NONNULL_END
