//
//  MMRecentContactsModel.h
//  EasyIM
//
//  Created by momo on 2019/5/10.
//  Copyright © 2019年 Looker. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum {
    TargetType_RecC = 2,    //最近联系人
    TargetType_TopC = 12,   //常用联系人
    TargetType_RecG = 3,    //最近群组
    TargetType_ComG = 13,   //常用群组
    TargetType_RecM = 4,    //最近会议
    TargetType_ComM = 13,   //常用会议
} TargetType;


/**
 最近联系人Model
 */

@interface MMRecentContactsModel : NSObject

@property (nonatomic, copy) NSString *targetId;
@property (nonatomic, copy) NSString *targetName;
@property (nonatomic, copy) NSString *targetNick;
@property (nonatomic, copy) NSString *targetPhoto;
@property (nonatomic, copy) NSString *lastTime;

@property (nonatomic, copy) NSString *targetType;
@property (nonatomic, assign) NSInteger subtype;



@property (nonatomic, assign) NSInteger unReadCount;
@property (nonatomic, copy) NSString *latestMsgStr;
@property (nonatomic, assign) long long latestMsgTimeStamp;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *latestHeadImage;
@property (nonatomic, copy) NSString *latestnickname;

@end

NS_ASSUME_NONNULL_END
