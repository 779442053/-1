//
//  MMWithdrawalViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMWithdrawalViewController.h"

@interface MMWithdrawalViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *withdrawalText;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;

@end

@implementation MMWithdrawalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setTitle:@"提现"];
    [self showLeftBackButton];
}
#pragma mark - Action

- (IBAction)commitAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    
}

- (IBAction)selectBlankAction:(UIButton *)sender
{
    
}


#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

@end
