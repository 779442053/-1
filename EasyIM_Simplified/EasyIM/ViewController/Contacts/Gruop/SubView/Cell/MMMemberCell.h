//
//  MMMemberCell.h
//  EasyIM
//
//  Created by momo on 2019/5/27.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GroupMemberModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AddGroupMemberDelegate <NSObject>

@required

- (void)addGroupMemberWithGesR:(UIGestureRecognizer *)gesture;

@end


@interface MMMemberCell : UITableViewCell

/** 成员列表*/
@property (nonatomic, strong) NSMutableArray *memberList;

/**cell的高度*/
@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, weak) id<AddGroupMemberDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
