//
//  MMGameCell.h
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMGameModel.h"

@protocol MMGameDelegate <NSObject>

@optional

- (void)enterGameWithIndexPath:(NSIndexPath *)indexPath;

@end

@interface MMGameCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *enterGameBtn;

@property (nonatomic, strong) MMGameModel *gameModel;

- (void)setDelegate:(id<MMGameDelegate>)delegate andIndexPath:(NSIndexPath *)indexPath;

@end

