//
//  YFButton.m
//  YFTabBarController
//
//  Created by mashun on 15/8/26.
//  Copyright (c) 2015年 developer. All rights reserved.
//

#import "YFButton.h"
#import "YFButton+layoutSubviews.h"

static NSMutableDictionary *_normalImageDict;
static NSMutableDictionary *_selectedImageDict;
static NSMutableArray      *_normalArray;
static NSMutableArray      *_selectdArray;
static UIColor             *_selectedTitleColor;
static UIColor             *_normalTitleColor;

@implementation YFButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        //初始化
    }
    return self;
}




+ (id)buttonWithFrame:(CGRect)frame
            withIndex:(int)index
    withSelectedImage:(UIImage*)selectedImage
       andNormalImage:(UIImage*)normalImage
   selectedTitleColor:(UIColor *)selectedTitleColor
     normalTitleColor:(UIColor *)normalTitleColor {
    
    if (!_selectedTitleColor) {
        _selectedTitleColor = selectedTitleColor;
    }
    if (!_normalTitleColor) {
        _normalTitleColor = normalTitleColor;
    }
    
    if (!_normalImageDict) {
        _normalImageDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    if (!_selectedImageDict) {
        _selectedImageDict = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    if (!_normalArray) {
        _normalArray = [NSMutableArray arrayWithCapacity:1];
    }
    if (!_selectdArray) {
        _selectdArray = [NSMutableArray arrayWithCapacity:1];
    }
    
    YFButton *button = [YFButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    button.choiceType = YFChoiceButtonStatusTypeUnselected;
    button.index = index;
    NSString *imageKey = [NSString stringWithFormat:@"%d", index];
    if (normalImage) {
        [button setImage:normalImage forState:UIControlStateNormal];
        [_normalImageDict setObject:normalImage forKey:imageKey];
    }
    if (selectedImage) {
        [button setImage:selectedImage forState:UIControlStateHighlighted];
        [_selectedImageDict setObject:selectedImage forKey:imageKey];
    }
    [button addTarget:self
               action:@selector(buttonAction:)
     forControlEvents:UIControlEventTouchDown];
    if (button.choiceType == YFChoiceButtonStatusTypeUnselected) {
        [_normalArray addObject:button];
    }else {
        [_selectdArray addObject:button];
    }
    return button;
}

+ (void)buttonAction:(YFButton *)yfButton {
    if (yfButton.choiceType == YFChoiceButtonStatusTypeSelected) {
        return;
    }
    yfButton.choiceType = YFChoiceButtonStatusTypeSelected;
}

- (void)setChoiceType:(YFChoiceButtonStausType)choiceType {
    _choiceType = choiceType;
    NSString *strIndex = [NSString stringWithFormat:@"%d", self.index];
    if (choiceType == YFChoiceButtonStatusTypeSelected) {
        if (_selectedImageDict[strIndex]) {
            [self setImage:_selectedImageDict[strIndex] forState:UIControlStateNormal];
            [self setTitleColor:_selectedTitleColor forState:UIControlStateNormal];
        }
    }else {
        if (_normalImageDict[strIndex]) {
            [self setImage:_normalImageDict[strIndex] forState:UIControlStateNormal];
            [self setTitleColor:_normalTitleColor forState:UIControlStateNormal];
        }
    }
    if (choiceType == YFChoiceButtonStatusTypeSelected) {
        for (int i = 0; i < _selectdArray.count; i++) {
            YFButton *button = _selectdArray[i];
            button.choiceType = YFChoiceButtonStatusTypeUnselected;
        }
        [_normalArray removeObject:self];
        [_selectdArray addObject:self];
        if (self.delegate && [self.delegate respondsToSelector:@selector(YFChoiceButtonSelectedButton:)]) {
            [self.delegate YFChoiceButtonSelectedButton:self];
        }
    }else if (_choiceType == YFChoiceButtonStatusTypeUnselected) {
        [_normalArray addObject:self];
        [_selectdArray removeObject:self];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
