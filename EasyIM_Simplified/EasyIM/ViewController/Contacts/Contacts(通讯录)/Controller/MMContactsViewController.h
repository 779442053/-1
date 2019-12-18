//
//  MMContactsViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"
@class ContactsModel;

NS_ASSUME_NONNULL_BEGIN

/**
 * 通讯录
 */
@interface MMContactsViewController : MMBaseViewController

/** 当前好友集合 */
@property(nonatomic,copy,readonly) NSArray<ContactsModel *>* _Nullable arrData;

+(MMContactsViewController *__weak)shareInstance;

@end

NS_ASSUME_NONNULL_END
