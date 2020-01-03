//
//  ZWRegistViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWRegistViewModel : ZWBaseViewModel
@property(nonatomic,strong)RACCommand *CodeCommand;
@property(nonatomic,strong)RACCommand *RegistCommand;
@property(nonatomic,strong)RACCommand *ForgetPswCommand;
@end

NS_ASSUME_NONNULL_END
