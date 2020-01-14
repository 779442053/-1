//
//  MMGroupDetailViewController.h
//  EasyIM
//
//  Created by momo on 2019/5/26.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMGroupDetailViewControllerDelegate<NSObject>

@optional
/**
 * 设置群聊背景图成功回调
 * @param strUrl 背景图网络地址
 * @param img    背景图片
 */
-(void)mmGroupDetailsSetBackgroundSuccess:(NSString *_Nonnull)strUrl
                                 andImage:(UIImage *_Nonnull)img;

@end

/**
 * 群详情
 */
@interface MMGroupDetailViewController : MMBaseViewController

#pragma mark - 群

/** 群创建时间戳*/
@property (nonatomic, copy) NSString *time;

/** 群还是聊天室 0表示群,10表示聊天室 */
@property (nonatomic, copy) NSString *mode;

/** 群id */
@property (nonatomic,  copy) NSString *groupId;

/** 群主(此值会修正所以为 strong) */
@property (nonatomic,strong) NSString *creatorId;

/** 群名称*/
@property (nonatomic, copy) NSString *name;
/** 群名公告*/
@property (nonatomic, copy) NSString *bulletin;
/** 群是否免打扰(notify — 0 不启用消息 开启免打扰，1 启用接收消息,关闭免打扰) */
@property (nonatomic, copy) NSString *notify;

@property (nonatomic, weak, nullable) id<MMGroupDetailViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
