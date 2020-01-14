//
//  UIViewController+MMPopover.m
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "UIViewController+MMPopover.h"

static const char popoverAnimatorKey;

@implementation UIViewController (MMPopover)

- (MMPopoverAnimator *)popoverAnimator
{
    return objc_getAssociatedObject(self, &popoverAnimatorKey);
}
- (void)setPopoverAnimator:(MMPopoverAnimator *)popoverAnimator
{
    objc_setAssociatedObject(self, &popoverAnimatorKey, popoverAnimator, OBJC_ASSOCIATION_RETAIN) ;
}
- (void)mm_PresentController:(UIViewController *)viewController completeHandle:(MMCompleteHandle)completion
{
    self.popoverAnimator = [MMPopoverAnimator popoverAnimatorCompleteHandle:completion];
    [self.popoverAnimator setCenterViewSize:CGSizeMake(SCREEN_WIDTH-2*30, 300)];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self.popoverAnimator;
    [self presentViewController:viewController animated:YES completion:nil];
}


@end
