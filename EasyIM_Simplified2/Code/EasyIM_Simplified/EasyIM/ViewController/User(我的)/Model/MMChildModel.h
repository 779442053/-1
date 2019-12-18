//
//  MMChildModel.h
//  EasyIM
//
//  Created by momo on 2019/9/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMChildModel : NSObject

@property (nonatomic, copy) NSString *bankName;//银行卡
@property (nonatomic, assign) CGFloat bankAmount;//消费或其他
@property (nonatomic, copy) NSString *bankTime;//时间
@property (nonatomic, assign) NSInteger bankState;//完成状态
@end

NS_ASSUME_NONNULL_END
