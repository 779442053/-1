//
//  LoginVC.m
//  EasyIM
//
//  served.
//

#import "LoginVC.h"
#import "RegisterViewController.h"
#import "KinTabBarController.h"
#import "AppDelegate.h"
#import "MMSystemHelp.h"
#import "MMVedioCallManager.h"
#import "ANCustomTextField.h"
#import "FindPwdViewController.h"

#import "ZWLoginViewModel.h"
#define ktextColor [UIColor colorWithHexString:@"#3b3b3b"]
/** 适配iPhone X的底部安全区域 */
#define BottomSafeArea (iPhone5_8 ? 34.f : 0.f)
@interface LoginVC ()<UITextFieldDelegate>

@property (nonatomic,strong) ANCustomTextField *accountField;
@property (nonatomic,strong) ANCustomTextField *passField;
@property (nonatomic,strong) UIButton *loginBtn;
@property (nonatomic,strong) UIButton *resginBtn;
@property (nonatomic,strong) UIButton *btnForget;
@property(nonatomic,strong)ZWLoginViewModel *ViewModel;
@end
@implementation LoginVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    //进来进行预登陆  ,获取到 soket 地址 和hppt 地址
    [[self.ViewModel.preLoginCommand execute:nil] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            //预登陆成功
        }else{
            [YJProgressHUD showMessage:@"系统错误,请稍后再来"];
        }
    }];
}
-(void)zw_addSubviews{
    [self setTitle:@"登录"];
    [self.view addSubview:self.accountField];
    [self.view addSubview:self.passField];
    [self.view addSubview:self.loginBtn];
    [self.navigationView addSubview:self.resginBtn];
    [self.view addSubview:self.btnForget];
}
- (ANCustomTextField *)accountField{
    if (!_accountField) {
        CGFloat y = ZWStatusAndNavHeight + 18;
        CGFloat w = G_SCREEN_WIDTH - 2 * G_GET_SCALE_LENTH(25);
        _accountField = [[ANCustomTextField alloc] initWithFrame:CGRectMake(G_GET_SCALE_LENTH(25), y, w, 44)];
        _accountField.textColor = ktextColor;
        _accountField.font = [UIFont systemFontOfSize:14];
        _accountField.backgroundColor = [UIColor whiteColor];
       // _accountField.keyboardType = UIKeyboardTypePhonePad;
        _accountField.returnKeyType = UIReturnKeyNext;
        _accountField.delegate = self;
        _accountField.placeholder = @"手机号码";
        //显示清除按钮
        _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _accountField.leftPadding = 0;
        _accountField.hasBorder = NO;
        _accountField.hasBottomBorder = YES;
        _accountField.borderStyle = UITextBorderStyleNone;
        _accountField.bottomLine.backgroundColor = G_EEF0F3_COLOR;
        _accountField.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:K_APP_LOGIN_USER]?[[NSUserDefaults standardUserDefaults] objectForKey:K_APP_LOGIN_USER]:@""];
        _accountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _accountField;
}
- (ANCustomTextField *)passField{
    if (!_passField) {
        CGFloat y = _accountField.height + _accountField.y;
        _passField = [[ANCustomTextField alloc] initWithFrame:CGRectMake(G_GET_SCALE_LENTH(25), y, _accountField.width, 44)];
        _passField.textColor = ktextColor;
        _passField.font = [UIFont systemFontOfSize:14];
        _passField.backgroundColor = [UIColor whiteColor];
        _passField.keyboardType = UIKeyboardTypeDefault;
        _passField.returnKeyType = UIReturnKeyJoin;
        _passField.delegate = self;
        _passField.placeholder = @"密码";
        //显示清除按钮
        _passField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _passField.leftPadding = 0;
        //密码框
        _passField.secureTextEntry = YES;
        _passField.hasBorder = NO;
        _passField.hasBottomBorder = YES;
        _passField.borderStyle = UITextBorderStyleNone;
        _passField.bottomLine.backgroundColor = G_EEF0F3_COLOR;
        _passField.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:K_APP_LOGIN_PWD]?[[NSUserDefaults standardUserDefaults] objectForKey:K_APP_LOGIN_PWD]:@""];
    }
    return _passField;
}
- (UIButton *)loginBtn{
    if (!_loginBtn) {
        CGFloat y = _passField.height + _passField.y + 32;
        _loginBtn = [BaseUIView createBtn:CGRectMake(0, y, G_GET_SCALE_LENTH(320), G_GET_SCALE_HEIGHT(45))
                                 AndTitle:@"登录"
                            AndTitleColor:[UIColor whiteColor]
                               AndTxtFont:FONT(13)
                                 AndImage:nil
                       AndbackgroundColor:[UIColor colorWithHexString:@"#01A1EF"]
                           AndBorderColor:nil
                          AndCornerRadius:7
                             WithIsRadius:YES
                      WithBackgroundImage:nil
                          WithBorderWidth:0];
        _loginBtn.centerX = G_SCREEN_WIDTH/2;
        _loginBtn.showsTouchWhenHighlighted = YES;
        [_loginBtn addTarget:self
                      action:@selector(login:)
            forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}
- (UIButton *)resginBtn{
    if (!_resginBtn) {
        _resginBtn = [BaseUIView createBtn:CGRectMake(G_SCREEN_WIDTH - 60 -20,ISIphoneX?44: 20, 60, 44)
                                    AndTitle:@"注册"
                               AndTitleColor:[UIColor colorWithHexString:@"#01A1EF"]
                                  AndTxtFont:FONT(13)
                                    AndImage:nil
                          AndbackgroundColor:nil
                              AndBorderColor:nil
                             AndCornerRadius:0
                                WithIsRadius:NO
                         WithBackgroundImage:nil
                             WithBorderWidth:0.0];
        _resginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_resginBtn addTarget:self
                         action:@selector(resginBtnClick:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _resginBtn;
}
- (UIButton *)btnForget{
    if (!_btnForget) {
        CGFloat w = 120;
        CGFloat h = 44;
        CGFloat y = G_SCREEN_HEIGHT - h - 20 - ZWTabbarSafeBottomMargin;
        CGFloat x = (G_SCREEN_WIDTH - w) * 0.5;
        _btnForget = [BaseUIView createBtn:CGRectMake(x,y,w,h)
                                  AndTitle:@"忘记密码"
                             AndTitleColor:[UIColor colorWithHexString:@"#AAAAAA"]
                                AndTxtFont:FONT(13)
                                  AndImage:nil
                        AndbackgroundColor:nil
                            AndBorderColor:nil
                           AndCornerRadius:0
                              WithIsRadius:NO
                       WithBackgroundImage:nil
                           WithBorderWidth:0.0];
        _resginBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_btnForget addTarget:self
                       action:@selector(btnFogetAction:)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnForget;
}
//MARK: - 注册
- (void)resginBtnClick:(UIButton *)sender
{
    RegisterViewController *controller = [[RegisterViewController alloc] init];
    controller.registerFinish = ^(NSString * _Nonnull strPhone, NSString * _Nonnull strPwd) {
        self.accountField.text = strPhone;
        self.passField.text = strPwd;
        [self login:nil];
    };
     BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:controller];
    controller.modalPresentationStyle = 0;
    [self presentViewController: nav
                       animated: YES
                     completion: NULL];
}
//MARK: - 登录
- (void)login:(UIButton *_Nullable)sender
{
    NSString *errorMsg = nil;
    [self.view endEditing:YES];
    if (_accountField.text.length == 0) {
        errorMsg = @"请输入手机号";
        [MMProgressHUD showHUD:errorMsg];
        return;
    }
//    else if(![_accountField.text checkPhoneNo]){
//        [MMProgressHUD showHUD:@"手机号格式有误"];
//        return;
//    }
    if (_passField.text.length == 0) {
        errorMsg = @"请输入密码";
        [MMProgressHUD showHUD:errorMsg];
        return;
    }else if(![_passField.text checkUsername:15]) {
        errorMsg = [NSString stringWithFormat:@"请输入6-%d位长度字母或数字密码",15];
        [MMProgressHUD showHUD:errorMsg];
        return;
    }
    NSDictionary *dict = @{
       @"loginType":@"2",
       @"deviceDesc":[[MMSystemHelp deviceVersion] stringByAppendingString:@"-iOS"],
       @"username":_accountField.text,
       @"domain":@"9000",
       @"userPsw":[YHUtils md5HexDigest:_passField.text]
    };
    [[self.ViewModel.LoginCommand execute:dict] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [ZWSaveTool setObject:_accountField.text forKey:K_APP_LOGIN_USER];
            [ZWSaveTool setObject:_passField.text forKey:K_APP_LOGIN_PWD];
            [MMProgressHUD showHUD:@"登录成功" withDelay:1.0];
            [self performSelector:@selector(setMainView)withObject:self afterDelay:1.0];
        }
    }];
}

- (void)setMainView
{
    AppDelegate *appDelegate =  [AppDelegate shareAppDelegate];
    //翻转动画
    appDelegate.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [UIView transitionWithView:appDelegate.window
                      duration:0.9
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{
                        BOOL oldState = UIView.areAnimationsEnabled;
                        [UIView setAnimationsEnabled:NO];
                        
                        KinTabBarController *kinTabBarController = [[KinTabBarController alloc] initWithSelectVCIndex:0];
                        BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:kinTabBarController];
                        
                        appDelegate.window.rootViewController = nav;
                        appDelegate.tabBarController = kinTabBarController;
                        
                        [UIView setAnimationsEnabled:oldState];
                    }
                    completion:^(BOOL finished) {
                         [MMVedioCallManager sharedManager];
                    }];
}


//MARK: - 忘记密码
-(IBAction)btnFogetAction:(UIButton *)sender{
    FindPwdViewController *controller = [[FindPwdViewController alloc] init];
    controller.modalPresentationStyle = 0;
    controller.findPwdFinish = ^(NSString * _Nonnull strPhone, NSString * _Nonnull strPwd) {
        self.accountField.text = strPhone;
        self.passField.text = strPwd;
        [self login:nil];
    };
    
    BaseNavgationController *nav = [[BaseNavgationController alloc] initWithRootViewController:controller];
    nav.modalPresentationStyle = 0;
    [self presentViewController: nav
                       animated: YES
                     completion: NULL];
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
    if(strLength != 0 && textField == self.accountField && length >= 11){
        return NO;
    }
    
    //MARK:密码长度
    else if(strLength != 0 && textField == self.passField && length >= 15){
        return NO;
    }
    
    //回车登录
    if ([string isEqualToString:@"\n"]) {
        [self login:nil];
    }
    return YES;
}
-(ZWLoginViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWLoginViewModel alloc]init];
    }
    return _ViewModel;
}
@end

