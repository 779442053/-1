//
//  ZWMeViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/3.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWMeViewModel : ZWBaseViewModel
@property(nonatomic,strong)RACCommand *getMyUserInfoCommand;
@property(nonatomic,strong)RACCommand *addFriendCommand;
@property(nonatomic,strong)RACCommand *add2GroupCommand;
@end

NS_ASSUME_NONNULL_END
