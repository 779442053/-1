//
//  MMRechargeStatusController.m
//  EasyIM
//
//  Created by momo on 2019/9/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMRechargeStatusController.h"

@interface MMRechargeStatusController ()

@end

@implementation MMRechargeStatusController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showLeftBackButton];
    [self setTitle:@"充值详情"];
}

- (IBAction)finishAction:(UIButton *)sender {
    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:([self.navigationController.viewControllers count] -3)] animated:YES];
}
@end
