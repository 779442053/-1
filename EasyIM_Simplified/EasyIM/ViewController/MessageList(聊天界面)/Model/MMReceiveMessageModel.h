//
//  MMReceiveMessageModel.h
//  EasyIM
//
//  Created by momo on 2019/4/23.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MMMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMReceiveMessageModel : NSObject
/**  单聊
 user =         {
     fromID = 643444;
     fromName = lw003;
     fromNick = "\U6d4b\U8bd5003";
     fromPhoto = "http://imapi.joyvc.com/storage/users/2019/11/28/2019-11-28-20-52-40-5ddfc318e4e93.jpg";
     msg =             {
         slice =                 (
                                 {
                 content = "\U963f\U9e7f\U63d0\U9ad8";
                 type = text;
             },
                                 {
                 type = null;
             }
         );
     };
     msgID = "191227-152707_00001_643444_3993692";
     msgType = text;
     time = "2019-12-27 15:26:55";
     toID = 3993692;
 };
 */
/**
 group =         {
     fromID = 1544657;
     fromName = lw007;
     fromNick = "\U6d4b\U8bd5007";
     fromPhoto = "http://imapi.joyvc.com/storage/users/2019/11/28/2019-11-28-20-52-40-5ddfc318e4e93.jpg";
     groupID = 1436;
     msg =             {
         slice =                 (
                                 {
                 content = "\U7389\U6842\U72d7";
                 type = text;
             },
                                 {
                 type = null;
             }
         );
     };
     msgID = "200112-211739_00001_1544657_1436";
     time = "2020-1-12 21:17:25";
 };
 */
#pragma mark - 公共部分
@property (nonatomic, copy) NSString *fromID;
@property (nonatomic, copy) NSString *fromName;
@property (nonatomic, copy) NSString *fromNick;
@property (nonatomic, copy) NSString *fromPhoto;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *msgID;
@property (nonatomic, copy) NSString *msgType;
@property (nonatomic, strong) MMChatContentModel *slice;

#pragma mark - 单聊接收部分
//@property (nonatomic, copy) NSString *fromNick;
@property (nonatomic, copy) NSString *toID;
@property (nonatomic, copy) NSString *toName;

#pragma mark - 群消息接收部分
@property (nonatomic, copy) NSString *groupID;
@property (nonatomic, copy) NSString *groupName;
@property (nonatomic, copy) NSString *groupPhoto;

#pragma mark - 消息接收插入位置
@property (nonatomic, assign) BOOL isInsert;




@end

NS_ASSUME_NONNULL_END
