//
//  ZWNotificationEnumTwo.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/27.
//  Copyright © 2019 Looker. All rights reserved.
//

#ifndef ZWNotificationEnumTwo_h
#define ZWNotificationEnumTwo_h
//通知类型定义
typedef NS_ENUM(NSUInteger, BULLETIN_TYPE) {
    //BULLETIN_TYPE_NONE = -1, //未知定义
     BULLETIN_TYPE_NONE = -1,
    BULLETIN_TYPE_ADD_FRIEND = 0,//请求加好友
    BULLETIN_TYPE_ACCEPT_FRIEND =1,//同意加好友（群）
    BULLETIN_TYPE_REJECT_FRIEND = 2,//拒绝加好友（群）
    BULLETIN_TYPE_BE_ACCEPT_FRIEND =3,//被同意加好友(群)
    BULLETIN_TYPE_BE_REJECT_FRIEND =4,//被拒绝加好友(群)
    BULLETIN_TYPE_BE_DEL_FRIEND =5,//被好友移除（群）
    BULLETIN_TYPE_APPLY_JOIN_GROUP =6, //申请加入（群）
    //2019-12-25 hrc新增
    BULLETIN_TYPE_EXIT_GROUP = 7,  //退出组织 (群)
    BULLETIN_TYPE_DELETE_GROUP = 8,//解散组织 (群)
    BULLETIN_TYPE_BE_KICK_OUT_GROUP = 9,//被踢出组织 (群)
    BULLETIN_TYPE_CHANGE_INFO = 10,//信息变更 (群)
    BULLETIN_TYPE_BE_INVITE_INTO_GROUP = 11,//邀请加入（群）
    BULLETIN_TYPE_NEW_GROUP_MEMBER = 12,//新成员加入（群）
// 2019-01-12 ------属于 FlowCallUser FlowCallGroup
    //下面两值的用法，用来提醒用户有呼叫你，如果该（群呼叫）还存在，要支持加入群呼叫。
    BULLETIN_TYPE_CALLUSER  = 100,
    BULLETIN_TYPE_CALLGROUP = 200
};

#endif /* ZWNotificationEnumTwo_h */
