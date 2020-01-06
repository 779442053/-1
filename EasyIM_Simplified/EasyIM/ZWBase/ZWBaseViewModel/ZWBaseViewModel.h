//
//  ZWBaseViewModel.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWBaseViewModelProtocol.h"
#import "ZWDataManager.h"

#import "ZWSaveTool.h"
#import "YJProgressHUD.h"
#import "ZWSocketManager.h"
#import "ZWAPIConseKey.h"
#import "MMDateHelper.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZWBaseViewModel : NSObject<ZWBaseViewModelProtocol>

//生成16位随机字符串
-(NSString *)randomString:(NSInteger )num;
//json转字符串
-(NSString *)convertToJsonData:(NSMutableDictionary *)parma;

@end

NS_ASSUME_NONNULL_END
