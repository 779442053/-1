//
//  MMHeadImageView.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMHeadImageView.h"

@interface MMHeadImageView ()

@property (nonatomic, assign) CGFloat bordering;

@end


@implementation MMHeadImageView

- (instancetype)init
{
    if (self = [super init]) {
        [self addSubview:self.imageView];
        
        self.layer.masksToBounds  = YES;
        self.backgroundColor      = MMRGB(0xf0f0f0);
        //        self.bordering            = 4;
        self.bordering            = 0;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}


- (void)layoutSubviews
{
  
    self.imageView.width = self.frame.size.width - _bordering;
    self.imageView.height = self.frame.size.height - _bordering;
    
    self.imageView.centerX = self.width*0.5;
    self.imageView.centerY = self.height*0.5;
}

- (void)setColor:(UIColor *)color bording:(CGFloat)bord
{
    self.backgroundColor = color;
    self.bordering       = bord;
}

- (UIImageView *)imageView
{
    if (nil == _imageView) {
        _imageView = [[UIImageView alloc] init];
        
        _imageView.layer.masksToBounds = YES;
        _imageView.layer.cornerRadius = 3;
    }
    return _imageView;
}


@end
