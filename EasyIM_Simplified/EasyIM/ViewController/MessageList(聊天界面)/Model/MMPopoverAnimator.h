//
//  MMPopoverAnimator.h
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^MMCompleteHandle)(BOOL presented);

@interface MMPopoverAnimator : NSObject<UIViewControllerAnimatedTransitioning,UIViewControllerTransitioningDelegate>

@property(nonatomic,assign)CGRect       presentedFrame;

+ (instancetype)popoverAnimatorCompleteHandle:(MMCompleteHandle)completeHandle;

- (void)setCenterViewSize:(CGSize)size;


@end

NS_ASSUME_NONNULL_END
