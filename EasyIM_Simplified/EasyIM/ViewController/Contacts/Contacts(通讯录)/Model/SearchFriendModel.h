//
//  SearchFriendModel.h
//  EasyIM
//
//  Created by momo on 2019/4/11.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SearchFriendModel : NSObject

@property (nonatomic, copy) NSString *userid;   //用户Id11111
@property (nonatomic, copy) NSString *username; //用户名
@property (nonatomic, copy) NSString *nickname; //昵称
@property (nonatomic, copy) NSString *email;    //邮箱
@property (nonatomic, copy) NSString *mobile;   //电话
@property (nonatomic, copy) NSString *photoUrl;      //图片地址
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *is_fr;

@property (nonatomic, assign) NSInteger domainid;
@property (nonatomic, copy) NSString *telephone;

@property (nonatomic, copy) NSString *userType;
@property (nonatomic, copy) NSString *usersig;   //签名
@property (nonatomic, assign) float jingdu;      //经度
@property (nonatomic, assign) float weidu;       //纬度

@property (nonatomic, assign) BOOL isFriend;

@end

NS_ASSUME_NONNULL_END
