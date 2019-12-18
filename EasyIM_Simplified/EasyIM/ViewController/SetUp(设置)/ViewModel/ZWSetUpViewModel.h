//
//  ZWSetUpViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWSetUpViewModel : ZWBaseViewModel
@property(strong,nonatomic)RACCommand *changePswCommand;
@end

NS_ASSUME_NONNULL_END
