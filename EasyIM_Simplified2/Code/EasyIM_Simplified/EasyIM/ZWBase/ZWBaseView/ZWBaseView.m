//
//  ZWBaseView.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseView.h"
#import "UIColor+ZWColor.h"
#import "UIFont+ZWFont.h"
@implementation ZWBaseView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self zw_setupViews];
        [self zw_bindViewModel];
    }
    return self;
}

- (instancetype)initWithViewModel:(id<ZWBaseViewModelProtocol>)viewModel {
    
    self = [super init];
    if (self) {
    
        [self zw_setupViews];
        [self zw_bindViewModel];
    }
    return self;
}

- (void)zw_bindViewModel {
}

- (void)zw_setupViews {
}
//手指轻点击view时候,键盘下去==也可以在appdele里面用第三方实现
- (void)zw_addReturnKeyBoard {
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [tap.rac_gestureSignal subscribeNext:^(id x) {
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window endEditing:YES];
    }];
    [self addGestureRecognizer:tap];
}

@end
