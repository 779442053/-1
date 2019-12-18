//
//  ZWSearchBarView.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWSearchBarView.h"
static bool closeIntrinsic = false;//Intrinsic的影响
/** 常量数 */
CGFloat const DCMargin = 45;
@implementation ZWSearchBarView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUI];
        UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(searchClick)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
/**
 通过覆盖intrinsicContentSize函数修改自定义View的Intrinsic的大小
 @return CGSize
 */
-(CGSize)intrinsicContentSize
{
    if (closeIntrinsic) {
        return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
    } else {
        return CGSizeMake(self.width, self.height);
    }
}
- (void)setUpUI
{
    self.backgroundColor = [UIColor whiteColor];
    _placeholdLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    _placeholdLabel.font = [UIFont zwwNormalFont:12];
    _placeholdLabel.textColor = [UIColor colorWithHexString:@"C3C3C5"];
    [self addSubview:_placeholdLabel];
    [self addSubview:self.searchImageView];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    _placeholdLabel.frame = CGRectMake(DCMargin, 0, self.width - 50, self.height);
    
    [_placeholdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        [make.left.equalTo(self)setOffset:DCMargin];
        make.top.equalTo(self);
        make.height.equalTo(self);
    }];
    [_searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        [make.left.equalTo(self)setOffset:10];
        make.centerY.mas_equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    //设置边角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(2, 2)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
-(UIImageView *)searchImageView{
    if (_searchImageView == nil) {
        _searchImageView = [[UIImageView alloc]init];
        _searchImageView.image = [UIImage imageNamed:@"contact_search"];
    }
    return _searchImageView;
}
#pragma mark - Intial
- (void)awakeFromNib {
    [super awakeFromNib];
}
#pragma mark - Setter Getter Methods

- (void)searchClick
{
    !_searchViewBlock ?: _searchViewBlock();
}
@end
