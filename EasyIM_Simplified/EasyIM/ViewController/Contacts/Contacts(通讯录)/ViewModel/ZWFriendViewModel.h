//
//  ZWFriendViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWFriendViewModel : ZWBaseViewModel
@property(nonatomic,strong) RACCommand *addFriendCommand;
//@property(nonatomic,strong) RACCommand *addFriendMsgCommand;
@property(nonatomic,strong) RACCommand *acceptFriendCommand;
@property(nonatomic,strong) RACCommand *rejectFriendCommand;
@property(nonatomic,strong) RACCommand *setmemoFriendCommand;
@property(nonatomic,strong) RACCommand *GetUserInfoCommand;
@property(nonatomic,strong) RACCommand *deleteUserCommand;
@end

NS_ASSUME_NONNULL_END
