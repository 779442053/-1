//
//  JJTableViewIndexView.h
//  索引
//
//  Created by 欧家俊 on 16/12/21.
//  Copyright © 2016年 欧家俊. All rights reserved.
//

#import <UIKit/UIKit.h>

//索引label的tag值(防止冲突)
#define TAG 1024

//动画的半径
#define ANIMATION_RADIUS 80

//透明度变化率
#define ALPHA_RATE 1/80

typedef void (^MyBlock)(NSInteger);

@interface JJTableViewIndexView : UIView
#pragma mark - 属性
/**
 图片数组
 */
@property (nonatomic,strong) NSArray * imageNameArray;

/**
 文本数组
 */
@property (nonatomic,strong) NSArray * stringNameArray;

/**
 动画视图(可自定义)
 */
@property (nonatomic,strong) UIImageView * centerImageShowView;

/**
 动画视图(可自定义)
 */
@property (nonatomic,strong) UILabel * centerLableShowView;

/**
 滑动回调block
 */
@property (nonatomic,copy) MyBlock selectedBlock;

#pragma mark - 方法
/**
 *  index滑动反馈
 */
-(void)selectIndexBlock:(MyBlock)block;

/**
 实例化方法
 */
- (instancetype)initWithFrame:(CGRect)frame imageNameArray:(NSArray *)array;

/**
 实例化方法
 */
- (instancetype)initWithFrame:(CGRect)frame stringNameArray:(NSArray *)array;

@end
