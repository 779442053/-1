//
//  MMEmotionButton.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMEmotion.h"
#import <SDAutoLayout.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMEmotionButton : UIButton

@property (nonatomic, strong) MMEmotion *emotion;

@end

NS_ASSUME_NONNULL_END
