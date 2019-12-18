//
//  GetModel.h
//  EasyIM
//
//  Created by 魏勇城 on 2019/2/21.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetModel : NSObject

@property (nonatomic, copy) NSString *ret; //状态
@property (nonatomic, copy) NSString *desc; //是否成功
@property (nonatomic, copy) NSString *cmd; //状态
@property (nonatomic, copy) NSString *sessionID; //sessionId
@property (nonatomic, copy) NSString *userId; //userid
@property (nonatomic, copy) NSString *downloadurl; //nickname

@property (nonatomic, copy) NSString *sessionid; //sessionId
@property (nonatomic, copy) NSString *userid; //userid

@end

NS_ASSUME_NONNULL_END
