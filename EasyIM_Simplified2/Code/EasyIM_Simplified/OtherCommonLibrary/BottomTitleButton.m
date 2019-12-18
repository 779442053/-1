//
//  BottomTitleButton.m
//  auction
//
//  Created by 源库 on 2017/4/15.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "BottomTitleButton.h"

@interface BottomTitleButton ()

@property (nonatomic) float margin;

@end

@implementation BottomTitleButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithMargin:(float)margin {
    self = [super init];
    if (self) {
        _margin = margin;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float margin = _margin;
    CGSize size = self.bounds.size;
    CGSize labelSize = self.titleLabel.bounds.size;
    CGSize imageViewSize = self.imageView.bounds.size;
    self.imageView.frame = CGRectMake(size.width/2-imageViewSize.width/2,
                                      size.height/2-imageViewSize.height/2-labelSize.height/2-margin/2,
                                      imageViewSize.width,
                                      imageViewSize.height);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.frame = CGRectMake(0,
                                       size.height/2+imageViewSize.height/2-labelSize.height/2+margin/2,
                                       size.width,
                                       labelSize.height);
}

@end
