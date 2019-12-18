//
//  MMAddBankViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMAddBankViewController.h"

//ViewController
#import "MMNextAddBankViewController.h"

@interface MMAddBankViewController ()

@end

@implementation MMAddBankViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"添加银行卡"];
    [self showLeftBackButton];
    
}
#pragma mark - Action

- (IBAction)nextAction:(UIButton *)sender
{
    //MARK: 下一步
    
    MMNextAddBankViewController *nabView = [[MMNextAddBankViewController alloc] init];
    [self.navigationController pushViewController:nabView animated:YES];
}

@end
