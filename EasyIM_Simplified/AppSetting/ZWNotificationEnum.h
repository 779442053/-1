//
//  ZWNotificationEnum.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/27.
//  Copyright © 2019 Looker. All rights reserved.
//

#ifndef ZWNotificationEnum_h
#define ZWNotificationEnum_h
//呼叫流程通知类型的定义
typedef NS_ENUM(NSUInteger, BULLETIN_FLOW_TYPE) {
    kBulletinFlowFriend  = 0, //好友添加流程
    kBulletinFlowGroup  = 1,  //群组添加流程
    kBulletinFlowCallUser = 10,//呼叫用户流程 -- 未完成
    kBulletinFlowCallGroup = 11, //群呼叫流程 -- 未完成
};

#endif /* ZWNotificationEnum_h */
