//
//  ZWLoginViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWLoginViewModel : ZWBaseViewModel

@property(nonatomic,strong)RACCommand *preLoginCommand;
@property(nonatomic,strong)RACCommand *LoginCommand;
@end

NS_ASSUME_NONNULL_END
