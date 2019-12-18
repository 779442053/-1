//
//  FrdList.m
//  EasyIM
//
//  Created by 魏勇城 on 2019/2/21.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "FrdList.h"

@implementation FrdList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"user":[UserFriendModel class]};
    
}

@end
