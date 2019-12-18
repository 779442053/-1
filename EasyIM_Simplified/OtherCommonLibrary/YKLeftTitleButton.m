//
//  YKLeftTitleButton.m
//  hjqinspection
//
//  Created by 源库 on 2017/3/22.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "YKLeftTitleButton.h"

@interface YKLeftTitleButton ()

@property (nonatomic) float margin;

@end

@implementation YKLeftTitleButton

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
    self.imageView.frame = CGRectMake(size.width/2-imageViewSize.width/2+labelSize.width/2+margin/2,
                                      size.height/2-imageViewSize.height/2,
                                      imageViewSize.width,
                                      imageViewSize.height);
    self.titleLabel.frame = CGRectMake(size.width/2-imageViewSize.width/2-labelSize.width/2-margin/2,
                                       size.height/2-labelSize.height/2,
                                       labelSize.width,
                                       labelSize.height);
}

@end
