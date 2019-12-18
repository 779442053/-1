//
//  ZWBaseModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseModel.h"

@implementation ZWBaseModel
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID" : @"id"};
}
@end
