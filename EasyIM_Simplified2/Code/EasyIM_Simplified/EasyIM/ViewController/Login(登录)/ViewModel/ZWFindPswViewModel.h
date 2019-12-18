//
//  ZWFindPswViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWFindPswViewModel : ZWBaseViewModel
@property(nonatomic,strong)RACCommand *CodeCommand;
@property(nonatomic,strong)RACCommand *RegistCommand;
@end

NS_ASSUME_NONNULL_END
