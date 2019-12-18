//
//  SHBCustomTextField.m
//  SaleTool
//
//  Created by ganshiwei on 16/10/31.
//  Copyright © 2016年 rongkai. All rights reserved.
//

#import "ANCustomTextField.h"

#define UIColorFromHexForAlpha(rgbValue, a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define UIColorFromHex(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

#define ANMainColor UIColorFromHex(0x343e47)

@interface ANCustomTextField ()

@property (strong, nonatomic) UIButton *rightButton;

@end

@implementation ANCustomTextField

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
//        [self setValue:UIColorFromHexForAlpha(0xffffff, 0.2) forKeyPath:@"_placeholderLabel.textColor"];
        [self setupRightView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
//        [self setValue:UIColorFromHexForAlpha(0xffffff, 0.2) forKeyPath:@"_placeholderLabel.textColor"];
        [self setupRightView];
    }
    return self;
}

- (void)setupRightView{
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(0, 0,40 , 40);
    [_rightButton addTarget:self action:@selector(changeTextEntryType:) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = _rightButton;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect iconRect = [super leftViewRectForBounds:bounds];
    iconRect.origin.x += 8;
    return iconRect;
}

//UITextField 文字与输入框的距离
- (CGRect)textRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, _leftPadding, 0);
}

//控制文本的位置
- (CGRect)editingRectForBounds:(CGRect)bounds{
    return CGRectInset(bounds, _leftPadding, 0);
}

- (void)setHasBorder:(BOOL)hasBorder{
    _hasBorder = hasBorder;
    if (hasBorder) {
        self.layer.borderColor = ANMainColor.CGColor;
        self.layer.borderWidth = 0.5;
    }
}

- (void)setHasBottomBorder:(BOOL)hasBottomBorder{
    _hasBottomBorder = hasBottomBorder;
    
    if (hasBottomBorder) {
        if (!_bottomLine) {
            _bottomLine = [[UILabel alloc] init];
            _bottomLine.frame = CGRectMake(0, self.frame.size.height - 1.0, self.frame.size.width, 1.0);
            [self addSubview:_bottomLine];
        }
    }
    else{
        if (_bottomLine) {
            [_bottomLine removeFromSuperview];
            _bottomLine = nil;
        }
    }
}

- (void)setRightNormalImage:(UIImage *)rightNormalImage{
    _rightNormalImage = rightNormalImage;
    self.rightViewMode = UITextFieldViewModeAlways;
    [_rightButton setImage:_rightNormalImage forState:UIControlStateNormal];
}

- (void)setRightSelectedImage:(UIImage *)rightSelectedImage{
    _rightSelectedImage = rightSelectedImage;
    [_rightButton setImage:_rightSelectedImage forState:UIControlStateSelected];
}

- (void)setLeftNormalImage:(UIImage *)leftNormalImage{
    _leftNormalImage = leftNormalImage;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.leftView = [[UIImageView alloc] initWithImage:_leftNormalImage];
}

- (void)changeTextEntryType:(UIButton *)button{
    button.selected = !button.selected;
    if ([self.p_delegate respondsToSelector:@selector(textFieldRightViewDidSelect:selected:)]) {
        [self.p_delegate textFieldRightViewDidSelect:self selected:button.selected];
    }
}

@end
