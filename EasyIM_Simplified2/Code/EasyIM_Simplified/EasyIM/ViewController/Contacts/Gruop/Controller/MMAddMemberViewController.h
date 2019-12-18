//
//  MMAddMemberViewController.h
//  EasyIM
//
//  Created by momo on 2019/6/1.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMAddMemberViewControllerDelegate<NSObject>

@optional
/** 添加好友成功回调 */
-(void)mmAddMemberFinish;

/**
 * 邀请成员成功回调
 * @param arrMembersId 被邀请人员编号
 * @param strGroupId 所在群组编号
 * @param arrDetails 被邀请成员的详细信息(UI展示使用)
 * @param isVideo YES 群视频 NO 群语音
 */
-(void)mmInvitationMemberFinish:(NSArray  *_Nonnull)arrMembersId
                     andGroupId:(NSString *_Nonnull)strGroupId
                 andDetailsData:(NSArray  *_Nullable)arrDetails
                     andIsVideo:(BOOL)isVideo;


/**
 * 联系人选择回调
 * @param strUserId 联系人编号
 * @param strUserName 用户名
 * @param strNickname 昵称
 * @param strPhoto 图像地址
 */
-(void)mmDidSelectForLinkmanId:(NSString *_Nonnull)strUserId
                 andUserName:(NSString *_Nonnull)strUserName
                 andNickName:(NSString *_Nullable)strNickname
                    andPhoto:(NSString *_Nullable)strPhoto;
@end

/**
 * 添加好友
 */
@interface MMAddMemberViewController : MMBaseViewController

/** 群id */
@property (nonatomic,  copy) NSString *groupId;

/** 群主id */
@property (nonatomic,  copy) NSString *creatorId;

/** 当前群成员 */
@property (nonatomic,  copy) NSArray *memberData;

/** 是否为邀请群视频(YES 群视频邀请) */
@property (nonatomic,assign) BOOL isGroupVideo;

/** 是否为邀请群语音(YES 群语音邀请) */
@property (nonatomic,assign) BOOL isGroupAudio;

/** 是否为联系人 */
@property (nonatomic,assign) BOOL isLinkman;

@property (nonatomic,  weak) id<MMAddMemberViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
