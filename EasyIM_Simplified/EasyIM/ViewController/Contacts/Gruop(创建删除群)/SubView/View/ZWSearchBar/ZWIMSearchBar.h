//
//  ZWIMSearchBar.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#define LYSearchBarDefaultHeight 60.0
typedef NS_ENUM(NSInteger, ZWBarStyle) {
    /** 默认样式*/
    ZWBarStyleDefault = 0,
    /** 系统 UISearchBar 默认样式*/
    ZWBarStyleSystem  = 1,
    /** 边框样式*/
    ZWBarStyleBorder  = 2,
};
NS_ASSUME_NONNULL_BEGIN
@class ZWIMSearchBar;
@protocol ZWIMSearchBarDelegate <NSObject>

@optional
/**
 更新搜索结果回调, 以下4种情况会触发
 1 searchBar 开始输入
 2 输入文本发生变化时 (若输入文本还未确认则不会触发,比如输入中文时,点击键盘确认按钮后才会触发)
 3 点击取消
 4 手动改变 active 的值
 
 如果想自行选择处理时机, 比如说只想在点击键盘搜索按钮时进行搜索操作, 则需要处理以下3个方法:
 ① searchBarTextDidBeginEditing:(点击搜索框) [根据 active 显示搜索结果,此时一般为空]
 ② searchBarSearchButtonClicked:(点击搜索按钮)[执行搜索操作并刷新数据]
 ③ searchBarCancelButtonClicked:(点击取消按钮)[根据 active 显示原始数据]
 
 @param searchBar searchBar对象
 */
- (void)updateSearchResultsForSearchBar:(ZWIMSearchBar *)searchBar;

// return NO to not become first responder
- (BOOL)searchBarShouldBeginEditing:(ZWIMSearchBar *)searchBar;

// called when text starts editing
- (void)searchBarTextDidBeginEditing:(ZWIMSearchBar *)searchBar;

// return NO to not resign first responder
- (BOOL)searchBarShouldEndEditing:(ZWIMSearchBar *)searchBar;

// called when text ends editing
- (void)searchBarTextDidEndEditing:(ZWIMSearchBar *)searchBar;

// called when text changes (including clear)
- (void)searchBar:(ZWIMSearchBar *)searchBar textDidChange:(NSString *)searchText;

// called before text changes
- (BOOL)searchBar:(ZWIMSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

// called when keyboard search button pressed(点击搜索按钮时触发)
- (void)searchBarSearchButtonClicked:(ZWIMSearchBar *)searchBar;

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(ZWIMSearchBar *)searchBar;

@end
@interface ZWIMSearchBar : UIView
@property(nonatomic, weak, nullable) id<ZWIMSearchBarDelegate> delegate;
@property(nonatomic, copy, nullable) NSString *text;
@property(nonatomic, copy, nullable) NSString *placeholder;
@property (nonatomic, assign) ZWBarStyle barStyle;
/**
 主要用来判断是否处于搜索状态
 也可主动设置来 开启/取消 搜索, 非必要情况不建议使用
 */
@property (nonatomic, assign, getter = isActive) BOOL active;

@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, strong, readonly) UIButton *cancelButton;
@end

NS_ASSUME_NONNULL_END
