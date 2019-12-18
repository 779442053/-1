//
//  HorizontalSelectCollectionViewCell.m
//  auction
//
//  Created by 源库 on 2017/4/14.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "HorizontalSelectCollectionViewCell.h"
#import "YKRightTitleButton.h"

@implementation HorizontalSelectCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        YKRightTitleButton *btn = [[YKRightTitleButton alloc]initWithMargin:8];
        [self.contentView addSubview:btn];
        btn.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        [btn setTitleColor:[UIColor colorWithHexString:@"3d4245"] forState:UIControlStateNormal];
        btn.userInteractionEnabled = NO;
        _button = btn;
    }
    return self;
}

@end
