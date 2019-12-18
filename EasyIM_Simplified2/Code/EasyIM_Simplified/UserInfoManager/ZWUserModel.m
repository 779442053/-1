//
//  ZWUserModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/13.
//  Copyright © 2019 step. All rights reserved.
//

#import "ZWUserModel.h"
#import <objc/runtime.h>
#define userTag @"user"
@implementation ZWUserModel
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{@"ID" : @"id"};
}
+ (instancetype)currentUser{
    static ZWUserModel *user = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[ZWUserModel alloc]init];
        user.nickName = @"请设置昵称";
        user.isLogin = NO;
        user.cmd = @"";
        user.departId = @"";
        user.err = @"";
        user.meetingID = @"";
        user.photoUrl = @"";
        user.type = @"";
        user.result = @"";
        user.sessionID = @"";
        user.userId = @"";
        user.userSig = @"请设置您的签名";
        user.userName = @"";
        user.email = @"";
        user.mobile = @"";
        user.telephone = @"";
        user.depart = @"";
        user.company = @"";
        user.ver = @"";
        user.xns = @"";
        user.host = @"";
        user.money = 0.00;
        user.port = 0;
        user.webapi = @"";
        user.webrtc = @"";
        user.HostUrl = @"";
        user.SocialApi = @"";
        user.token = @"";
        user.IP = @"";
        user.userPsw = @"";
        user.domain = @"";
        user.sex = @"1";
        //user.Userremark = @"请设置您的签名";
    });
    return user;
}
//实现归档解档
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i++)
    {
        objc_property_t pro = propertyList[i];
        const char *name = property_getName(pro);
        NSString *key = [NSString stringWithUTF8String:name];
        if ([aDecoder decodeObjectForKey:key])
        {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList([self class], &count);
    for (int i = 0 ; i < count; i ++)
    {
        objc_property_t pro = propertyList[i];
        const char *name = property_getName(pro);
        NSString *key  = [NSString stringWithUTF8String:name];
        [aCoder encodeObject:[self valueForKey:key] forKey:key];
    }
}
@end
