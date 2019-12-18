//
//  SearchFriendCell.h
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/19.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchFriendModel.h"

@class MMGroupModel;

NS_ASSUME_NONNULL_BEGIN

@interface SearchFriendCell : UITableViewCell

@property (nonatomic, strong) SearchFriendModel *model;
@property (nonatomic, strong) UIButton *button;

- (void)cellInitGroupData:(MMGroupModel *_Nullable)model;

@end

NS_ASSUME_NONNULL_END
