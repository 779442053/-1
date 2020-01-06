//
//  NSMutableArray+ZWMutableARR.h
//  共享蜂
//
//  Created by  on 2017/12/17.
//  Copyright © 2017年. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (ZWMutableARR)
- (id)safeObjectAtIndex:(NSUInteger)index;

#pragma 增加或删除对象
- (void)insertObject:(id)object atIndexIfNotNil:(NSUInteger)index;
- (void)moveObjectAtIndex:(NSUInteger)index toIndex:(NSUInteger)toIndex;

#pragma mark - 排序
///重组数组(打乱顺序)
- (void)shuffle;
///数组倒序
- (void)reverse;
///数组去除相同的元素
- (void)unique;
///根据关键词 对本数组的内容进行排序  YES 升序 NO 降序
- (void)sorting:(NSString *)parameters ascending:(BOOL)ascending;

#pragma - mark 安全操作
-(void)addObj:(id)i;
-(void)addString:(NSString*)i;
-(void)addBool:(BOOL)i;
-(void)addInt:(int)i;
-(void)addInteger:(NSInteger)i;
-(void)addUnsignedInteger:(NSUInteger)i;
-(void)addCGFloat:(CGFloat)f;
-(void)addChar:(char)c;
-(void)addFloat:(float)i;
-(void)addPoint:(CGPoint)o;
-(void)addSize:(CGSize)o;
-(void)addRect:(CGRect)o;
@end
