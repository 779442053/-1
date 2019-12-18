//
//  MMVedioCallEnum.h
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

/*!
 * @abstract 枚举类型声明
 */

#ifndef MMVedioCallEnum_h
#define MMVedioCallEnum_h

/*
 * 会话状态
 */
typedef enum {
    MMCallSessionStatusDisconnected = 0, //通话还没开始
    MMCallSessionStatusConnecting = 2,     //通话正在连接
    MMCallSessionStatusConnected,            //通话等待接听
    MMCallSessionStatusAccepted,               //通话同意接听
}MMCallSessionStatus;

/*
 * 通话类型
 */
typedef enum {
    MMCallTypeVoice = 0,  //实时语音
    MMCallTypeVideo,        //实时视频
}MMCallType;

/*
 * 通话结束原因
 */

typedef enum {
    MMCallEndReasonHangup = 0,              //对方挂断
    MMCallEndReasonNoResponse,           //对方没有响应
    MMCallEndReasonDecline,                     //对方拒接
    MMCallEndReasonBusy,                         //对方占线
    MMCallEndReasonFailed,                       //呼叫失败
    MMCallEndReasonRemoteOffline,         //对方不在线
} MMCallEndReason;

/*
 *  通话网络状态
 */
typedef enum {
    MMCallNetWorkStatusNormal = 0,          //网络正常
    MMCallNetWorkStatusUnstable,              //网络不稳定
    MMCallNetWorkStatusNoData,                //没有数据
} MMCallNetWorkStatus;

/*
 * 主叫方与被叫方
 */
typedef enum {
    MMCallParty_Calling = 1,                          //主叫方
    MMCallParty_Called,                                 //被叫方
} MMCallParty;


/*
 *查看好友是否隐身
 */
typedef enum {
    MMUserStatus_offline,                            //离线
    MMUserStatus_online,                            //在线
    MMUserStatus_busy,                              //忙碌
    MMUserStatus_leave,                             //离开
    MMUserStatus_hide,                               //隐身
} MMUserStatus;


/*
 *呼叫状态(与服务器相对应)
 */
typedef enum {
    MMCallStatus_disconnected = 0,            //还未连接
    MMCallStatus_callIng = 10,                //我呼叫对方
    MMCallStatus_ring = 20,                   //对方呼叫我,我本地响铃
    MMCallStatus_ringBack = 30,               //回铃中(等待对方摘机)
    MMCallStatus_busyIng = 40,                //对方忙
    MMCallStatus_talkIng = 50,                //呼叫成功,正在双方通话
    MMCallStatus_jinHua = 60,                 //静话
    MMCallStatus_hangUp = 70,                 //挂断
} MMCallStatus;

#endif /* MMVedioCallEnum_h */
