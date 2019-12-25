//
//  GroupMemberModel.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/25.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "GroupMemberModel.h"

@implementation GroupMemberModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"list":[MemberList class]};
    
}
@end
@implementation MemberList

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{
             @"memberId":@"id",
             @"userName":@"username",
             @"photoUrl":@"pic",
             @"userSig":@"usersig",
             @"nickName":@"nickname",
    };
}

@end
