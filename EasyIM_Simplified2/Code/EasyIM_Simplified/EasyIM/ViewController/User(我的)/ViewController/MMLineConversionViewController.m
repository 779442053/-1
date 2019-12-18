//
//  MMLineConversionViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMLineConversionViewController.h"

@interface MMLineConversionViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountField;//金额输入框

@end

@implementation MMLineConversionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setupUI];
}

#pragma mark - Private

- (void)setupUI
{
    [self setTitle:@"转换额度"];
    [self showLeftBackButton];
}

#pragma mark - Action

- (IBAction)rolloutAction:(UIButton *)sender
{
    //MARK: 转出
}

- (IBAction)rollinAction:(UIButton *)sender
{
    //MARK: 转入
}

- (IBAction)commitAction:(UIButton *)sender
{
    //MARK: 确认提交
    [self.view endEditing:YES];
    
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

@end
