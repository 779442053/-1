//
//  ZWChartViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWChartViewModel : ZWBaseViewModel
@property (nonatomic, strong) RACCommand *GetChartLishDataCommand;
@property (nonatomic, strong) RACCommand *GetGroupChartLishDataCommand;
@property(nonatomic,strong) RACCommand *requestCommand;
@property(nonatomic,strong) RACCommand *requestMoreCommand;
//获取群成员
@property(nonatomic,strong) RACCommand *getGroupPeopleListCommand;
@end

NS_ASSUME_NONNULL_END
