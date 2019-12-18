//
//  GroupModel.h
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/25.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class GroupList;
@class List;
@class GroupList;

@interface GroupModel : NSObject

@property (nonatomic, copy) NSString *type; //状态
@property (nonatomic, copy) NSString *xns; //是否成功
@property (nonatomic, copy) NSString *cmd; //状态
@property(nonatomic,strong) List *list;//
@property (nonatomic, copy) NSString *result; //是否成功
@property (nonatomic, copy) NSString *err; //状态

@end

@interface List : NSObject

@property (nonatomic, strong) NSMutableArray<GroupList *> *group; //群组

@end

@interface GroupList : NSObject

@property (nonatomic, copy) NSString *creatorID; //
@property (nonatomic, copy) NSString *groupID; //
@property (nonatomic, copy) NSString *mode; //
@property (nonatomic, copy) NSString *name; //
@property (nonatomic, copy) NSString *time; //
@property (nonatomic, copy) NSString *type; //
@property (nonatomic, copy) NSString *bulletin; //
@property (nonatomic, copy) NSString *theme; //

@end

NS_ASSUME_NONNULL_END
