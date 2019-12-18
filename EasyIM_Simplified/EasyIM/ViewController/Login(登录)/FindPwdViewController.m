//
//  FindPwdViewController.m
//  EasyIM
//
//  Cl rights reserved.
//

#import "FindPwdViewController.h"

#import "ANCustomTextField.h"


static CGFloat const txt_height = 44;
#define ktextColor [UIColor colorWithHexString:@"#3b3b3b"]
#define K_APP_CODE_LENGTH 6
@interface FindPwdViewController ()<UITextFieldDelegate>{
    NSTimer   *timer;       //计时器
    BOOL      isAgain;      //重新获取
    NSInteger timerNo;
}

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
    
    [self initView];
}


//MARK: - initView
- (void)initView
{
    
    [self setTitle:@"找回密码"];
    self.view.backgroundColor= [UIColor whiteColor];
    
    [self.view addSubview:self.txtPhone];
    [self.view addSubview:self.txtCode];
    [self.view addSubview:self.txtPwd];
    [self.view addSubview:self.txtConfirmPwd];
    
    [self.view addSubview:self.btnSubmit];
    
    //返回
    [self showLeftBackButton];
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
    [MMRequestManager registerUserWithUserName:_txtPhone.text
                                           pwd:[YHUtils md5HexDigest:_txtPwd.text] aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
                                               if (!error) {
                                                   //记录注册信息,方便登录时直接使用
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [[NSUserDefaults standardUserDefaults] setObject:_txtPhone.text forKey:K_APP_LOGIN_USER];
                                                       [[NSUserDefaults standardUserDefaults] setObject:_txtPwd.text forKey:K_APP_LOGIN_PWD];
                                                       [[NSUserDefaults standardUserDefaults] synchronize];
                                                   });
                                                   
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [MMProgressHUD showHUD: dic[@"desc"]];
                                                   });
                                                   
                                                   if (weakSelf.findPwdFinish) {
                                                       weakSelf.findPwdFinish(_txtPhone.text, _txtPwd.text);
                                                   }
                                                   
                                                   [weakSelf performSelector:@selector(delayAction) withObject:nil afterDelay:1.0f];
                                               }else{
                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                       [MMProgressHUD showHUD: MMDescriptionForError(error)];
                                                   });
                                               }
                                           }];
}

- (void)delayAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//MARK: - 发送验证码
-(IBAction)btnSendCodeAction:(UIButton *)sender{
    
    [MMProgressHUD showHUD:@"暂无发送接口"];
    return;
    
    NSString *strPhoneCode = self.txtPhone.text;
    if (!strPhoneCode.checkPhoneNo) {
        [MMProgressHUD showHUD:@"请输入手机号"];
        return;
    }
    
    //发送验证码
    NSString *strUrl = [NSString stringWithFormat:@"http://154.8.172.16:5001/API/SendSMSCode"];
    NSDictionary *dicParams = @{ @"Phone":strPhoneCode};
    
    WEAKSELF
    [MMProgressHUD showHUD];
    [[MMApiClient sharedClient] GET:strUrl
                         parameters:dicParams
                            success:^(id  _Nonnull responseObject) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MMProgressHUD hideHUD];
                                });
                                
                                if (responseObject && [responseObject[@"resultCode"] integerValue] >= 0) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MMProgressHUD showHUD:@"验证码发送成功"];
                                        
                                        //获取成功，开启倒计时
                                        [weakSelf startCountDown];
                                    });
                                }
                                else{
                                    NSLog(@"注册发送验证码失败！详见：%@",responseObject);
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [MMProgressHUD showHUD:responseObject[@"errorMessage"]];
                                    });
                                }
                            }
                            failure:^(NSError * _Nonnull error) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [MMProgressHUD hideHUD];
                                    
                                    NSLog(@"注册验证码发送异常，详见！%@",error);
                                    [MMProgressHUD showHUD:error.localizedDescription];
                                });
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
        
        //显示清除按钮
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
        
        //显示清除按钮
        _txtPwd.clearButtonMode = UITextFieldViewModeWhileEditing;
        _txtPwd.leftPadding = 0;
        
        //密码框
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


//MARK: - UITextFieldDelegte
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
@end
