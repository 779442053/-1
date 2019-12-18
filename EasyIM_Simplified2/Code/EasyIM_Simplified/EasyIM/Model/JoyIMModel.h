//
//  JoyIMModel.h
//  EasyIM
//
//  Created by 魏勇城 on 2019/2/21.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FrdList.h"

NS_ASSUME_NONNULL_BEGIN

@interface JoyIMModel : NSObject

@property (nonatomic, copy) NSString *type; //状态
@property (nonatomic, copy) NSString *xns; //是否成功
@property (nonatomic, copy) NSString *cmd; //状态
@property (nonatomic, strong) FrdList *frdList; //好友
@property (nonatomic, copy) NSString *result; //是否成功 0 呼叫失败，1呼叫成功
@property (nonatomic, copy) NSString *err; //状态

@end

NS_ASSUME_NONNULL_END
