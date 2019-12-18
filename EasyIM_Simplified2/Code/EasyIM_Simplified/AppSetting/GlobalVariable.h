///
//  GlobalVariable.h
//  speedauction
//
//  Created by yuanku on 15/9/17.
//  Copyright (c) 2015年 Company. All rights reserved.
//

#ifndef speedauction_GlobalVariable_h
#define speedauction_GlobalVariable_h


/**
 *  宏定义
 *  ======需要删除对应的文件和类 ===张威威
 */
#define G_HTTP_URL [ZWUserModel currentUser].webapi.length ? [ZWUserModel currentUser].webapi : @"http://admin3.joyvc.com/"

//话题 朋友圈base地址
#define TOP_CIRCLE_URL @"http://admin2.joyvc.com/"

//最新接口地址
#define K_APP_HOST_ADMIN3 @"http://imapi.51fy.co/"

//=======================长度=============================
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)


#define G_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//屏幕高
#define G_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define G_UI_WIDTH (G_SCREEN_WIDTH - 2 * G_UI_START_X)
//宽度比例适配
#define G_GET_SCALE_LENTH(a)  a/720.0f*G_SCREEN_WIDTH*2.0
//高度比例适配
#define G_GET_SCALE_HEIGHT(a)  a/1280.0f*G_SCREEN_HEIGHT*2.0


#define kDefaultPic [UIImage imageNamed:@"icon_album_picture_fail_big"]

///判断设备类型是否iPhoneX
#define ISIphoneX  (IS_IOS_11 && IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))


//主题色
#define G_EEF0F3_COLOR [UIColor colorWithHexString:@"eef0f3"]//线颜色
#define FONT(f) [UIFont fontWithName:@"MicrosoftYaHei" size:f]


////////////////////////////////////////////////////////////////////////////////
//MARK: - 网络请求公共设置
////////////////////////////////////////////////////////////////////////////////
/** 请求Api */
#define K_APP_REQUEST_API @"/api_im/user/interfaceadduser"
#define K_APP_REQUEST_API_2 @"api/user/"
#define K_APP_REQUEST_API_3 @"api/friend/"

/** 请求结果(ret=succ 成功) */
#define K_APP_REQUEST_OK(rs)([(rs) isEqualToString:@"succ"])

/** Http请求返回码(状态) */
#define K_APP_REQUEST_CODE @"ret"

/** 请求返回结果 */
#define K_APP_REQUEST_DATA @"JoyIM"

/** 请求返回提示信息 */
#define K_APP_REQUEST_MSG @"desc"

/** 会话Id失效 */
#define K_APP_REQUEST_AUTHID(dicObj)([(dicObj[@"desc"]) containsString:@"无效"])



#define K_DEFAULT_USER_PIC [UIImage imageNamed:@"setting_default_icon"]


//MARK: - Bugly测试配置信息
////////////////////////////////////////////////////////////////////////////////
#define K_APP_BUGLY_APP_ID @"61c93afcea"
#define K_APP_BUGLY_APP_KEY @"ef43acb0-ad28-4907-9163-09183e935d13"


//MARK: - fir.im 版本检测
////////////////////////////////////////////////////////////////////////////////
#define K_APP_FIR_IM_URL @"https://api.fir.im/apps/latest/5d5e356b23389f1248bd3064"

//fir.im token
#define K_APP_FIR_IM_TOKEN @"c8e3b5b088c7ab9aa73807b518ec9c29"
#define K_APP_REQUEST_PLATFORM @"IOS"

//MARK: - GCDSocketTCPCMD 枚举
////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(NSUInteger,MMConGroupItem){
    MMConGroup_Friend = 0,
    MMConGroup_Group,
    MMConGroup_Topic,
};

typedef NS_ENUM(NSInteger,GCDSocketTCPCmdType){
    /** heartBeat 心跳包 */
    GCDSocketTCPCmdTypeHeartBeat = 0,
    
    /** updateuserstate 下线通知 */
    GCDSocketTCPCmdTypeUpdateuserstate,
    
    /** friendStatus 好友上线通知 */
    GCDSocketTCPCmdTypeFriendStatus,
   
    /** inviteFrd2Group 邀请好友入群 */
    GCDSocketTCPCmdTypeInviteFrd2Group,
    
    /** hasBulletin 好友通知 */
    GCDSocketTCPCmdTypeHasBulletin,

    /**
     * 视频呼叫返回状态(对方等待通知界面)
     * callUser  1v1音视频呼叫
     * CallGroup 1vM群组音视频呼叫
     */
    GCDSocketTCPCmdTypeCallUser,
    GCDSocketTCPCmdTypeCallGroup,
    
    /** login 获取登陆消息 */
    GCDSocketTCPCmdTypeLogin,
    
    /** sendMsg 发送消息回调 */
    GCDSocketTCPCmdTypeSendMsg,
    
    /** fetchMsg 读取消息 */
    GCDSocketTCPCmdTypeFetchMsg,
    
    /** HangUpCall 挂断 */
    GCDSocketTCPCmdTypeHangUpCall,
    
    /** 接受音视频邀请(AcceptCall 1v1、AcceptGroupCall 1vM) */
    GCDSocketTCPCmdTypeAcceptCall,
    GCDSocketTCPCmdTypeAcceptGroupCall,
    
    /** 拒绝视频邀请(RejectCall 1v1、RejectGroupCall 1vM) */
    GCDSocketTCPCmdTypeRejectCall,
    GCDSocketTCPCmdTypeRejectGroupCall,
       
    /** fetchGroupMsg 读取群消息 */
    GCDSocketTCPCmdTypeFetchGroupMsg,

    /** checkUserOnline 检查用户是否在线 */
    GCDSocketTCPCmdTypeCheckUserOnline,
    
    /** groupMsg 发群消息回调 */
    GCDSocketTCPCmdTypeGroupMsg,
    
    /** addFriend 加好友回调 */
    GCDSocketTCPCmdTypeAddFriend,
    
    /** deleteGroup 解散群回调 */
    GCDSocketTCPCmdTypeDeleteGroup,

    /** exitGroup 退出群回调 */
    GCDSocketTCPCmdTypeExitGroup,
    
    /** joinChatRoom 加入聊天室 */
    GCDSocketTCPCmdTypeJoinChatRoom,
    
    /** exitChatRoom 离开聊天室 */
    GCDSocketTCPCmdTypeExitChatRoom,
    
    /** sendChatRoomMsg 聊天室发送消息/礼物/红包 */
    GCDSocketTCPCmdTypeSendChatRoomMsg,
    
    /** logout 退出登录 */
    GCDSocketTCPCmdTypeLogout
};

#define ZWGCDSocketTCPCmdTypeGet @[@"heartBeat",\
@"updateuserstate",\
@"friendStatus",\
@"inviteFrd2Group",\
@"hasBulletin",\
@"callUser",\
@"CallGroup",\
@"login",\
@"sendMsg",\
@"fetchMsg",\
@"HangUpCall",\
@"AcceptCall",\
@"AcceptGroupCall",\
@"RejectCall",\
@"RejectGroupCall",\
@"fetchGroupMsg",\
@"checkUserOnline",\
@"groupMsg",\
@"addFriend",\
@"deleteGroup",\
@"exitGroup",\
@"joinChatRoom",\
@"exitChatRoom",\
@"sendChatRoomMsg",\
@"logout"]

/** 枚举 to 字串 */
#define ZWGCDSocketTCPCmdTypeString(type) ([ZWGCDSocketTCPCmdTypeGet objectAtIndex:type])

/** 字串 to 枚举 */
#define ZWGCDSocketTCPCmdTypeEnum(string) ([ZWGCDSocketTCPCmdTypeGet indexOfObject:string])


#endif
