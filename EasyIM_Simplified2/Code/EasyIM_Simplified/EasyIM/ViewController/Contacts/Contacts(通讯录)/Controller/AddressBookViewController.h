//
//  AddressBookViewController.h
//  EasyIM
//
//  Created by apple on 2019/8/24.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 手机通讯录
 */
@interface AddressBookViewController : MMBaseViewController

/** 通讯录数据 */
@property(nonatomic,copy,nullable) NSArray *arrAddressData;

/** 添加好友完成回调 */
@property(nonatomic,copy) void(^_Nullable addFriendFinishBack)(void);

@end

NS_ASSUME_NONNULL_END
