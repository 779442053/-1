//
//  ZWAPIConseKey.m
//  EasyIM
//
//  Created by step_zhang on 2019/10/31.
//  Copyright © 2019 step. All rights reserved.
//

#import "ZWAPIConseKey.h"

@implementation ZWAPIConseKey
// 服务地址
NSString *const  HTURL = @"http://imapi.joyvc.com";//域名
NSString *const  HTURL_Test = @"http://imapi.51fy.co";//域名2

NSString *const  Login = @"/api_im/user/login2";
NSString *const  Regist = @"/api_im/user/interfaceadduser";
NSString *const  PreLogin = @"/api_im/user/prelogin";
NSString *const  ForGetpsw = @"/api/user/password";
NSString *const  ResetPsw = @"/api/user/password";
NSString *const  SendCode = @"/api_im/user/code";
NSString *const  pushuserstatus = @"/api_im/user/pushuserstatus";
NSString *const  getfriendlist = @"/api_im/friend/getfriendlist";
NSString *const  userinfo = @"/api_im/user/userInfo";
NSString *const  getusernormal = @"/api_im/user/getusernormal";
NSString *const  addusernormal = @"/api_im/user/addusernormal";
NSString *const  delusernormal = @"/api_im/user/delusernormal";
NSString *const  update = @"/api_im/user/update";
NSString *const  updateuserphoto = @"/api_im/user/updateUserPhotoToDB";
NSString *const  adduserdynamic = @"/api_im/user/adduserdynamic";
NSString *const  setCoordinate = @"/api_im/user/setCoordinate";
NSString *const  addfriendtogroup = @"/api_im/friend/addfriendtogroup";
NSString *const  getfriendgroup = @"/api_im/friend/getfriendgroup";
NSString *const  getgroup = @"/api_im/group/getgroup";
NSString *const  addfriendgroup = @"/api_im/friend/addfriendgroup";
NSString *const  delfriendgroup = @"/api_im/friend/delfriendgroup";
NSString *const  delfriendtogroup = @"/api_im/friend/delfriendtogroup";
NSString *const  getDepartMemberByDeptId = @"/api_im/dept/getDepartMemberByDeptId";
NSString *const  add = @"/api_im/dept/add";
NSString *const  getToken = @"/api_im/getToken";
NSString *const  searchfriend = @"/api_im/friend/searchfriend";
NSString *const  usersig = @"/api_im/user/usersig";
NSString *const  getmemo = @"/api_im/friend/getmemo";
NSString *const  setmemo = @"/api_im/friend/setmemo";
NSString *const  getCoordinate = @"/api_im/user/getCoordinate";
NSString *const  getMulCoordinate = @"/api_im/user/getMulCoordinate";
NSString *const  searchUser = @"/api_im/user/searchUser";
NSString *const  getUserByDomain = @"/api_im/user/getUserByDomain";
NSString *const  leaveMsgList = @"/api_im/msg/leaveMsgList";
NSString *const  getmsghis = @"/api_im/msg/getmsghis";
NSString *const  pushmsgtouser = @"/api_im/msg/pushmsgtouser";
NSString *const  offlineGroupMsg = @"/api_im/msg/offlineGroupMsg";
NSString *const  getgroupmsghis = @"/api_im/msg/getgroupmsghis";
//NSString *const  kickGroupMember = @"/webim/api";
NSString *const  groupmember = @"/api_im/group/groupmember";
NSString *const  inviteFrd2Group = @"/webim/api";
NSString *const  addgroup = @"/api_im/group/addgroup";
NSString *const  modifygroup = @"/api_im/group/modifygroup";
NSString *const  deletegroup = @"/api_im/group/deletegroup";
NSString *const  searchgroup = @"/api_im/group/searchgroup";
NSString *const  setusergroupnotify = @"/api_im/group/setusergroupnotify";
NSString *const  SetGroupBackground = @"/webim/api";
//NSString *const  getgroup = @"/api_im/group/getgroup";
NSString *const  focusRoomMember = @"/webim/api";
NSString *const  unfocusRoomMember = @"/webim/api";
NSString *const  getgrouptype = @"/api_im/group/getgrouptype";
NSString *const  queryFileUpApiUrl = @"/api_im/uplodefile/queryFileUpApiUrl";
NSString *const  delfriend = @"api_im/friend/delfriend";
//NSString *const  w = @"1";
//NSString *const  w = @"1";
//NSString *const  w = @"1";
//NSString *const  w = @"1";
//NSString *const  w = @"1";
//NSString *const  w = @"1";
//NSString *const  w = @"1";
//NSString *const  w = @"1";




@end
