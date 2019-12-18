//
//  MMEditGroupViewController.h
//  EasyIM
//
//  Created by momo on 2019/6/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBaseViewController.h"
@class MemberList;

NS_ASSUME_NONNULL_BEGIN

@protocol MMEditGroupViewControllerDelegate<NSObject>

@optional
/**
 * 群组成员被移除成功后的回调
 */
-(void)mmEditGroupRemoveMemberSuccess:(MemberList *)member;

@end

/**
 * 群组管理
 */
@interface MMEditGroupViewController : MMBaseViewController

/** 群组成员 */
@property (nonatomic,strong) NSMutableArray *dataSource;

/** 群id */
@property (nonatomic, copy) NSString *groupId;

/** 群主 */
@property (nonatomic, copy) NSString *creatorId;

@property (nonatomic, weak) id<MMEditGroupViewControllerDelegate> deleget;

@end

NS_ASSUME_NONNULL_END
