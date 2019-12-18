//
//  NewFriendCell.h
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/15.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewFriendModel.h"

NS_ASSUME_NONNULL_BEGIN

@class NewFriendCell;

@protocol AddFriendAgreeDelegate <NSObject>

@required

- (void)didAgreeWithCell:(NewFriendCell *)cell;

@end

@interface NewFriendCell : UITableViewCell

@property (nonatomic, strong)   UIButton *certainBtn;
@property (nonatomic, strong)   UIImageView *headerImgView;
@property (nonatomic, strong)   UILabel *nickNameLabel;
@property (nonatomic, strong)   UILabel *infoLabel;

@property (nonatomic, strong) NewFriendModel *model;
@property (nonatomic, weak) id<AddFriendAgreeDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
