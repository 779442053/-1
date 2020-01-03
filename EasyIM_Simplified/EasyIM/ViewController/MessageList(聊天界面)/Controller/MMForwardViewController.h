//
//  MMForwardViewController.h
//  EasyIM
//
//  Created by momo on 2019/7/10.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMForwardCell.h"
#import "MMCommonModel.h"
@protocol MMFAnyDataDelegate <NSObject>
- (void)forwardMessageData:(NSMutableArray *)selectData;
@end
@interface MMForwardViewController : UIViewController
@property (nonatomic, strong) UIButton *leftBtn;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, weak) id<MMFAnyDataDelegate> delegate;
- (void)hintFullForward;
- (void)leftAction:(UIButton *)sender;
@end
