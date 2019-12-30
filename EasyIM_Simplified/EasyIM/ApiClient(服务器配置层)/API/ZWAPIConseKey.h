//
//  ZWAPIConseKey.h
//  EasyIM
//
//  Created by step on 2019/10/31.
//  Copyright © 2019 step. All rights reserved.
//
#pragma ===========这里是API接口 =============
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWAPIConseKey : NSObject
// 服务地址
FOUNDATION_EXTERN NSString *const HTURL;
FOUNDATION_EXTERN NSString *const HTURL_Test;
/*****  登陆注册忘记密码  *****/
FOUNDATION_EXTERN NSString *const Login;
FOUNDATION_EXTERN NSString *const Regist;
FOUNDATION_EXTERN NSString *const PreLogin;
FOUNDATION_EXTERN NSString *const ForGetpsw;
FOUNDATION_EXTERN NSString *const ResetPsw;
FOUNDATION_EXTERN NSString *const SendCode;

FOUNDATION_EXTERN NSString *const pushuserstatus;
FOUNDATION_EXTERN NSString *const getfriendlist;
FOUNDATION_EXTERN NSString *const userinfo;
FOUNDATION_EXTERN NSString *const getusernormal;
FOUNDATION_EXTERN NSString *const addusernormal;
FOUNDATION_EXTERN NSString *const update;
FOUNDATION_EXTERN NSString *const delusernormal;
FOUNDATION_EXTERN NSString *const updateuserphoto;
FOUNDATION_EXTERN NSString *const adduserdynamic;
FOUNDATION_EXTERN NSString *const setCoordinate;
FOUNDATION_EXTERN NSString *const addfriendtogroup;
FOUNDATION_EXTERN NSString *const getfriendgroup;
//FOUNDATION_EXTERN NSString *const getgroup;
FOUNDATION_EXTERN NSString *const addfriendgroup;
FOUNDATION_EXTERN NSString *const delfriendgroup;
FOUNDATION_EXTERN NSString *const delfriendtogroup;
FOUNDATION_EXTERN NSString *const getDepartMemberByDeptId;
FOUNDATION_EXTERN NSString *const add;
FOUNDATION_EXTERN NSString *const getToken;
FOUNDATION_EXTERN NSString *const searchfriend;
FOUNDATION_EXTERN NSString *const usersig;
FOUNDATION_EXTERN NSString *const getmemo;
FOUNDATION_EXTERN NSString *const setmemo;
FOUNDATION_EXTERN NSString *const getCoordinate;
FOUNDATION_EXTERN NSString *const getMulCoordinate;
FOUNDATION_EXTERN NSString *const searchUser;
FOUNDATION_EXTERN NSString *const getUserByDomain;
FOUNDATION_EXTERN NSString *const leaveMsgList;
FOUNDATION_EXTERN NSString *const getmsghis;
FOUNDATION_EXTERN NSString *const pushmsgtouser;
FOUNDATION_EXTERN NSString *const offlineGroupMsg;
FOUNDATION_EXTERN NSString *const getgroupmsghis;
//FOUNDATION_EXTERN NSString *const kickGroupMember;
FOUNDATION_EXTERN NSString *const groupmember;
FOUNDATION_EXTERN NSString *const inviteFrd2Group;
FOUNDATION_EXTERN NSString *const addgroup;
FOUNDATION_EXTERN NSString *const modifygroup;
FOUNDATION_EXTERN NSString *const deletegroup;
FOUNDATION_EXTERN NSString *const searchgroup;
FOUNDATION_EXTERN NSString *const setusergroupnotify;
FOUNDATION_EXTERN NSString *const SetGroupBackground;

FOUNDATION_EXTERN NSString *const getgroup;
FOUNDATION_EXTERN NSString *const focusRoomMember;
FOUNDATION_EXTERN NSString *const unfocusRoomMember;
FOUNDATION_EXTERN NSString *const getgrouptype;
FOUNDATION_EXTERN NSString *const queryFileUpApiUrl;
@end

NS_ASSUME_NONNULL_END
