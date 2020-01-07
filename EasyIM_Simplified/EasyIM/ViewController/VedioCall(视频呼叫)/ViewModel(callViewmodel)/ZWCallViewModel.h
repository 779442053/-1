//
//  ZWCallViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/6.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWCallViewModel : ZWBaseViewModel
@property(nonatomic,strong)RACCommand *GetFriendStatedCommand;
@end

NS_ASSUME_NONNULL_END
