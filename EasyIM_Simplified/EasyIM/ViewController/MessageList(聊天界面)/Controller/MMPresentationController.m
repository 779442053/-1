//
//  MMPresentationController.m
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMPresentationController.h"

@implementation MMPresentationController

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    
    // 设置弹出视图尺寸
    self.presentedView.frame = CGRectMake(self.containerView.center.x - self.presentedSize.width * 0.5, self.containerView.center.y - self.presentedSize.height * 0.5, self.presentedSize.width, self.presentedSize.height);
    
    //添加蒙版
    [self.containerView insertSubview:self.coverView atIndex:0];
}

- (UIView *)coverView
{
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        _coverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2f];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewClick)];
        [_coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (void)coverViewClick
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
