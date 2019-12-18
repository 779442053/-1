//
//  NSArray+ZWARR.m
//  共享蜂
//
//  Created by on 2017/12/17.
//  Copyright © 2017年 . All rights reserved.
//

#import "NSArray+ZWARR.h"
#import <objc/runtime.h>
@implementation NSArray (ZWARR)

+ (void)load {
    // 不可变数组原本的方法
    Method method_immutableArray_objectAtIndex = class_getInstanceMethod(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:));
    // 不可变数组的安全方法
    Method method_immutableArray_safeObjectAtIndex = class_getInstanceMethod(NSClassFromString(@"NSArray"),@selector(safeObjectAtIndex:));
    // 将不可变数组的方法替换成安全方法
    method_exchangeImplementations(method_immutableArray_objectAtIndex, method_immutableArray_safeObjectAtIndex);
}

/**
 用来替换NSArray的objectAtIndex:方法
 
 @param index 索引
 @return 对应的object
 */
- (id)safeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        NSLog(@"不可变数组越界了！");
        return nil;
    }else{
        __block id returnObj = nil;
        [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (index == idx) {
                returnObj = obj;
            }
        }];
        
        return returnObj;
    }
}

- (BOOL)isEqualToAnotherArray:(NSArray *)array {
    
    BOOL equal = YES;//默认相等
    
    if (self.count != array.count) {//肯定是不等的
        equal = NO;
        return equal;
    }
    for (NSString *son in self) {
        if (![array containsObject:son]) {//只要A数组中有一个元素不在B数组，就不相等
            equal = NO;
            break;
        }
    }
    
    
    return equal;
}
@end
