//
//  ZWBaseTableViewCell.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWBaseTableViewCell : UITableViewCell
- (void)zw_setupViews;
- (void)zw_bindViewModel;
@end

NS_ASSUME_NONNULL_END
