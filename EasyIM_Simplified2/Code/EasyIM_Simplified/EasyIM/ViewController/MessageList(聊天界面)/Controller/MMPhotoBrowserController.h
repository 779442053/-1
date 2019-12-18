//
//  MMPhotoBrowserController.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMPhotoBrowserController : UIViewController

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong,) UIImageView *imageView;


- (instancetype)initWithImage:(UIImage *)image;

- (instancetype)initWithImageUrlString:(NSString *)imageStr;

@end

NS_ASSUME_NONNULL_END
