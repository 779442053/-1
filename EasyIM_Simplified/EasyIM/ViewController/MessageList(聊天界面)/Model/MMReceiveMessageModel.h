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
 <JoyIM><type>rsp</type><xns>xns_user</xns><cmd>fetchMsg</cmd><list><user><fromID>6122507</fromID><fromName></fromName><fromNick></fromNick><fromPhoto></fromPhoto><toID>1544657</toID><time>2019-12-23 11:18:50</time><msgID>20191223_111850_700_6122507_1544657</msgID><msg>
     <slice>
         <type>text</type>
         <content>收到了吗</content>
     </slice>
 <slice><type>null</type></slice></msg>
 <msgType>text</msgType><url></url></user></list><result>1</result><err>ok</err><code></code><timeStamp>4589875</timeStamp></JoyIM>
 */
#pragma mark - 公共部分
@property (nonatomic, copy) NSString *fromID;
@property (nonatomic, copy) NSString *fromName;
@property (nonatomic, copy) NSString *fromPhoto;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *msgID;
@property (nonatomic, copy) NSString *msgType;
@property (nonatomic, strong) MMChatContentModel *slice;

#pragma mark - 单聊接收部分
@property (nonatomic, copy) NSString *fromNick;
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
