//
//  MMEmotionPageView.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMEmotionPageView.h"

#import <SDAutoLayout.h>

#import "UIImage+Extension.h"
#import "UIView+Extension.h"

#import "MMMessageConst.h"
#import "MMEmotionButton.h"
#import "MMFaceManager.h"

@interface MMEmotionPageView ()

@property (nonatomic, weak) UIButton *deleteBtn;

@end


@implementation MMEmotionPageView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [deleteBtn setImage:[UIImage imageNamed:@"emotion_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteBtn];
        self.deleteBtn       =  deleteBtn;
    }
    return self;
}


#pragma mark - Private

- (void)deleteBtnClicked:(UIButton *)deleteBtn
{
    [[NSNotificationCenter defaultCenter] postNotificationName:GXEmotionDidDeleteNotification object:nil];// 通知出去
}

- (void)setEmotions:(NSArray *)emotions
{
    _emotions                   = emotions;
    NSUInteger count            = emotions.count;
    for (int i = 0; i < count; i ++) {
        MMEmotionButton *button = [[MMEmotionButton alloc] init];
        [self addSubview:button];
        button.emotion          = emotions[i];
        [button addTarget:self action:@selector(emotionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset            = 15;
    NSUInteger count         = self.emotions.count;
    CGFloat btnW             = (self.width - 2*inset)/MMEmotionMaxCols;
    CGFloat btnH             = (self.height - 2*inset)/MMEmotionMaxRows;
    for (int i = 0; i < count; i ++) {
        MMEmotionButton *btn = self.subviews[i + 1];//因为已经加了一个deleteBtn了
        btn.width            = btnW;
        btn.height           = btnH;
        btn.x                = inset + (i % MMEmotionMaxCols)*btnW;
        btn.y                = inset + (i / MMEmotionMaxCols)*btnH;
    }
    self.deleteBtn.width     = btnW;
    self.deleteBtn.height    = btnH;
    self.deleteBtn.x         = inset + (count%MMEmotionMaxCols)*btnW;
    self.deleteBtn.y         = inset + (count/MMEmotionMaxCols)*btnH;
}


- (void)emotionBtnClicked:(MMEmotionButton *)button
{
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[GXSelectEmotionKey]  = button.emotion;
    [[NSNotificationCenter defaultCenter] postNotificationName:GXEmotionDidSelectNotification object:nil userInfo:userInfo];
}


@end
