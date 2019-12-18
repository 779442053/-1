//
//  GroupMemberModel.h
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/25.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class MemberList;
@class list;
@class MemberList;

@interface GroupMemberModel : NSObject

@property (nonatomic, copy) NSString *type; //状态
@property (nonatomic, copy) NSString *xns; //是否成功
@property (nonatomic, copy) NSString *cmd; //状态
@property (nonatomic,strong) list *list;//成员
@property (nonatomic, copy) NSString *result; //是否成功
@property (nonatomic, copy) NSString *err; //状态
@property (nonatomic, copy) NSString *count; //成员数量

@end

@interface list : NSObject

@property (nonatomic, strong) NSMutableArray<MemberList *> *member; //群组

@end

@interface MemberList : NSObject

@property (nonatomic, copy) NSString *memberId; //
@property (nonatomic, copy) NSString *type; //该人身份creator 、manager 、normal
@property (nonatomic, copy) NSString *userName; //
@property (nonatomic, copy) NSString *photoUrl; //
@property (nonatomic, copy) NSString *userSig; //用户签名
@property (nonatomic, copy) NSString *nickName;//昵称
@property (nonatomic, assign) BOOL isSelect;


@end

NS_ASSUME_NONNULL_END
