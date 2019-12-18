//
//  MMChatServerDefs.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#ifndef MMChatServerDefs_h
#define MMChatServerDefs_h

// 聊天类型
typedef enum {
    MMConversationType_Chat,    //单聊
    MMConversationType_Group,   //群聊
    MMConversationType_Meet,    //会议室
}MMConversationType;

// 消息发送状态
typedef enum {
    MMMessageDeliveryState_Pending = 0,  // 待发送
    MMMessageDeliveryState_Delivering,   // 正在发送
    MMMessageDeliveryState_Delivered,    // 已发送，成功
    MMMessageDeliveryState_Failure,      // 发送失败
    MMMessageDeliveryState_ServiceFaid   // 发送服务器失败(可能其它错,待扩展)
}MessageDeliveryState;


// 消息类型
typedef enum {
    MMMessageType_Text  = 1,             // 文本
    MMMessageType_Voice,                 // 短录音
    MMMessageType_Image,                 // 图片
    MMMessageType_Video,                 // 短视频
    MMMessageType_Doc,                   // 文档
    MMMessageType_Location,              // 位置
    MMMessageType_linkman,//联系人
    MMMessageType_TextURL,               // 文本＋链接
    MMMessageType_ImageURL,              // 图片＋链接
    MMMessageType_URL,                   // 纯链接
    MMMessageType_DrtNews,               // 送达号
    MMMessageType_NTF   = 12,            // 通知
    MMMessageType_Emp,
    
    MMMessageType_DTxt  = 21,            // 纯文本
    MMMessageType_DPic  = 22,            // 文本＋单图
    MMMessageType_DMPic = 23,            // 文本＋多图
    MMMessageType_DVideo= 24,            // 文本＋视频
    MMMessageType_PicURL= 25             // 动态图文链接
    
}MMMessageType;

typedef enum {
    MMGroup_SELF = 0,                    // 自己
    MMGroup_DOUBLE,                      // 双人组
    MMGroup_MULTI,                       // 多人组
    MMGroup_TODO,                        // 待办
    MMGroup_QING,                        // 轻应用
    MMGroup_NATIVE,                      // 原生应用
    MMGroup_DISCOVERY,                   // 发现
    MMGroup_DIRECT,                      // 送达号
    MMGroup_NOTIFY,                      // 通知
    MMGroup_BOOK                         // 通讯录
}MMGroupType;

// 消息状态
typedef enum {
    MMMessageStatus_unRead = 0,          // 消息未读
    MMMessageStatus_read,                // 消息已读
    MMMessageStatus_back                 // 消息撤回
}MMMessageStatus;

typedef enum {
    MMActionType_READ = 1,               // 语音已读
    MMActionType_BACK,                   // 消息撤回
    MMActionType_UPTO,                   // 消息读数
    MMActionType_KICK,                   // 请出会话
    MMActionType_OPOK,                   // 待办已办
    MMActionType_BDRT,                   // 送达号消息撤回
    MMActionType_GUPD,                   // 群信息修改
    MMActionType_UUPD,                   // 群成员信息修改
    MMActionType_DUPD,                   // 送达号信息修改
    MMActionType_OFFL = 10,              // 请您下线
    MMActionType_STOP = 11,              // 清除所有缓存
    MMActionType_UUPN                    // 改昵称
    
}MMActionType;

typedef NS_ENUM(NSInteger, MMChatBoxStatus) {
    MMChatBoxStatusNothing,     // 默认状态
    MMChatBoxStatusShowVoice,   // 录音状态
    MMChatBoxStatusShowFace,    // 输入表情状态
    MMChatBoxStatusShowMore,    // 显示“更多”页面状态
    MMChatBoxStatusShowKeyboard,// 正常键盘
    MMChatBoxStatusShowVideo    // 录制视频
};

typedef enum {
    MMDeliverSubStatus_Can        = 0,   // 可订阅
    MMDeliverSubStatus_Already,
    MMDeliverSubStatus_System
}MMDeliverSubStatus;

typedef enum {
    MMDeliverTopStatus_NO         = 0, // 非置顶
    MMDeliverTopStatus_YES             // 置顶
}MMDeliverTopStatus;


typedef enum {
    MMFileType_Other = 0,                // 其它类型
    MMFileType_Audio,                    //
    MMFileType_Video,                    //
    MMFileType_Html,
    MMFileType_Pdf,
    MMFileType_Doc,
    MMFileType_Xls,
    MMFileType_Ppt,
    MMFileType_Img,
    MMFileType_Txt
}MMFileType;
#endif /* MMChatServerDefs_h */
