//
//  MMNextAddBankCell.m
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMNextAddBankCell.h"

@interface MMNextAddBankCell ()<UITextFieldDelegate>

@property (nonatomic, weak) id <MMAddBankDelegate> delegate;
@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UILabel *titleLabel;//名称
@property (nonatomic, strong) UILabel *bankNameLabel;//银行
@property (nonatomic, strong) UITextField *textField;//输入框
@property (nonatomic, strong) UIButton *sendCodeBtn;//发送验证码

@end

@implementation MMNextAddBankCell


#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bankNameLabel];
    [self.contentView addSubview:self.textField];
    [self.contentView addSubview:self.sendCodeBtn];
}

- (void)layoutSubviews
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(16);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(60);
    }];
    
    [self.bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_right).offset(44);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-16);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(30);
    }];

    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bankNameLabel.mas_left);
        make.right.mas_equalTo(self.bankNameLabel.mas_right);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];

    [self.sendCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-18);
        make.size.mas_equalTo(CGSizeMake(80, 30));
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
}

#pragma mark - Getter

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@""
                                    AndTextColor:[UIColor lightGrayColor]
                                      AndTxtFont:FONT(13)
                              AndBackgroundColor:nil
                          ];
    }
    return _titleLabel;
}

- (UILabel *)bankNameLabel
{
    if (!_bankNameLabel) {
        _bankNameLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@"中国银行(5888)"
                                    AndTextColor:[UIColor blackColor]
                                      AndTxtFont:FONT(15)
                              AndBackgroundColor:nil
                          ];
    }
    return _bankNameLabel;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.placeholder = @"请输入";
        _textField.font = FONT(15);
        _textField.delegate = (id<UITextFieldDelegate>)self;
    }
    return _textField;
}

- (UIButton *)sendCodeBtn
{
    if (!_sendCodeBtn) {
        _sendCodeBtn = [BaseUIView createBtn:CGRectZero
                                  AndTitle:@"发送验证码"
                             AndTitleColor:[UIColor blackColor]
                                AndTxtFont:FONT(13)
                                  AndImage:nil
                        AndbackgroundColor:[UIColor whiteColor]
                            AndBorderColor:RGBCOLOR(6, 156, 232)
                           AndCornerRadius:3
                              WithIsRadius:YES
                       WithBackgroundImage:nil
                           WithBorderWidth:1];
        [_sendCodeBtn addTarget:self action:@selector(sendCodeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendCodeBtn;
}

#pragma mark - Private

- (void)sendCodeAction:(UIButton *)sender
{
    if (_delegate&&[_delegate respondsToSelector:@selector(sendCode)]) {
        [self.delegate sendCode];
    }
}

#pragma mark - Public

- (void)addDelegate:( id <MMAddBankDelegate>)delegate andIndexPath:(NSIndexPath *)indexPath
{
    _delegate = delegate;
    _indexPath = indexPath;
    _textField.tag = 200 + indexPath.row;
    
    
    switch (indexPath.row) {
        case 0:
        {
            _bankNameLabel.hidden = NO;
            _textField.hidden = YES;
            _sendCodeBtn.hidden = YES;
        }
            break;
        case 4:
        {
            _bankNameLabel.hidden = YES;
            _textField.hidden = NO;
            _sendCodeBtn.hidden = NO;
            
            
            [_textField mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(_sendCodeBtn.mas_left).offset(-20);
            }];
            
        }
            break;
        default:
        {
            _bankNameLabel.hidden = YES;
            _textField.hidden = NO;
            _sendCodeBtn.hidden = YES;
        }
            break;
    }
    
}

- (void)setBankInfoModel:(MMBankInfoModel *)bankInfoModel
{
    _bankInfoModel = bankInfoModel;
    self.titleLabel.text = bankInfoModel.bankTitle;
    self.bankNameLabel.text = bankInfoModel.bankName;
    self.textField.placeholder = bankInfoModel.bankPlaceholder;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 201) {
        _textField.keyboardType = UIKeyboardTypeDefault;
    }else{
        _textField.keyboardType = UIKeyboardTypeNumberPad;
    }
}

@end
