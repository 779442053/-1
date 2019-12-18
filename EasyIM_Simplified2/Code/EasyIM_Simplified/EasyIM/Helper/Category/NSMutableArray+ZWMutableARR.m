//
//  NSMutableArray+ZWMutableARR.m
//  共享蜂
//
//  Created by on 2017/12/17.
//  Copyright © 2017年 . All rights reserved.
//

#import "NSMutableArray+ZWMutableARR.h"
#import <objc/runtime.h>
@implementation NSMutableArray (ZWMutableARR)

+ (void)load {
    // 可变数组原本的方法
    Method method_mutableArray_objectAtIndex = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndex:));
    // 可变数组的安全方法
    Method method_mutableArray_safeObjectAtIndex = class_getInstanceMethod(NSClassFromString(@"NSMutableArray"),@selector(safeObjectAtIndex:));
    // 将可变数组的方法替换成安全方法
    method_exchangeImplementations(method_mutableArray_objectAtIndex, method_mutableArray_safeObjectAtIndex);
}

/**
 用来替换NSMutableArray的objectAtIndex:方法
 
 @param index 索引
 @return 对应的object
 */
- (id)safeObjectAtIndex:(NSUInteger)index {
    if (index >= self.count) {
        ZWWLog(@"可变数组越界了！");
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

#pragma 增加或删除对象

/**
 *  插入一个元素到指定位置
 *
 *  @param object 需要插入的元素
 *  @param index  位置
 */
- (void)insertObject:(id)object atIndexIfNotNil:(NSUInteger)index {
    if (self.count > index && object) {
        [self insertObject:object atIndex:index];
    }
}

/**
 *  移动对象 从一个位置到另一个位置
 *
 *  @param index   原位置
 *  @param toIndex 目标位置
 */
- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex {
    if (self.count > index && self.count > toIndex) {
        id object = [self objectAtIndex:index];
        if (index > toIndex) {
            [self removeObjectAtIndex:index];
            [self insertObject:object atIndex:toIndex];
        } else if (index < toIndex){
            [self removeObjectAtIndex:index];
            [self insertObject:object atIndex:toIndex - 1];
        }
    }
}

- (void)removeFirstObject {
    if (self.count > 0) {
        [self removeObjectAtIndex:0];
    }
}

#pragma mark - 排序
/**
 *  重组数组(打乱顺序)
 *
 */
- (void)shuffle {
    NSMutableArray *copy = [self mutableCopy];
    [self removeAllObjects];
    while ([copy count] > 0)
    {
        int index = arc4random() % [copy count];
        id objectToMove = [copy objectAtIndex:index];
        [self addObject:objectToMove];
        [copy removeObjectAtIndex:index];
    }
}

/**
 *  数组倒序
 *
 */
- (void)reverse {
    NSArray *reversedArray = [[self reverseObjectEnumerator] allObjects];
    [self removeAllObjects];
    [self addObjectsFromArray:reversedArray];
}

/**
 *  数组去除相同的元素
 */
- (void)unique {
    NSSet *set = [NSSet setWithArray:self];
    NSArray *array = [[NSArray alloc] initWithArray:[set allObjects]];
    [self removeAllObjects];
    [self addObjectsFromArray:array];}

/**
 *  根据关键词 对本数组的内容进行排序
 *
 *  @param parameters 关键词
 *  @param ascending  YES 升序 NO 降序
 *
 */
- (void)sorting:(NSString *)parameters ascending:(BOOL)ascending {
    NSSortDescriptor*sorter=[[NSSortDescriptor alloc]initWithKey:parameters ascending:ascending];
    NSMutableArray *sortDescriptors=[[NSMutableArray alloc]initWithObjects:&sorter count:1];
    NSArray *sortArray=[self sortedArrayUsingDescriptors:sortDescriptors];
    [self removeAllObjects];
    [self addObjectsFromArray:sortArray];
}

#pragma - mark 安全操作
/**
 *  添加新对象
 *
 *  @param i 添加的对象
 */
-(void)addObj:(id)i {
    if (i!=nil) {
        [self addObject:i];
    }
}

/**
 *  添加字符串
 *
 *  @param i 添加的字符串
 */
-(void)addString:(NSString*)i {
    if (i!=nil) {
        [self addObject:i];
    }
}

/**
 *  添加Bool
 *
 *  @param i 添加的Bool
 */
-(void)addBool:(BOOL)i {
    [self addObject:@(i)];
}

/**
 *  添加Int
 *
 *  @param i 添加的Int
 */
-(void)addInt:(int)i {
    [self addObject:@(i)];
}

/**
 *  添加Integer
 *
 *  @param i 添加的Integer
 */
-(void)addInteger:(NSInteger)i {
    [self addObject:@(i)];
}

/**
 *  添加UnsignedInteger
 *
 *  @param i 添加的UnsignedInteger
 */
-(void)addUnsignedInteger:(NSUInteger)i {
    [self addObject:@(i)];
}

/**
 *  添加CGFloat
 *
 *  @param ;;;i 添加的CGFloat
 */
-(void)addCGFloat:(CGFloat)f {
    [self addObject:@(f)];
}

/**
 *  添加Char
 *
 *  @param i 添加的Char
 */
-(void)addChar:(char)c {
    [self addObject:@(c)];
}

/**
 *  添加Float
 *
 *  @param i 添加的Float
 */
-(void)addFloat:(float)i {
    [self addObject:@(i)];
}

/**
 *  添加Point
 *
 *  @param i 添加的Point
 */
-(void)addPoint:(CGPoint)o {
    [self addObject:NSStringFromCGPoint(o)];
}

/**
 *  添加Size
 *
 *  @param i 添加的Size
 */
-(void)addSize:(CGSize)o {
    [self addObject:NSStringFromCGSize(o)];
}

/**
 *  添加Rect
 *
 *  @param i 添加的Rect
 */
-(void)addRect:(CGRect)o {
    [self addObject:NSStringFromCGRect(o)];
}

@end
