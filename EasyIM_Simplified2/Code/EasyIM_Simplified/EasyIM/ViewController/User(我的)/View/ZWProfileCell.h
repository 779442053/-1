//
//  ZWProfileCell.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/3.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWProfileCell : ZWBaseTableViewCell
-(void)updateWithTitle:(NSString *)title subTitle:(NSString *)subtitle indexPath:(NSIndexPath*)indexpath;
@end

NS_ASSUME_NONNULL_END
