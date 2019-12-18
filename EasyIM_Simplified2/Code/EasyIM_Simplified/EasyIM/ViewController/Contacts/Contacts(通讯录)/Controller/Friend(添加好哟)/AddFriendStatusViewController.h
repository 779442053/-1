//
//  AddFriendStatusViewController.h
//  EasyIM
//
//  Created by momo on 2019/4/10.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "MMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddFriendStatusViewController : MMBaseViewController

@property (nonatomic, strong) NSMutableArray *newFriendsArr;

@property (nonatomic, copy) void (^changeStatusBlock)(NSMutableArray *arr);

@end

NS_ASSUME_NONNULL_END
