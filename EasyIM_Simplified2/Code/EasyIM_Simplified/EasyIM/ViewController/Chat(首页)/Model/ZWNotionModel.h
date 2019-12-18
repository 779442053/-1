//
//  ZWNotionModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/16.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWNotionModel : ZWBaseModel
@property(nonatomic,copy)NSString *uid;
@property(nonatomic,copy)NSString *kFlow;
@property(nonatomic,copy)NSString *time;
@property(nonatomic,copy)NSString *fromName;
@property(nonatomic,copy)NSString *groupID;
@property(nonatomic,copy)NSString *toID;
@property(nonatomic,copy)NSString *fromID;
@property(nonatomic,copy)NSString *fromPhoto;
/***/
@property(nonatomic,copy)NSString *bulletinType;
@property(nonatomic,copy)NSString *fromNick;
@property(nonatomic,copy)NSString *webrtcId;
@property(nonatomic,copy)NSString *msg;
//@property(nonatomic,copy)NSString *fromNick;
//@property(nonatomic,copy)NSString *
@end

NS_ASSUME_NONNULL_END
