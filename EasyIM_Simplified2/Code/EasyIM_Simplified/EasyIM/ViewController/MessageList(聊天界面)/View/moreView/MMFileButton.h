//
//  MMFileButton.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMFileButton : UIButton
@property (nonatomic, strong) MMMessage *messageModel;

@property (nonatomic, strong) UILabel *identLabel;

@property (nonatomic, strong) UIProgressView *progressView;
@end

NS_ASSUME_NONNULL_END
