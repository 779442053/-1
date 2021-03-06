//
//  MMMessageConst.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMMessageConst.h"

/************Const*************/

CGFloat const HEIGHT_STATUSBAR   = 20;
CGFloat const HEIGHT_NAVBAR      = 44;
CGFloat const HEIGHT_CHATBOXVIEW = 215;





/************Event*************/

NSString *const GXRouterEventVoiceTapEventName   = @"GXRouterEventVoiceTapEventName";
NSString *const GXRouterEventImageTapEventName   = @"GXRouterEventImageTapEventName";
NSString *const GXRouterEventTextUrlTapEventName =
@"GXRouterEventTextUrlTapEventName";
NSString *const GXRouterEventMenuTapEventName    =
@"GXRouterEventMenuTapEventName";
NSString *const GXRouterEventVideoTapEventName   =
@"GXRouterEventVideoTapEventName";
NSString *const GXRouterEventShareTapEvent       =
@"GXRouterEventShareTapEvent";

NSString *const GXRouterEventVideoRecordExit     =
@"GXRouterEventVideoRecordExit";
NSString *const GXRouterEventVideoRecordCancel   =
@"GXRouterEventVideoRecordCancel";
NSString *const GXRouterEventVideoRecordFinish   = @"GXRouterEventVideoRecordFinish";
NSString *const GXRouterEventVideoRecordStart    =
@"GXRouterEventVideoRecordStart";
NSString *const GXRouterEventURLSkip             =
@"GXRouterEventURLSkip";
NSString *const GXRouterEventScanFile            =
@"GXRouterEventScanFile";






/** 消息类型的KEY */
NSString *const MessageTypeKey         =@"messageKey";
NSString *const VideoPathKey                =@"videoKey";
NSString *const GXSelectEmotionKey   = @"selectEmotionKey";

NSString *const MessageKey                  =@"mKey";
NSString *const VoiceIcon                        =@"voiceIcon";
NSString *const RedView                          =@"redView";



/************Name 消息类型*************/

NSString *const TypeText        = @"text";
NSString *const TypeVoice       = @"voice";
NSString *const TypePic         = @"pic";
NSString *const TypeVideo       = @"video";
NSString *const TypeFile        = @"file";
NSString *const TypeSystem      = @"system";
NSString *const TypePicText     = @"picText";
NSString *const TypeLocation    = @"linkMap";
NSString *const TypeLinkMan     = @"linkman";
NSString *const TypeWithdraw     = @"TypeWithdraw";//撤回


/************Notification*************/

NSString *const GXEmotionDidSelectNotification   =
@"GXEmotionDidSelectNotification";
NSString *const GXEmotionDidDeleteNotification   =
@"GXEmotionDidDeleteNotification";
NSString *const GXEmotionDidSendNotification     =
@"GXEmotionDidSendNotification";
//NSString *const NotificationReceiveUnreadMessage =
//    @"NotificationReceiveUnreadMessage";
NSString *const NotificationDidCreatedConversation =
@"NotificationDidCreatedConversation";
NSString *const NotificationFirstMessage         =
@"NotificationFirstMessage";
NSString *const NotificationDidUpdateDeliver     =
@"NotificationDidUpdateDeliver";
NSString *const NotificationPushDidReceived      =
@"NotificationPushDidReceived";
NSString *const NotificationDeliverChanged       =
@"NotificationDeliverChanged";
NSString *const NotificationBackMsgNotification  =
@"NotificationBackMsgNotification";
NSString *const NotificationGPhotoDidChanged     =
@"NotificationGPhotoDidChanged";

NSString *const NotificationReloadDataIMSource     =
@"NotificationReloadDataIMSource";

NSString *const NotificationUserHeadImgChangedNotification  =
@"NotificationUserHeadImgChangedNotification";

NSString *const NotificationKickUserNotification     =
@"NotificationKickUserNotification";

NSString *const NotificationShareExitNotification =
@"NotificationShareExitNotification";

NSString *const ICShareCancelNotification =
@"ICShareCancelNotification";

NSString *const ICShareConfirmNotification =
@"ICShareConfirmNotification";

NSString *const ICShareStayInAppNotification =
@"ICShareStayInAppNotification";

NSString *const ICShareBackOtherAppNotification =
@"ICShareBackOtherAppNotification";
