//
//  MMForward_GroupViewController.h
//  EasyIM
//
//  Created by momo on 2019/7/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMForwardViewController.h"
#import "MMForwardDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMForward_GroupViewController : MMForwardViewController

@property (nonatomic, weak) id <MMForwardDelegate> forwardDelegate;

- (instancetype)initWithSelectDataArr:(NSArray *)dataArr;

@end

NS_ASSUME_NONNULL_END
