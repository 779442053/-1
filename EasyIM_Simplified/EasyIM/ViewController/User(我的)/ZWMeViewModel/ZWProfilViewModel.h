//
//  ZWProfilViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWProfilViewModel : ZWBaseViewModel
@property(nonatomic,strong) RACCommand *requestCommand;
@property(nonatomic,strong) RACCommand *updateUserInfoCommand;
@property(nonatomic,strong) RACCommand *uploadUserImageCommand;

//群修改
@property(nonatomic,strong) RACCommand *UpdateGroupNameCommand;

@end

NS_ASSUME_NONNULL_END
