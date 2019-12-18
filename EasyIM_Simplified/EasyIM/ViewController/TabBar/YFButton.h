//
//  YFButton.h
//  YFTabBarController
//
//  Created by mashun on 15/8/26.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YFButton;

typedef enum : NSUInteger {
    YFChoiceButtonStatusTypeUnselected,
    YFChoiceButtonStatusTypeSelected
} YFChoiceButtonStausType;

@protocol YFButtonDelegate <NSObject>

- (void)YFChoiceButtonSelectedButton:(YFButton *)button;

@end
@interface YFButton : UIButton

@property (nonatomic, assign) int index;
@property (nonatomic, assign) id<YFButtonDelegate>delegate;
@property (nonatomic, assign) YFChoiceButtonStausType choiceType;

/**
 创建tabbar使用的button

 @param frame 位置大小
 @param index 编号
 @param selectedImage 选中的图片
 @param normalImage 未选中的图片
 @param selectedTitleColor 选中的标题
 @param normalTitleColor 未选中的标题
 @return button
 */
+ (id)buttonWithFrame:(CGRect)frame
            withIndex:(int)index
    withSelectedImage:(UIImage*)selectedImage
       andNormalImage:(UIImage*)normalImage
   selectedTitleColor:(UIColor *)selectedTitleColor
     normalTitleColor:(UIColor *)normalTitleColor ;

@end
