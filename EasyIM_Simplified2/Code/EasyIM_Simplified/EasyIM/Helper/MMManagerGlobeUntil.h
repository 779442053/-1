//
//  MMManagerGlobeUntil.h
//  EasyIM
//
//  Created by momo on 2019/5/8.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMManagerGlobeUntil : NSObject

//System
@property (nonatomic, assign) BOOL isNetConnect;                   //网络是否连接
@property (nonatomic, assign) BOOL isWIFI;                   //是否是WiFi

//ToUser
@property (nonatomic, copy) NSString *toUid;//对方的Id
@property (nonatomic, copy) NSString *userName;//对方的昵称

+ (instancetype)sharedManager;

- (void)managerReachability;


NSString* MMDescriptionForError(NSError* error);

@end

NS_ASSUME_NONNULL_END
