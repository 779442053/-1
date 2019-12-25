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

@interface GroupMemberModel : NSObject
@property (nonatomic, copy) NSString *groupID; //群id
@property (nonatomic, copy) NSString *createID; //创建者id
@property (nonatomic, strong) NSMutableArray<MemberList *> *list; //群组
@end

@interface MemberList : NSObject
@property (nonatomic, copy) NSString *memberId; //用户id
@property (nonatomic, copy) NSString *type; //该人身份creator 、manager 、normal
@property (nonatomic, copy) NSString *username; //
@property (nonatomic, copy) NSString *photoUrl; //
@property (nonatomic, copy) NSString *usersig; //用户签名
@property (nonatomic, copy) NSString *nickname;//昵称
@property (nonatomic, copy) NSString *online;//是否在线
@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
