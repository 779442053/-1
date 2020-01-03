//
//  FindPwdViewController.m
//  EasyIM
//
//  Cl rights reserved.
//

#import "FindPwdViewController.h"
#import "ANCustomTextField.h"
#import "ZWRegistViewModel.h"
static CGFloat const txt_height = 44;
#define ktextColor [UIColor colorWithHexString:@"#3b3b3b"]
#define K_APP_CODE_LENGTH 6
@interface FindPwdViewController ()<UITextFieldDelegate>{
    NSTimer   *timer;       //计时器
    BOOL      isAgain;      //重新获取
    NSInteger timerNo;
}
@property(nonatomic,strong)ZWRegistViewModel *ViewModel;
@property (nonatomic,strong) ANCustomTextField *txtPhone;
@property (nonatomic,strong) ANCustomTextField *txtCode;
@property (nonatomic,strong) UIButton          *btnSendCode;
@property (nonatomic,strong) ANCustomTextField *txtPwd;
@property (nonatomic,strong) ANCustomTextField *txtConfirmPwd;
@property (nonatomic, strong) UIButton *btnSubmit;
@end

@implementation FindPwdViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)zw_addSubviews{
    [self setTitle:@"找回密码"];
    [self showLeftBackButton];
    self.view.backgroundColor= [UIColor whiteColor];
    [self.view addSubview:self.txtPhone];
    [self.view addSubview:self.txtCode];
    [self.view addSubview:self.txtPwd];
    [self.view addSubview:self.txtConfirmPwd];
    [self.view addSubview:self.btnSubmit];
}
//MARK: - 找回密码
- (void)btnSubmitAction:(UIButton *_Nullable)sender
{
    [MMProgressHUD showHUD:@"暂无接口"];
    return;
    
    NSString *msg;
    if (!_txtPhone.text.checkTextEmpty) {
        msg = @"请输入手机号";
        [MMProgressHUD showHUD:msg];
        return;
    }
    else if(!_txtPhone.text.checkPhoneNo){
        [MMProgressHUD showHUD:@"手机号格式有误"];
        return;
    }
    
    if (!_txtCode.text.checkTextEmpty) {
        msg = @"请输入短信验证码";
        [MMProgressHUD showHUD:msg];
        return;
    }
    
    if (!_txtPwd.text.checkTextEmpty) {
        msg = @"请输入密码";
        [MMProgressHUD showHUD:msg];
        return;
    }else if (!_txtConfirmPwd.text.checkTextEmpty) {
        msg = @"请输入确认密码";
        [MMProgressHUD showHUD:msg];
        return;
    }else if (![_txtPwd.text isEqualToString:_txtConfirmPwd.text]) {
        msg = @"两次输入的密码不一致请重新输入";
        [MMProgressHUD showHUD:msg];
        return;
    }
    //登录传入的是密文，此处应该也传密文
    WEAKSELF
    [[self.ViewModel.RegistCommand execute:@{@"userpsw":[YHUtils md5HexDigest:_txtPwd.text],@"mobile":_txtPhone.text}] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [ZWSaveTool setObject:_txtPhone.text forKey:K_APP_LOGIN_USER];
                [ZWSaveTool setObject:_txtPwd.text forKey:K_APP_LOGIN_PWD];
            });
            if (weakSelf.findPwdFinish) {
                weakSelf.findPwdFinish(_txtPhone.text, _txtPwd.text);
            }
            [weakSelf performSelector:@selector(delayAction) withObject:nil afterDelay:1.0f];
        }else{
            ZWWLog(@"=======")
            [MMProgressHUD showError:@"该手机号已经注册"];
        }
    }];
    
}
- (void)delayAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//MARK: - 发送验证码
-(void)btnSendCodeAction:(UIButton *)sender{
    [MMProgressHUD showHUD:@"暂无发送接口"];
    return;
    NSString *strPhoneCode = self.txtPhone.text;
    if (!strPhoneCode.checkPhoneNo) {
        [MMProgressHUD showHUD:@"请输入手机号"];
        return;
    }
    //发送验证码
     NSDictionary *dicParams = @{ @"Phone":strPhoneCode};
       [[self.ViewModel.CodeCommand execute:dicParams] subscribeNext:^(id  _Nullable x) {
           if ([x[@"code"] intValue] == 0) {
               
           }
       }];
}
//MARK: - 倒计时
/** 开始倒计时 */
-(void)startCountDown{
    //停止计时
    [self stopCountDown];
    //关闭键盘
    [self.view endEditing:YES];
    //按钮禁用
    [self.txtPhone setEnabled:NO];
    [self.btnSendCode setEnabled:NO];
    //开启计时
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateUIInfo) userInfo:nil repeats:YES];
    [timer fire];
}
/** 停止计时 */
-(void)stopCountDown{
    //停止
    if (timer != nil) {
        [timer invalidate];
        timer = nil;
    }
    timerNo = 0;
    //按钮启用
    [self.txtPhone setEnabled:YES];
    [self.btnSendCode setEnabled:YES];
    [self.btnSendCode setTitle: isAgain?@"重新获取验证码":@"获取验证码" forState:UIControlStateNormal];
    
}

//更新UI
-(IBAction)updateUIInfo{
    timerNo = timerNo + 1;
    if (timerNo < 60) {
        NSString *strInfo = [NSString stringWithFormat:@"%ld秒",(60 - (long)timerNo)];
        [self.btnSendCode setTitle:strInfo forState:UIControlStateNormal];
    }
    else{
        //停止计时
        isAgain = YES;
        [self stopCountDown];
    }
}
//MARK: - lazy load
- (ANCustomTextField *)txtPhone{
    if (!_txtPhone) {
        CGFloat y = 18 + ZWStatusAndNavHeight;
        CGFloat w = G_SCREEN_WIDTH - 2 * G_GET_SCALE_LENTH(25);
        _txtPhone = [[ANCustomTextField alloc] initWithFrame:CGRectMake(G_GET_SCALE_LENTH(25), y, w, txt_height)];
        _txtPhone.textColor = ktextColor;
        _txtPhone.font = [UIFont systemFontOfSize:14];
        _txtPhone.backgroundColor = [UIColor whiteColor];
        _txtPhone.keyboardType = UIKeyboardTypePhonePad;
        _txtPhone.returnKeyType = UIReturnKeyNext;
        _txtPhone.delegate = self;
        _txtPhone.placeholder = @"手机号码";
        _txtPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtPhone.leftPadding = 0;
        _txtPhone.hasBorder = NO;
        _txtPhone.hasBottomBorder = YES;
        _txtPhone.borderStyle = UITextBorderStyleNone;
        _txtPhone.bottomLine.backgroundColor = G_EEF0F3_COLOR;
        _txtPhone.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _txtPhone;
}
- (ANCustomTextField *)txtCode{
    if (!_txtCode) {
        CGFloat y = _txtPhone.height + _txtPhone.y;
        _txtCode = [[ANCustomTextField alloc] initWithFrame:CGRectMake(G_GET_SCALE_LENTH(25), y, _txtPhone.width, txt_height)];
        _txtCode.textColor = ktextColor;
        _txtCode.font = [UIFont systemFontOfSize:14];
        _txtCode.backgroundColor = [UIColor whiteColor];
        _txtCode.keyboardType = UIKeyboardTypeNumberPad;
        _txtCode.returnKeyType = UIReturnKeyNext;
        _txtCode.delegate = self;
        _txtCode.placeholder = @"短信验证码";
        //显示清除按钮
        _txtCode.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtCode.leftPadding = 0;
        _txtCode.rightView = self.btnSendCode;
        _txtCode.rightViewMode = UITextFieldViewModeAlways;
        _txtCode.hasBorder = NO;
        _txtCode.hasBottomBorder = YES;
        _txtCode.borderStyle = UITextBorderStyleNone;
        _txtCode.bottomLine.backgroundColor = G_EEF0F3_COLOR;
        _txtCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _txtCode;
}
-(UIButton *)btnSendCode{
    if (!_btnSendCode) {
        _btnSendCode = [BaseUIView createBtn:CGRectMake(0, 0, 120, txt_height)
                                    AndTitle:@"获取验证码"
                               AndTitleColor:[UIColor colorWithHexString:@"#01A1EF"]
                                  AndTxtFont:FONT(13)
                                    AndImage:nil
                          AndbackgroundColor:nil
                              AndBorderColor:nil
                             AndCornerRadius:0
                                WithIsRadius:YES
                         WithBackgroundImage:nil
                             WithBorderWidth:0];
        //竖线
        CGFloat y = 5;
        CGFloat h = txt_height - 2 * y;
        UILabel *line = [BaseUIView createLable:CGRectMake(0, y, 0.5, h)
                                        AndText:nil
                                   AndTextColor:nil
                                     AndTxtFont:nil
                             AndBackgroundColor:G_EEF0F3_COLOR];
        [_btnSendCode addSubview:line];
        _btnSendCode.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_btnSendCode addTarget:self
                         action:@selector(btnSendCodeAction:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSendCode;
}
- (ANCustomTextField *)txtPwd{
    if (!_txtPwd) {
        CGFloat y = _txtCode.height + _txtCode.y;
        _txtPwd = [[ANCustomTextField alloc] initWithFrame:CGRectMake(G_GET_SCALE_LENTH(25), y, _txtCode.width, txt_height)];
        _txtPwd.textColor = ktextColor;
        _txtPwd.font = [UIFont systemFontOfSize:14];
        _txtPwd.backgroundColor = [UIColor whiteColor];
        _txtPwd.keyboardType = UIKeyboardTypeDefault;
        _txtPwd.returnKeyType = UIReturnKeyNext;
        _txtPwd.delegate = self;
        _txtPwd.placeholder = @"密码";
        _txtPwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtPwd.leftPadding = 0;
        _txtPwd.secureTextEntry = YES;
        _txtPwd.hasBorder = NO;
        _txtPwd.hasBottomBorder = YES;
        _txtPwd.borderStyle = UITextBorderStyleNone;
        _txtPwd.bottomLine.backgroundColor = G_EEF0F3_COLOR;
    }
    return _txtPwd;
}
- (ANCustomTextField *)txtConfirmPwd{
    if (!_txtConfirmPwd) {
        CGFloat y = _txtPwd.height + _txtPwd.y;
        _txtConfirmPwd = [[ANCustomTextField alloc] initWithFrame:CGRectMake(G_GET_SCALE_LENTH(25), y, _txtCode.width, txt_height)];
        _txtConfirmPwd.textColor = ktextColor;
        _txtConfirmPwd.font = [UIFont systemFontOfSize:14];
        _txtConfirmPwd.backgroundColor = [UIColor whiteColor];
        _txtConfirmPwd.keyboardType = UIKeyboardTypeDefault;
        _txtConfirmPwd.returnKeyType = UIReturnKeyJoin;
        _txtConfirmPwd.delegate = self;
        _txtConfirmPwd.placeholder = @"请再次输入密码";
        //显示清除按钮
        _txtConfirmPwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtConfirmPwd.leftPadding = 0;
        //密码框
        _txtConfirmPwd.secureTextEntry = YES;
        _txtConfirmPwd.hasBorder = NO;
        _txtConfirmPwd.hasBottomBorder = YES;
        _txtConfirmPwd.borderStyle = UITextBorderStyleNone;
        _txtConfirmPwd.bottomLine.backgroundColor = G_EEF0F3_COLOR;
    }
    return _txtConfirmPwd;
}

- (UIButton *)btnSubmit{
    if (!_btnSubmit) {
        CGFloat y = _txtConfirmPwd.height + _txtConfirmPwd.y + 37;
        _btnSubmit = [BaseUIView createBtn:CGRectMake(0, y, G_GET_SCALE_LENTH(320), G_GET_SCALE_HEIGHT(45))
                                    AndTitle:@"提交"
                               AndTitleColor:[UIColor whiteColor]
                                  AndTxtFont:FONT(13)
                                    AndImage:nil
                          AndbackgroundColor:[UIColor colorWithHexString:@"#01A1EF"]
                              AndBorderColor:nil
                             AndCornerRadius:7
                                WithIsRadius:YES
                         WithBackgroundImage:nil
                             WithBorderWidth:0];
        _btnSubmit.centerX = G_SCREEN_WIDTH/2;
        _btnSubmit.showsTouchWhenHighlighted = YES;
        [_btnSubmit addTarget:self
                         action:@selector(btnSubmitAction:)
               forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSubmit;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //禁止用户切换键盘为Emoji表情
    if ([textField.textInputMode.primaryLanguage isEqual:@"emoji"] || textField.textInputMode.primaryLanguage == nil) {
        return NO;
    }
    NSUInteger length = textField.text.length;
    NSUInteger strLength = string.length;
    //MARK:手机号长度限制
    if(strLength != 0 && textField == self.txtPhone && length >= 11){
        return NO;
    }
    //MARK:验证码长度
    else if(strLength != 0 && textField == self.txtCode && length >= 6){
        return NO;
    }
    //MARK:密码长度
    else if(strLength != 0 && (textField == self.txtPwd || textField == self.txtConfirmPwd) && length >= 15){
        return NO;
    }
    //回车注册
    if ([string isEqualToString:@"\n"]) {
        [self btnSubmitAction:nil];
    }
    return YES;
}
-(ZWRegistViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWRegistViewModel alloc]init];
    }
    return _ViewModel;
}
@end

