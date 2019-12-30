//
//  NewGroupViewCell.h
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/28.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserFriendModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NewGroupViewCellDelegate<NSObject>

- (void)selectCellWithSelectText:(NSString *)selectText isSelect:(BOOL)isSelect indexPath:(NSIndexPath *)indexPath;

//- (void)selectCellWithModel:(UserFriendModel *)model isSelect:(BOOL)isSelect;

@end

@interface NewGroupViewCell : UITableViewCell

@property (strong, nonatomic)  UIImageView *logoImage;
@property (strong, nonatomic)  UIButton *selBtn;
@property (strong, nonatomic)  UILabel *name;
@property (strong, nonatomic)  UILabel *desLable;
@property (strong, nonatomic)  UIImageView *selImage;

@property (nonatomic,weak) id<NewGroupViewCellDelegate> delegate;

@property (nonatomic, strong) UserFriendModel *model;
@property (nonatomic, strong) NSIndexPath *indexPath;

@end

NS_ASSUME_NONNULL_END
