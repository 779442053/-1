//
//  ZWProgressView.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/16.
//  Copyright © 2020 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWProgressView : UIView
@property (assign, nonatomic) NSInteger timeMax;
- (void)clearProgress;
@end

NS_ASSUME_NONNULL_END
