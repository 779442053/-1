//
//  MMButton.h
//  EasyIM
//
//  Created by momo on 2019/5/7.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMButtonState :NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIImage *image;

@end


@interface MMButton : UIControl

@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithTitle:(NSString *)aTitle
                       target:(id)aTarget
                       action:(SEL)aAction;

- (void)setTitle:(nullable NSString *)title
        forState:(UIControlState)state;

- (void)setTitleColor:(nullable UIColor *)color
             forState:(UIControlState)state;

- (void)setImage:(nullable UIImage *)image
        forState:(UIControlState)state;


@end

NS_ASSUME_NONNULL_END
