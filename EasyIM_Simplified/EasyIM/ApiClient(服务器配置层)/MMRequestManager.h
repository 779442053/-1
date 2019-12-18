//
//  MMRequestManager.h
//  EasyIM
//
//  Created by momo on 2019/4/25.
//  Copyright © 2019年 Looker. All rights reserved.
//
//
#import <Foundation/Foundation.h>

//Socket
#import "MMConnectConfig.h"
#import "MMGCDAsyncSocketCommunicationManager.h"

//音频视频
#import "MMVedioCallEnum.h"

//工具类
#import "YHUtils.h"
#import <YYModel.h>
#import "MMDateHelper.h"

//Model
#import "MMCallSessionModel.h"
#import "ContactsModel.h"
#import "MMRecentContactsModel.h"
#import "MMGroupModel.h"
#import "SearchFriendModel.h"
#import "NewFriendModel.h"
#import "GroupMemberModel.h"
#import "MMClassListModel.h"
#import "MMMessage.h"
#import "ZWUserModel.h"
NS_ASSUME_NONNULL_BEGIN


/**
 请求管理类
 */
@interface MMRequestManager : NSObject


/**
 1v1视频呼叫

 @param toId 发送请求Id
 @param callType 请求类型
 @param callBack 结果返回
 */
+ (void)sendVedioRequestWithToId:(NSString *)toId
                            callType:(MMCallType)callType
                          callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack;

/**
 * 1vM群音视频呼叫
 */
+(void)sendVideoOrAudioWithGroupId:(NSString *)strGroupid
                       andCallType:(MMCallType)callType
                          callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack;


/**
 视频挂断

 @param toId 发送请求Id
 @param webrtcId webrtcId
 @param callType 请求类型
 @param callBack 结果返回
 */
+ (void)hangUpCallWithToId:(NSString *)toId
                  webrtcId:(NSString *)webrtcId
                     callType:(NSInteger)callType
                    callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack;


/**
 拒绝视频

 @param toId 发送请求Id
 @param webrtcId webrtcId
 @param callType 请求类型
 @param callBack 结果返回
 */
+ (void)rejectCallWithToId:(NSString *)toId
                  webrtcId:(NSString *)webrtcId
                  callType:(NSInteger)callType
                  callBack:(void(^)(MMCallSessionModel *session,NSError *error))callBack;
/**
 检查别人在线状态

 @param userId 用户Id
 @param callBack 结果返回
 */
+ (void)checkUserOnlineWithUserId:(NSString *)userId
                                            callBack:(void(^)(NSInteger status,NSError *error))callBack;


/**
 检查自己的状态

 @param callBack 0-离线；1-在线；2-忙碌；3-离开；4-隐身
 */
+ (void)checkUserStatusCallBack:(void(^)(NSInteger status,NSError *error))callBack;


/**
 获取群列表

 @param callBack 结果返回
 */
+ (void)queryGroupCallBack:(void(^)(NSArray <MMGroupModel *>*groupList,NSError *error))callBack;


/**
 查询组信息
 
 @param strKey 搜索关键字
 @param startRow 页索引(第一页 0)
 @param rowCount 页大小
 @param aCompletionBlock 回调
 */
+(void)searchGroupForName:(NSString * _Nonnull)strKey
                 startRow:(NSString *_Nonnull)startRow
                 rowCount:(NSString *_Nonnull)rowCount
              aCompletion:(void(^ _Nullable)(NSArray<MMGroupModel *> *_Nullable arrGroupList,NSError * _Nullable error))aCompletionBlock;

/**
 获取加好友通知

 @param aCompletionBlock 结果返回
 */
+ (void)fetchBulletionCompletion:(void(^)(NSArray <NewFriendModel *>*bulletionList,NSError *error))aCompletionBlock;

/**
 好友状态(接受/拒绝)

 @param cmd 接受或拒绝指令
 @param tagUserId 对方id
 @param time 时间
 @param msg 留言
 @param aCompletionBlock 结果返回
 */
+ (void)aNoticFriendsWithCmd:(NSString *)cmd
                   tagUserId:(NSString *)tagUserId
                        time:(NSString *)time
                         msg:(NSString *)msg
                 aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock;




/**
 增加群

 @param groupName 群名
 @param bulletin 公告
 @param theme 主题
 @param photo 群头像
 @param userlist 用户列表
 @param aCompletionBlock 结果返回
 */
+ (void)addGroupWithGroupName:(NSString *)groupName
                     bulletin:(NSString *)bulletin
                        theme:(NSString *)theme
                        photo:(NSString *)photo
                     userlist:(NSString *)userlist
                  aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock;



/**
 获取群成员

 @param taggroupId 群id
 @param mode mode
 @param aCompletionBlock 结果返回
 */
+ (void)groupMemberWithtaggroupId:(NSString *_Nullable)taggroupId
                             mode:(NSString *_Nullable)mode
                      aCompletion:(void(^)(NSArray<MemberList *> *_Nullable memberList,NSString *_Nullable createId,NSError *_Nullable error))aCompletionBlock;


/**
 主动退出群

 @param groupid 群id
 @param msg 退出原因
 @param aCompletionBlock 结果返回
 */
+ (void)exitGroupWithGroupid:(NSString *)groupid msg:(NSString *)msg
                 aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock;


/**
 接受音频邀请

 @param model model
 @param callType 当前发起会话类型(3 群聊语音/0 单聊语音,1 单聊视频/ 4群聊视频)
 @param aCompletionBlock 结果返回
 */
+ (void)acceptCallWithModel:(MMCallSessionModel *)model
                      callType:(NSInteger)callType
                   aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock;


/**
 邀请群成员

 @param groupId 群id
 @param friendId 好友id列表
 @param aCompletionBlock 结果返回
 */
+ (void)inviteFrd2GroupWithGroupId:(NSString *)groupId
                          friendId:(NSString *)friendId
                       aCompletion:(void(^)(NSDictionary *dic, NSError *error))aCompletionBlock;

//=====================================我是分割线==================================//
//=====================================Model解析==================================//


/**
 获取话题分类列表

 @param userId 用户编号
 @param gid 话题分类编号
 @param page 起始页
 @param limit 截取条数
 @param aCompletionBlock 结果返回
 */
+ (void)fetchTopicGroupListWithUserId:(NSString *)userId
                                  gid:(NSInteger)gid
                                 page:(NSInteger)page
                                limit:(NSInteger)limit
                           completion:(void(^)(NSArray <MMClassListModel *>*arr, NSError *error))aCompletionBlock;

/**
 获取话题详情接口

 @param userId 用户编号
 @param did 话题内容编号
 @param aCompletionBlock 结果返回
 */
+ (void)fetchClassDetailWithUserId:(NSString *)userId
                                  did:(NSInteger)did
                           completion:(void(^)(NSArray <MMClassListModel *>*arr, NSError *error))aCompletionBlock;





//MARK: - 聊天室逻辑处理
/**
 退出当前聊天室
 
 @param roomId 聊天室编号
 @param strPwd 聊天室密码 //md5,可以为空,聊天室用
 @param strMsg 消息
 @param finshback 完成回调
 */
+ (void)liveRoomExitForRoomId:(NSString *_Nonnull)roomId
                       AndPwd:(NSString *_Nullable)strPwd
                       AndMsg:(NSString *_Nullable)strMsg
                andFinishBack:(void(^_Nullable)(id _Nullable responseData,NSString *_Nullable strError))finshback;

/**
 聊天室发送消息/礼物/红包
 http://apidoc.joysw.cn/web/#/1?page_id=63
 
 @param roomId 聊天室编号
 @param strMsg 消息内容
 @param giftDic 礼物对象(没有传空)
         @{
           @"giftcount":@"礼物数量",
           @"gift":@"礼物编号",
           @"toID":@"如为0则是发送给聊天室所有人，否则发给指定toID的人"
         }
 @param redPacketDic 红包对象(没有传空)
         @{
             @"money":@"红包金额",
             @"toID":@"如为0则是发送给聊天室所有人，否则发给指定toID的人"
         }
 @param finshback 事件完成回调
 */
+ (void)liveRoomSendMessageOrGiftForRoomId:(NSString *_Nonnull)roomId
                                AndMessage:(NSString *_Nullable)strMsg
                                 orGiftDic:(NSDictionary *_Nullable)giftDic
                            orRedPacketDic:(NSDictionary *_Nullable)redPacketDic
                             andFinishBack:(void(^_Nullable)(id _Nullable responseData,NSString *_Nullable strError))finshback;

/**
 加入聊天室
 
 @param strRoomId 聊天室编号
 @param strPwd 聊天室密码 //md5,可以为空,聊天室用
 @param strMsg 加入信息
 @param finishBack 操作回调
 */
+ (void)liveRoomJoinForRoomId:(NSString *_Nonnull)strRoomId
                       AndPwd:(NSString *_Nullable)strPwd
                   AndMessage:(NSString *_Nullable)strMsg
                AndFinishBack:(void(^_Nullable)(NSString *strError,id _Nullable responseData))finishBack;
@end




NS_ASSUME_NONNULL_END
