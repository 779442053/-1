//
//  RegisterModel.h
//  EasyIM
//
//  Created by 魏勇城 on 2019/3/5.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterModel : NSObject

@property (nonatomic, copy) NSString *ret; //状态
@property (nonatomic, copy) NSString *desc; //是否成功
@property (nonatomic, copy) NSString *cmd; //状态
@property (nonatomic, copy) NSString *userid; //用户id

@end

NS_ASSUME_NONNULL_END
