//
//  ZWChatViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWChatViewModel : ZWBaseViewModel
@property(nonatomic,strong) RACCommand *requestCommand;
@property(nonatomic,strong) RACCommand *GetPushdataCommand;
@property(nonatomic,strong) RACCommand *addFriendCommand;
@property(nonatomic,strong) RACCommand *socketContactCommand;
@end

NS_ASSUME_NONNULL_END
