//
//  MMFriendAppViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

#import "NewFriendModel.h"

NS_ASSUME_NONNULL_BEGIN

//typedef enum : NSUInteger {
//    MMFAppAccept,
//    MMFAppRes,
//} MMFApp;
//
//typedef void (^AddFStatusBlock)( id __nullable data,NSError *__nullable error);
//
//@protocol AddFriendAgreeDelegate2 <NSObject>
//
//@optional
//
//- (void)acceptRquestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock;
//- (void)rejectRequestWithType:(MMFApp)type aComption:(AddFStatusBlock)aComptionBlock;
//
//@end

/**
 好友申请
 */
@interface MMFriendAppViewController : MMBaseViewController

@property (nonatomic, strong) NewFriendModel *model;
//@property (nonatomic, weak) id <AddFriendAgreeDelegate2> delegate;

@end

NS_ASSUME_NONNULL_END
