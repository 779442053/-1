//
//  VerificationViewController.h
//  EasyIM
//
//  Created by 魏冰杰 on 2019/8/28.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"
#import "NewFriendModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    MMFAppAccept,
    MMFAppRes,
} MMFApp;

typedef void (^AddFStatusBlock)( id __nullable data,NSError *__nullable error);

@protocol AddFriendAgreeDelegate2 <NSObject>

@optional
//接受好友请求(群)
- (void)acceptRquestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock;
//拒绝好友请求(群)
- (void)rejectRequestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock;

@end

@interface VerificationViewController : MMBaseViewController
@property (nonatomic, strong) NewFriendModel *model;
@property (nonatomic, weak) id <AddFriendAgreeDelegate2> delegate;
@end

NS_ASSUME_NONNULL_END
