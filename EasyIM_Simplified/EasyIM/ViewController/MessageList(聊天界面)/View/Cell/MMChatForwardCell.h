//
//  MMChatForwardCell.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBaseMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MMGroup;

@interface MMChatForwardCell : MMBaseMessageCell

@property (nonatomic, strong) MMGroup *group;

+ (instancetype)cellWithTableView:(UITableView *)tableView;


@end

NS_ASSUME_NONNULL_END
