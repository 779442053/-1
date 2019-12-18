//
//  UIViewController+MMPopover.h
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMPopoverAnimator.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^MMCompleteHandle)(BOOL presented);

@interface UIViewController (MMPopover)

@property (nonatomic, strong) MMPopoverAnimator        *popoverAnimator;

- (void)mm_PresentController:(UIViewController *)viewController completeHandle:(MMCompleteHandle)completion;


@end

NS_ASSUME_NONNULL_END
