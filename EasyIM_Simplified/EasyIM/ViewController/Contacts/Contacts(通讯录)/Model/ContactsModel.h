//
//  ContactsModel.h
//  EasyIM
//
//  Created by momo on 2019/4/15.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ContactsModel : NSObject

@property (nonatomic, copy) NSString *photoUrl; //图片地址
@property (nonatomic, copy) NSString *remarkName;
@property (nonatomic, copy) NSString *userId; //用户Id
@property (nonatomic, copy) NSString *userName; //用户名
@property (nonatomic, copy) NSString *nickName; //昵称
@property (nonatomic, copy) NSString *online; //是否在线

@property (nonatomic, copy) NSString *cmd;//请求命令

@property (nonatomic, assign) BOOL isSelect;



-(NSString *)getName;
@end

NS_ASSUME_NONNULL_END
