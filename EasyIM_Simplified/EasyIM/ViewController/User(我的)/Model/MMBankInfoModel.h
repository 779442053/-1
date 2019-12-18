//
//  MMBankInfoModel.h
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMBankInfoModel : NSObject

@property (nonatomic, copy) NSString *bankTitle;//标题
@property (nonatomic, copy) NSString *bankName;//银行卡名称
@property (nonatomic, copy) NSString *bankInfo;//银行卡信息
@property (nonatomic, copy) NSString *bankPlaceholder;//银行卡描述

@end

NS_ASSUME_NONNULL_END
