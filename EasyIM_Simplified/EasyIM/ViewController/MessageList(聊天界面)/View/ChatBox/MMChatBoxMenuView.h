//
//  MMChatBoxMenuView.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    MMEmotionMenuButtonTypeEmoji = 100,
    MMEmotionMenuButtonTypeCuston,
    MMEmotionMenuButtonTypeGif
    
} MMEmotionMenuButtonType;

@class MMChatBoxMenuView;

@protocol MMChatBoxMenuDelegate <NSObject>

@optional
- (void)emotionMenu:(MMChatBoxMenuView *)menu
    didSelectButton:(MMEmotionMenuButtonType)buttonType;

@end


@interface MMChatBoxMenuView : UIView

@property (nonatomic, weak)id <MMChatBoxMenuDelegate>delegate;


@end

NS_ASSUME_NONNULL_END
