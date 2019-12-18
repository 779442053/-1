//
//  ZWGroudDetailViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWGroudDetailViewModel : ZWBaseViewModel
@property(nonatomic,strong)RACCommand *getGroupPeopleListCommand;
@property(nonatomic,strong)RACCommand *setGroupSDNCommand;
@property(nonatomic,strong)RACCommand *deleteGroupWithGroupId;
@property(nonatomic,strong)RACCommand *exitGroupWithGroupid;
@property(nonatomic,strong)RACCommand *setGroupChatBg;
@end

NS_ASSUME_NONNULL_END
