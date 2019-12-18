//
//  MMGlobalVariables.m
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMGlobalVariables.h"

BOOL isCalling = NO;

static MMGlobalVariables *shared = nil;

@implementation MMGlobalVariables

+ (instancetype)shareGlobal
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[MMGlobalVariables alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

@end

