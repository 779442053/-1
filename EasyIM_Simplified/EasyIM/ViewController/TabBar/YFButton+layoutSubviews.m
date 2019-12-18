//
//  YFButton+layoutSubviews.m
//  kin
//
//  Created by 源库 on 2017/3/9.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "YFButton+layoutSubviews.h"

@implementation YFButton (layoutSubviews)

-(void)layoutSubviews {
    [super layoutSubviews];
    
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width/2;
    center.y = self.imageView.frame.size.height/2+4.5;
    self.imageView.center = center;
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 2;
    newFrame.origin.y = 34;
    newFrame.size.width = self.frame.size.width;
    
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
