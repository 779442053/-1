//
//  ZWSurePlaceholderView.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWSurePlaceholderView.h"
@interface ZWSurePlaceholderView ()
@property (nonatomic, strong) UIButton *reloadButton;
@end
@implementation ZWSurePlaceholderView
- (void)layoutSubviews {
    [super layoutSubviews];
    [self createUI];
}
- (void)createUI {
    self.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1];
    
    
    [self addSubview:self.reloadButton];
}
- (UIButton*)reloadButton {
    if (!_reloadButton) {
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.image = self.image ? self.image : [UIImage imageNamed:@"search_empty_img"];
        iv.center = CGPointMake(self.center.x, self.center.y-50);
        
        [self addSubview:iv];
        
        _reloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _reloadButton.frame = CGRectMake(0, 0, 200, 50);
        _reloadButton.center = CGPointMake(self.center.x, CGRectGetMaxY(iv.frame)+CGRectGetHeight(_reloadButton.frame)/2.f);
        [_reloadButton setTitle:self.title.length > 0 ? self.title : @"暂无数据" forState:UIControlStateNormal];
        _reloadButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_reloadButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_reloadButton addTarget:self action:@selector(reloadClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reloadButton;
}

- (void)reloadClick:(UIButton*)button {
    if (self.reloadClickBlock) {
        self.reloadClickBlock();
    }
}

@end
