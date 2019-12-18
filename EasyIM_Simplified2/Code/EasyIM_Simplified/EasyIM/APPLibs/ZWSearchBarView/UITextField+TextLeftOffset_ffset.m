//
//  UITextField+TextLeftOffset_ffset.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "UITextField+TextLeftOffset_ffset.h"

@implementation UITextField (TextLeftOffset_ffset)
- (void)setTextOffsetWithLeftViewRect : (CGRect)rect WithMode :(UITextFieldViewMode)mode
{
    UIView *view = [[UIView alloc]initWithFrame:rect];
    self.leftView = view;
    self.leftViewMode = mode; //枚举 默认为no 不显示leftView
}
@end
