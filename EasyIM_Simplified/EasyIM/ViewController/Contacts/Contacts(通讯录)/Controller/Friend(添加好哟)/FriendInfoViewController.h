//
//  FriendInfoViewController.h
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/18.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 好友信息
 */
@interface FriendInfoViewController : MMBaseViewController

@property (nonatomic,   copy) NSString  *userId;
@property (nonatomic, assign) BOOL isFriend;

@end

NS_ASSUME_NONNULL_END
