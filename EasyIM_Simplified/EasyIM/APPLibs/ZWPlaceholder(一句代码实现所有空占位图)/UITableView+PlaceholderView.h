//
//  UITableView+PlaceholderView.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/26.
//  Copyright © 2019 Looker. All rights reserved.
//




#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (PlaceholderView)
@property (nonatomic, strong)UIImage *placeholderImg;
@property (nonatomic, strong)NSString *placeholderText;

@property (nonatomic, strong)UIView *placeholderView; //设置此属性 会是上面属性无效
@end

NS_ASSUME_NONNULL_END
