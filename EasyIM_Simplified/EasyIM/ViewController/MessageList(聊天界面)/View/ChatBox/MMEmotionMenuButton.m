//
//  MMEmotionMenuButton.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMEmotionMenuButton.h"

@implementation MMEmotionMenuButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        self.titleLabel.font  = [UIFont systemFontOfSize:15];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted
{
    
}
@end
