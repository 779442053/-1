//
//  MMChatBoxMoreViewItem.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMChatBoxMoreViewItem : UIView
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *imageName;


- (void)addTarget:(id)target action:(SEL)action
 forControlEvents:(UIControlEvents)controlEvents;

/**
 *  创建一个MMChatBoxMoreViewItem
 *
 *  @param title     item的标题
 *  @param imageName item的图片
 *
 *  @return item
 */
+ (MMChatBoxMoreViewItem *)createChatBoxMoreItemWithTitle:(NSString *)title
                                                imageName:(NSString *)imageName;
@end

NS_ASSUME_NONNULL_END
