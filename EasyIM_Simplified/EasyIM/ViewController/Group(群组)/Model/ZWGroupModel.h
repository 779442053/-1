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
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *ID;
@property (nonatomic, copy) NSString *notice;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *creatorID;
@property (nonatomic, copy) NSString *type;
@end

NS_ASSUME_NONNULL_END
