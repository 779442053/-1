//
//  MMPresentationController.h
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMPresentationController : UIPresentationController

@property (nonatomic, assign) CGSize           presentedSize;
@property (nonatomic, assign) CGFloat          presentedHeight;

@property (nonatomic, strong) UIView           *coverView;

@end

NS_ASSUME_NONNULL_END
