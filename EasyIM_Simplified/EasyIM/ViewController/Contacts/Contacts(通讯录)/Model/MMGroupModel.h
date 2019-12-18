//
//  MMGroupModel.h
//  EasyIM
//
//  Created by momo on 2019/4/18.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMGroupModel : NSObject

@property (nonatomic, copy) NSString *creatorID; //
@property (nonatomic, copy) NSString *groupID; //
@property (nonatomic, copy) NSString *mode; //
@property (nonatomic, copy) NSString *name; //
@property (nonatomic, copy) NSString *photo;  //头像
@property (nonatomic, copy) NSString *notify; //
@property (nonatomic, copy) NSString *time; //
@property (nonatomic, copy) NSString *type; //类型
@property (nonatomic, copy) NSString *theme;//主题
@property (nonatomic, copy) NSString *bulletin; //公告

@property (nonatomic, copy) NSString *cmd;

@end

NS_ASSUME_NONNULL_END
