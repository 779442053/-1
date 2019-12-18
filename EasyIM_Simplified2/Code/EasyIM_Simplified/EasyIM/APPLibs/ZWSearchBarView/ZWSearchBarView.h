//
//  ZWSearchBarView.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWSearchBarView : UIView
/* 搜搜b图片 */
@property (strong , nonatomic)UIImageView *searchImageView;
/* 占位文字 */
@property (strong , nonatomic)UILabel *placeholdLabel;

/** 搜索 */
@property (nonatomic, copy) dispatch_block_t searchViewBlock;
/**
 intrinsicContentSize
 */
@property(nonatomic, assign) CGSize intrinsicContentSize;
@end

NS_ASSUME_NONNULL_END
