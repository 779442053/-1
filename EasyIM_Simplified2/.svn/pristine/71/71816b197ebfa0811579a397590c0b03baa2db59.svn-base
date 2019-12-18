//
//  MMPopoverAnimator.m
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMPopoverAnimator.h"
#import "MMPresentationController.h"

#define kAnimationDuration 0.3

@interface MMPopoverAnimator ()
{
    BOOL                       _isPresented;
    CGSize                     _presentedSize;
}


@property(nonatomic,strong)MMPresentationController  *presentationController;

@property(nonatomic,copy)  MMCompleteHandle           completeHandle;

@end

@implementation MMPopoverAnimator

+ (instancetype)popoverAnimatorCompleteHandle:(MMCompleteHandle)completeHandle
{
    MMPopoverAnimator *popoverAnimator = [[MMPopoverAnimator alloc] init];
    popoverAnimator.completeHandle = completeHandle;
    return popoverAnimator;
}

#pragma mark - UIViewControllerTransitioningDelegatere

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    MMPresentationController *presentation = [[MMPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    
    presentation.presentedSize = _presentedSize;
    self.presentationController = presentation;
    return presentation;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    
    _isPresented = YES;
    !self.completeHandle?:self.completeHandle(_isPresented);
    return self;
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    
    _isPresented = NO;
    !self.completeHandle? :self.completeHandle(_isPresented);
    return self;
}

#pragma mark - <UIViewControllerAnimatedTransitioning>
- (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext
{
    return kAnimationDuration;
}

- (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    _isPresented?[self animationForPresentedView:transitionContext]:[self animationForDismissedView:transitionContext];
}

#pragma mark - animationMethod

// Presented
- (void)animationForPresentedView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextToViewKey];
    [transitionContext.containerView addSubview:presentedView];
    self.presentationController.coverView.alpha = 0.0f;
    
    // 设置阴影
//    transitionContext.containerView.layer.shadowColor = [UIColor blackColor].CGColor;
//    transitionContext.containerView.layer.shadowOffset = CGSizeMake(0, 5);
//    transitionContext.containerView.layer.shadowOpacity = 0.5f;
//    transitionContext.containerView.layer.cornerRadius = 8.0f;
    
    WEAKSELF
    presentedView.alpha = 0.0f;
    presentedView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    // 动画弹出
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.presentationController.coverView.alpha = 1.0f;
        presentedView.alpha = 1.0f;
        presentedView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
    
    
}

// Dismissed
- (void)animationForDismissedView:(nonnull id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *presentedView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    WEAKSELF
    // 消失
    [UIView animateWithDuration:kAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.presentationController.coverView.alpha = 0.0f;
        presentedView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [presentedView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
    
}

#pragma mark - Setting

- (void)setCenterViewSize:(CGSize)size
{
    _presentedSize = size;
}


@end
