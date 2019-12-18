//
//  YKHorizontalSelectView.h
//  auction
//
//  Created by 源库 on 2017/4/14.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YKHorizontalSelectView;
@protocol YKHorizontalSelectViewDataSource <NSObject>

- (NSInteger)numberOfItemsInSelectView:(YKHorizontalSelectView *)selectView;

- (NSString *)selectView:(YKHorizontalSelectView *)selectView titleForItemWithIndex:(NSInteger)index;

@optional

- (NSString *)selectView:(YKHorizontalSelectView *)selectView iconForItemWithIndex:(NSInteger)index;
- (NSString *)selectView:(YKHorizontalSelectView *)selectView iconSelectedForItemWithIndex:(NSInteger)index;

//- (UIView *)selectView:(YKHorizontalSelectView *)selectView viewForItemWithIndex:(NSInteger)index;
//
//- (NSString *)selectView:(YKHorizontalSelectView *)selectView badgeValueForItemWithIndex:(NSInteger)index;

@end

@protocol YKHorizontalSelectViewDelegate <NSObject>

- (void)selectView:(YKHorizontalSelectView *)selectView didSelectWithIndex:(NSInteger)index;

@optional

- (BOOL)selectView:(YKHorizontalSelectView *)selectView shouldSelectWithIndex:(NSInteger)index;

@end

@interface YKHorizontalSelectView : UIView

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) NSInteger selectIndex;
@property (nonatomic) NSInteger textfont;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, weak) id<YKHorizontalSelectViewDataSource> dataSource;
@property (nonatomic, weak) id<YKHorizontalSelectViewDelegate> delegate;

@end


