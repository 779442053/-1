//
//  EditFriendRemarkController.m
//  EasyIM
//
//  Created by apple on 2019/7/3.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "EditFriendRemarkController.h"
#import "BaseUIView.h"
#import "ZWFriendViewModel.h"
static CGFloat const cell_height = 40;
static NSInteger const name_length = 30;

@interface EditFriendRemarkController ()<UITextFieldDelegate>

@property(nonatomic, strong) UIView *contentView;
@property(nonatomic, strong) UILabel *labTitle;
@property(nonatomic, strong) UITextField *txtField;
@property(nonatomic, strong) ZWFriendViewModel *ViewModel;
@end

@implementation EditFriendRemarkController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"编辑备注"];
    [self showLeftBackButton];
    [self.view addSubview:self.contentView];
}
//MARK: - 完成
-(void)rightAction{
    NSString *strRemark = self.txtField.text;
    if (!strRemark.checkTextEmpty) {
        [MBProgressHUD showError:@"请输入备注"];
        return;
    }
    if (!self.strRemarkId.checkTextEmpty) {
        [MBProgressHUD showError:@"好友编号不存在"];
        return;
    }
    [[self.ViewModel.setmemoFriendCommand execute:@{@"muserid":self.strRemarkId,@"musername":strRemark,@"musernotice":@"1"}] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}
//MARK: - lazy load
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [BaseUIView createView:CGRectMake(0, 20, SCREEN_WIDTH, cell_height)
                           AndBackgroundColor:[UIColor whiteColor]
                                  AndisRadius:NO
                                    AndRadiuc:0
                               AndBorderWidth:0
                               AndBorderColor:nil];
        
        [_contentView addSubview:self.labTitle];
        [_contentView addSubview:self.txtField];
    }
    return _contentView;
}

-(UILabel *)labTitle{
    if (!_labTitle) {
        _labTitle = [BaseUIView createLable:CGRectMake(20, 0, 50, cell_height)
                                    AndText:@"备注名"
                               AndTextColor:[UIColor blackColor]
                                 AndTxtFont:FONT(12)
                         AndBackgroundColor:nil];
    }
    return _labTitle;
}

-(UITextField *)txtField{
    if (!_txtField) {
        CGFloat x = _labTitle.frame.origin.x + _labTitle.frame.size.width;
        CGFloat w = SCREEN_WIDTH - x - 20;
        _txtField = [BaseUIView createTextField:CGRectMake(x, 0, w, cell_height)
                                        AndText:nil
                                   AndTextColor:[UIColor blackColor]
                                     AndTxtFont:FONT(12)
                                  AndPlacehodle:@"请输入备注名"
                             AndPlacehodleColor:[UIColor darkGrayColor]
                             AndBackgroundColor:nil];
        _txtField.delegate = self;
        _txtField.textAlignment = NSTextAlignmentRight;
        _txtField.returnKeyType = UIReturnKeySend;
    }
    return _txtField;
}


//MARK: - UITextFieldDelegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    // [S] 禁止用户切换键盘为Emoji表情
    if (textField.isFirstResponder) {
        if ([textField.textInputMode.primaryLanguage isEqual:@"emoji"] || textField.textInputMode.primaryLanguage == nil) {
            return NO;
        }
    }
    // [E] 禁止用户切换键盘为Emoji表情
    
    NSUInteger length = textField.text.length;
    NSUInteger strLength = string.length;
    
    //MARK:名称长度限制
    if(strLength != 0 && textField == self.txtField && length >= name_length){
        return NO;
    }
    
    //回车提交
    if ([string isEqualToString:@"\n"]) {
        [self rightAction];
    }
    return YES;
}
-(ZWFriendViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWFriendViewModel alloc]init];
    }
    return _ViewModel;
}
@end
