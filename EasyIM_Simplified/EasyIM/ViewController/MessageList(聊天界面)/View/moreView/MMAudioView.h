//
//  MMAudioView.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMAudioView : UIView

@property (nonatomic, copy) NSString *audioName;

@property (nonatomic, copy) NSString *audioPath;

- (void)releaseTimer;

@end

NS_ASSUME_NONNULL_END
