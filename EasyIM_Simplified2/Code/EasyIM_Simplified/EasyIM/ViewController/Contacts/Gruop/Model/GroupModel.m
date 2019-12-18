//
//  GroupModel.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/25.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "GroupModel.h"

@implementation GroupModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"group":[List class]};
    
}

@end

@implementation List

+ (NSDictionary *)modelContainerPropertyGenericClass {
    
    return @{@"group":[GroupList class]};
    
}

@end

@implementation GroupList

@end
