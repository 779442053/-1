//
//  MMForwardCell.h
//  EasyIM
//
//  Created by momo on 2019/7/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MMCommonModel;

NS_ASSUME_NONNULL_BEGIN

@interface MMForwardCell : UITableViewCell

@property (nonatomic, strong) UIImageView *identifierImage;//group_selected,group_unSelected

@property (nonatomic, assign) BOOL isEdit;

@property (nonatomic, strong) MMCommonModel *model;

@end

NS_ASSUME_NONNULL_END
