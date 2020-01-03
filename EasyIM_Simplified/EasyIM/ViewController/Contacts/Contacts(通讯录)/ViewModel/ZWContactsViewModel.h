//
//  ZWContactsViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/27.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWContactsViewModel : ZWBaseViewModel
@property(nonatomic,strong) RACCommand *requestCommand;
@property(nonatomic,strong) RACCommand *requestMoreCommand;
@property(nonatomic,strong) RACCommand *restUserNameCommand;
@property(nonatomic,strong) RACCommand *deleteUserCommand;
@property(nonatomic,strong) RACCommand *GetPushdataCommand;
@end

NS_ASSUME_NONNULL_END
