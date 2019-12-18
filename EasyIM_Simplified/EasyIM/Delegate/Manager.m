//
//  Manger.m
//  MultiDelegateDemo
//
//  Created by JiangMing on 2017/3/20.
//  Copyright © 2017年 JiangMing. All rights reserved.
//

#import "Manager.h"

@interface Manager()

{
    MultiDelegate<ManagerDelegate>     *_multiDelegate;
    
}

@end

@implementation Manager

+ (instancetype)shareManager{
    static Manager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}


- (id)init {
    if (self = [super init]) {
        _multiDelegate = (MultiDelegate<ManagerDelegate> *)[[MultiDelegate alloc] init];
        _multiDelegate.silentWhenEmpty = YES;
    }
    return self;
}


#pragma mark - Public Methods
- (void)addDelegate:(id<ManagerDelegate>)delegate{
    if (delegate && ![_multiDelegate.delegates.allObjects containsObject:delegate]) {
        [_multiDelegate addDelegate:delegate];
    }
}

- (void)removeDelegate:(id<ManagerDelegate>)delegate{
    [_multiDelegate removeDelegate:delegate];
}

- (void)clearAllDelegates{
    [_multiDelegate removeAllDelegates];
}


- (void)reciveBottonClick:(NSString *)sendMsg{
    
    [_multiDelegate manager:self didBottonClick:sendMsg];
    
    [_multiDelegate manager:self sendMsg:sendMsg];
}


@end
