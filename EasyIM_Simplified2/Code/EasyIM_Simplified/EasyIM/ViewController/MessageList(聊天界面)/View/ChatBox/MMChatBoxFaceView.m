//
//  MMChatBoxFaceView.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMChatBoxFaceView.h"

#import "MMChatBoxMenuView.h"
#import "MMEmotionListView.h"
#import "MMFaceManager.h"

#define bottomViewH 36.0

@interface MMChatBoxFaceView ()<UIScrollViewDelegate,MMChatBoxMenuDelegate>

@property (nonatomic, weak) MMEmotionListView *showingListView;

@property (nonatomic, strong) MMEmotionListView *emojiListView;
@property (nonatomic, strong) MMEmotionListView *custumListView;
@property (nonatomic, strong) MMEmotionListView *gifListView;

@property (nonatomic, weak) MMChatBoxMenuView *menuView;

@end

@implementation MMChatBoxFaceView

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        MMChatBoxMenuView *menuView = [[MMChatBoxMenuView alloc] init];
        [menuView setDelegate:self];
        [self addSubview:menuView];
        _menuView = menuView;
        self.custumListView.emotions = [MMFaceManager customEmotion];
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            self.custumListView.emotions = [MMFaceManager customEmotion];
//        });
        
        // 如果表情选中的时候需要动画或者其它操作,则在这里监听通知
    }
    return self;
}



#pragma mark - Private

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.menuView.width         = self.width;
    self.menuView.height        = bottomViewH;
    self.menuView.x             = 0;
    self.menuView.y             = self.height - self.menuView.height;
    
    self.showingListView.x      = self.showingListView.y = 0;
    self.showingListView.width  = self.width;
    self.showingListView.height = self.menuView.y;
}


#pragma mark - MMChatBoxMenuDelegate

- (void)emotionMenu:(MMChatBoxMenuView *)menu didSelectButton:(MMEmotionMenuButtonType)buttonType
{
    [self.showingListView removeFromSuperview];
    switch (buttonType) {
        case MMEmotionMenuButtonTypeCuston:
            [self addSubview:self.custumListView];
            break;
        case MMEmotionMenuButtonTypeEmoji:
            [self addSubview:self.emojiListView];
            break;
        case MMEmotionMenuButtonTypeGif:
            [self addSubview:self.gifListView];
            break;
        default:
            break;
    }
    self.showingListView = [self.subviews lastObject];
    [self setNeedsLayout];
}


#pragma mark - Getter

- (MMEmotionListView *)emojiListView
{
    if (!_emojiListView) {
        _emojiListView           = [[MMEmotionListView alloc] init];
//        _emojiListView.emotions  = [MMFaceManager emojiEmotion];
    }
    return _emojiListView;
}

- (MMEmotionListView *)gifListView
{
    if (!_gifListView) {
        _gifListView             = [[MMEmotionListView alloc] init];
    }
    return _gifListView;
}

- (MMEmotionListView *)custumListView
{
    if (!_custumListView) {
        _custumListView          = [[MMEmotionListView alloc] init];
        _custumListView.emotions = [MMFaceManager customEmotion];
    }
    return _custumListView;
}


@end
