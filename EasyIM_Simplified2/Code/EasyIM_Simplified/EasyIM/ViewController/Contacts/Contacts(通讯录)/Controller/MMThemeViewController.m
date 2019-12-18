//
//  MMThemeViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/24.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMThemeViewController.h"

@interface MMThemeViewController ()<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, assign) BOOL isClean;

@end

@implementation MMThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupUI];
    [self setTitle:@"修改签名"];
    [self showLeftBackButton];
    //[self addRightBtnWithImage:[UIImage imageNamed:@"setting_editPan_icon"]];
}

#pragma mark - Private

- (void)setupUI
{
    UITextView *textView = [[UITextView alloc] init];
    textView.editable = YES;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    textView.delegate = (id<UITextViewDelegate>)self;
    
    //textview 改变字体的行间距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:15],
                                 NSParagraphStyleAttributeName:paragraphStyle,
                                 NSForegroundColorAttributeName:[UIColor lightGrayColor],
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:_theme.length ? _theme : @"请输入签名" attributes:attributes];
    
    [self.view addSubview:textView];
    self.textView = textView;
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15);
        make.right.equalTo(self.view).offset(-15);
        make.top.equalTo(self.view.mas_top).offset(20);
        make.height.equalTo(@200);
    }];
    
    [textView.layer setMasksToBounds:YES];
    [textView.layer setCornerRadius:8.0f];
    
    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)delayAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


//MARK: - 签名修改
- (void)rightAction
{
    
    [self.view endEditing:YES];
    
    if (!_textView.text.length || [self.textView.text isEqualToString:@"请输入签名"]) {
        [MMProgressHUD showHUD:@"签名不能为空"];
        return;
    }

    [MMProgressHUD showHUD];
    [MMRequestManager setUserThemeWithUserId:[ZWUserModel currentUser].userId theme:_textView.text aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        [MMProgressHUD hideHUD];
        if (!error) {
            
            [MMProgressHUD showHUD:@"修改成功"];
            if (self.changeTheme) {
                self.changeTheme(_textView.text);
            }
            [self performSelector:@selector(delayAction) withObject:nil afterDelay:1.0f];
            
        }else{
            [MMProgressHUD showHUD:MMDescriptionForError(error)];
        }
    }];
}


//MARK: - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}



- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    if (!_isClean) {
        self.textView.text = @"";
    }
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    [self.view endEditing:YES];
    
    if(textView.text.length < 1){
        self.textView.text = @"请输入签名";
        self.textView.textColor = [UIColor lightGrayColor];
        _isClean = NO;
    }else{
        _isClean = YES;
    }
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    //控制文本输入内容
    if (range.location>=100){
        //控制输入文本的长度
        [MMProgressHUD showHUD:@"签名不得多于100字"];
        return  NO;
    }
    if ([text isEqualToString:@"\n"]){
        //禁止输入换行
        return NO;
    }
    return YES;
}

@end
