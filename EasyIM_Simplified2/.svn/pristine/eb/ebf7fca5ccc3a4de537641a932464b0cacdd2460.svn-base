//
//  MM1v1CallViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMCallViewController.h"

//ManagerClass


#import "MMVedioCallManager.h"

//Defines
#import "MMDefines.h"
#import "MMVedioCallEnum.h"

//Model
#import "MMCallSessionModel.h"

#import "WebRTCAvConf_iOS/WebRTCAvConf_iOS.h"
#import "ARDSettingsModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface ARDConfEvents : CFConfEvents

@end

@interface MM1v1CallViewController : MMCallViewController

@property (nonatomic, strong, nullable) CFAvConf *avConf;

@property (nonatomic, strong) UILabel *remoteNameLabel;//对方昵称
@property (nonatomic, strong) UILabel *timeLabel;//时间
@property (nonatomic, strong) UIButton *answerButton;//accept


@property (nonatomic) MMCallStatus callStatus;
@property (nonatomic, strong, nullable) MMCallSessionModel *callSessionModel;


- (instancetype)initWithCallSession:(MMCallSessionModel *)aCallSession;



- (void)initForRoom:(NSString*)room
            roomUrl:(NSString*)roomUrl;


- (void)clearDataAndView;

@end

NS_ASSUME_NONNULL_END
