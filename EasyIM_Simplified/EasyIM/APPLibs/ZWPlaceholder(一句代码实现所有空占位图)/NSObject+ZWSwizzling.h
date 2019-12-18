//
//  NSObject+ZWSwizzling.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//




#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ZWSwizzling)
//交换方法,监听tabview的reload 方法.检测数据源是否是空.
+ (void)methodSwizzlingWithOriginalSelector:(SEL)originalSelector
bySwizzledSelector:(SEL)swizzledSelector;
@end

NS_ASSUME_NONNULL_END
