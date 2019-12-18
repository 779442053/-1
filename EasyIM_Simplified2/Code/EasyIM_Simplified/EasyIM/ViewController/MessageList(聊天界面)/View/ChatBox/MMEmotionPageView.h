//
//  MMEmotionPageView.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMEmotion.h"
#import <SDAutoLayout.h>

NS_ASSUME_NONNULL_BEGIN

#define MMEmotionMaxRows 3
#define MMEmotionMaxCols 7
#define MMEmotionPageSize ((MMEmotionMaxRows * MMEmotionMaxCols) - 1)

@interface MMEmotionPageView : UIView

@property (nonatomic, strong) NSArray *emotions;

@end

NS_ASSUME_NONNULL_END
