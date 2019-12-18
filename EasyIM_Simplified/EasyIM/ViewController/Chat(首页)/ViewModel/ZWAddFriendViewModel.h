//
//  ZWAddFriendViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWAddFriendViewModel : ZWBaseViewModel
@property(nonatomic,strong) RACCommand *addFriendCommand;
@property(nonatomic,strong) RACCommand *addGroupCommand;
@property(nonatomic,strong) RACCommand *searchFriendCommand;
@property(nonatomic,strong) RACCommand *searchMoreFriendCommand;
@property(nonatomic,strong) RACCommand *searchGroupCommand;
@property(nonatomic,strong) RACCommand *searchMoreGroupCommand;
@end

NS_ASSUME_NONNULL_END
