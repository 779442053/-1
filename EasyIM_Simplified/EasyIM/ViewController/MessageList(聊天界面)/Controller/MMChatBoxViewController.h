//
//  MMChatBoxViewController.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMRecordManager.h"
#import "MMChatBoxViewControllerDelegate.h"
#import "MMChatBox.h"


NS_ASSUME_NONNULL_BEGIN

@interface MMChatBoxViewController : UIViewController

@property (nonatomic, weak) id<MMChatBoxViewControllerDelegate>delegate;

@property (nonatomic, strong) MMChatBox *chatBox;

//////////////////////////////////////////////////////////////////
@property (nonatomic, assign,) MMConversationType conversationType;
@property (nonatomic,   copy, nullable) NSString *groupId;
@property (nonatomic,   copy, nullable) NSString *mode;
@property (nonatomic,   copy, nullable) NSString *creatorId;

@end

NS_ASSUME_NONNULL_END
