//
//  MMTitleView.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMSearchBar;

@protocol MMTitleViewDelegate <NSObject>

- (void)cancelBtnClicked;

- (void)searchText:(NSString *)text;

@end

@interface MMTitleView : UIView
@property (nonatomic, weak) id<MMTitleViewDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
