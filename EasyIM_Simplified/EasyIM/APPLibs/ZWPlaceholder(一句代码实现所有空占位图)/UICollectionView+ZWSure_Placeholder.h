//
//  UICollectionView+ZWSure_Placeholder.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//




#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (ZWSure_Placeholder)
@property (nonatomic, assign) BOOL firstReload;
@property (nonatomic, strong) UIView *placeholderView;
@property (nonatomic, copy) void(^reloadBlock)(void);
@end

NS_ASSUME_NONNULL_END
