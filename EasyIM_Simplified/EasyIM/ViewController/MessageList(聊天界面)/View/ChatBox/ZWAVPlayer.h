//
//  ZWAVPlayer.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/16.
//  Copyright © 2020 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWAVPlayer : UIView
- (instancetype)initWithFrame:(CGRect)frame withShowInView:(UIView *)bgView url:(NSURL *)url;

@property (copy, nonatomic) NSURL *videoUrl;

- (void)stopPlayer;
@end

NS_ASSUME_NONNULL_END
