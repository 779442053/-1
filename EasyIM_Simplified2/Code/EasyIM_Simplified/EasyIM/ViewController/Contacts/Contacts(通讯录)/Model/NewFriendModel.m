//
//  NewFriendModel.m
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/15.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "NewFriendModel.h"

@implementation NewFriendModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"uid":@"id",
             @"remark":@"remark",
             @"state":@"state",
             @"headImgUrl":@"headImgUrl",
             @"askRemark":@"askRemark",
             @"nickName":@"nickName",
             @"createTime":@"createTime"
             };
}

-(NSString *)fromName{
    return [_fromName stringByRemovingPercentEncoding];
}

-(NSString *)fromNick{
    return [_fromNick stringByRemovingPercentEncoding];
}

@end
