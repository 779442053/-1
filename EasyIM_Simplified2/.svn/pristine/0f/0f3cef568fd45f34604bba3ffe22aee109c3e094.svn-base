//
//  MMChatHandler.m
//  EasyIM
//
//  Created by momo on 2019/4/18.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatHandler.h"

@interface MMChatHandler ()

//所有的代理
@property (nonatomic, strong) NSMutableArray *delegates;

@end

@implementation MMChatHandler

#pragma mark - 初始化聊天handler单例
+ (instancetype)shareInstance
{
    static MMChatHandler *handler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        handler = [[MMChatHandler alloc]init];
    });
    return handler;
}


- (NSMutableArray *)delegates
{
    
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    return _delegates;
}


#pragma mark - 添加代理
- (void)addDelegate:(id<MMChatHandlerDelegate>)delegate delegateQueue:(dispatch_queue_t)queue
{
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

#pragma mark - 移除代理
- (void)removeDelegate:(id<MMChatHandlerDelegate>)delegate
{
    [self.delegates removeObject:delegate];
}

@end
