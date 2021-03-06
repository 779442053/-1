//
//  MMRechargeViewController.m
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMRechargeViewController.h"

#import "MMSelectBankMViewController.h"
#import "MMRechargeStatusController.h"

@interface MMRechargeViewController ()<UITextFieldDelegate,MMSelectBankDelegate>

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *blankInfo;
@property (weak, nonatomic) IBOutlet UITextField *rechargeText;

@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation MMRechargeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"充值"];
    [self showLeftBackButton];
}
#pragma mark - Action

- (IBAction)nextAction:(UIButton *)sender
{
    // MARK: 下一步
    [self.view endEditing:YES];
    
//    if (!self.rechargeText.text.length) {
//        return;
//    }
    
    MMRechargeStatusController *rechargeStatus = [[MMRechargeStatusController alloc] init];
    [self.navigationController pushViewController:rechargeStatus animated:YES];
}

- (IBAction)selectBankAction:(UIButton *)sender
{
    // MARK: 选择银行卡
    MMSelectBankMViewController *selectBank = [[MMSelectBankMViewController alloc] init];
    selectBank.delegate = (id <MMSelectBankDelegate>)self;
    selectBank.indexPath = _indexPath;
    selectBank.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:selectBank animated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _rechargeText = textField;
}

#pragma mark - MMSelectBankDelegate

- (void)selectBankWithTitle:(NSString *)title andIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"title:%@,indexPath:%@",title,indexPath);
    
    _indexPath = indexPath;
    
    self.blankInfo.text = title;
}
@end
