//
//  AddFriViewController.h
//  EasyIM
//
//  Created by 魏冰杰 on 2019/8/27.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"
#import "SearchFriendModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddFriViewController : MMBaseViewController

@property (nonatomic, strong) SearchFriendModel *model;

//来自哪里
@property(nonatomic,copy)NSString *FromType;
@property(nonatomic,copy)NSString *userID;
@end

NS_ASSUME_NONNULL_END
