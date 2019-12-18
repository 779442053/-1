//
//  ZWSurePlaceholderView.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWSurePlaceholderView : UIView
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, copy) void(^reloadClickBlock)(void);
@end

NS_ASSUME_NONNULL_END
