//
//  MMGCDAsyncSocketManager.m
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMGCDAsyncSocketManager.h"
#import <GCDAsyncSocket.h>
#import "ZWMessage.h"
static const NSInteger TIMEOUT = 30;       //超时时间

@interface MMGCDAsyncSocketManager ()

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, assign) NSInteger beatCount;         // 发送心跳次数,用于重连
@property (nonatomic, strong) NSTimer *beatTimer;          // 心跳定时器
@property (nonatomic, strong) NSTimer *reconnectTimer;     // 重连定时器
@property (nonatomic, strong) NSString *host;              // socket连接的host地址
@property (nonatomic, assign) uint16_t port;               // sokcet连接的port

@end

@implementation MMGCDAsyncSocketManager

+ (MMGCDAsyncSocketManager *)sharedInstance
{
    static MMGCDAsyncSocketManager *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    
    self = [super init];
    if (!self) {
        return nil;
    }
    self.connectStatus = -1;
    self.reconnectionCount = 0;
    
    return self;
}

#pragma mark - Socket Method
- (void)changeHost:(NSString *)host port:(NSInteger)port
{
    self.host = host;
    self.port = port;
    ZWWLog(@"host = %@  port = %d",self.host,self.port)
}
- (void)connectSocketWithDelegate:(id)delegate
{
    if (self.connectStatus !=-1) {
        MMLog(@"Socket连接中 或已连接");
        return;
    }
    self.connectStatus = 0;
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:delegate delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    ZWWLog(@"开始进行socket长连接host=%@ port= %hu",self.host,self.port)
    if (![self.socket connectToHost:self.host onPort:self.port withTimeout:TIMEOUT error:&error]) {
        self.connectStatus = -1;
        [ZWMessage error:@"连接失败!!" title:[NSString stringWithFormat:@"Socket连接错误-----%@",error]];
        ZWWLog(@"Socket连接错误-----%@",error);
    }
    else{
        [ZWMessage success:@"测试使用" title:@"socket连接成功!!"];
        ZWWLog(@"Socket连接成功");
    }
}
/**
 发送心跳包

 @param beatBody 心跳String
 */
- (void)socketDidConnectBeginSendBeat:(NSString *)beatBody
{
    
    self.connectStatus = 1;
    self.reconnectionCount = 0;
    if (!self.beatTimer) {
        self.beatTimer = [NSTimer scheduledTimerWithTimeInterval:30.0
                                                          target:self
                                                        selector:@selector(sendBeat:)
                                                        userInfo:beatBody
                                                         repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.beatTimer forMode:NSRunLoopCommonModes];
    }
    
}

- (void)socketDidDisconectBeginSendReconnect:(NSString *)reconnectBody
{
    self.connectStatus = -1;
    if (self.reconnectionCount >= 0) {
        ZWWLog(@"%@",reconnectBody);
        ZWWLog(@"开始重新连接重连次数%zd",self.reconnectionCount);
        
        NSTimeInterval time = pow(2, self.reconnectionCount);
        
        ZWWLog(@"重连间隔==%f",time);
        
        if (!self.reconnectTimer) {
            self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                                   target:self
                                                                 selector:@selector(reconnection:)
                                                                 userInfo:reconnectBody
                                                                  repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.reconnectTimer forMode:NSRunLoopCommonModes];
        }
        self.reconnectionCount++;
    } else {
        [self.reconnectTimer invalidate];
        self.reconnectTimer = nil;
        self.reconnectionCount = 0;
    }
}

- (void)socketWriteData:(NSString *)data
{
    NSData *requestData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:requestData withTimeout:-1 tag:200];
    [self socketBeginReadData];
}

- (void)socketBeginReadData
{
    
    [self.socket readDataWithTimeout:-1 tag:200];
}

- (void)disconnectSocket
{
    
    self.connectStatus = -1;
    self.reconnectionCount = 0;

    [self.socket disconnect];
    self.socket = nil;
    
    [self.beatTimer invalidate];
    self.beatTimer = nil;
    
}

#pragma mark - Public method

- (void)resetBeatCount
{
    self.beatCount = 0;
}

#pragma mark - Private method

- (void)sendBeat:(NSTimer *)timer
{
    
//    if (self.beatCount >= kBeatLimit) {
//        [self disconnectSocket];
//        return;
//    } else {
//        self.beatCount++;
//    }
    
    if (timer != nil) {
        [self socketWriteData:timer.userInfo];
    }
    
}

- (void)reconnection:(NSTimer *)timer
{
    NSError *error = nil;
    if (![self.socket connectToHost:self.host onPort:self.port withTimeout:TIMEOUT error:&error]) {
        self.connectStatus = -1;
    }
}


@end
