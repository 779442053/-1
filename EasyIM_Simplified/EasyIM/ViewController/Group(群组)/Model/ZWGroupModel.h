//
//  ZWGroupModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/27.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWGroupModel : ZWBaseModel
@property(nonatomic,copy)NSString *groupname;
@property(nonatomic,copy)NSString *gid;
@property (nonatomic, copy) NSString *cmd;
@end

NS_ASSUME_NONNULL_END
