//
//  ZWSearchBar.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWSearchBar.h"
#import "UITextField+TextLeftOffset_ffset.h"
/*! leftView 的宽度  */
static NSInteger leftViewWidth = 35 ;
/*! 图片和label的间距 */
static NSInteger space = 15;
@interface ZWSearchBar()<UITextFieldDelegate>

/*! 默认文字 默认居中存在 */

/*! 方法镜图片 */
@property(nonatomic,strong)UIImageView *searchImage;
/*! 取消按钮 */
@property(nonatomic,strong)UIButton *cancelButton;
/*! 输入框 */
@property(nonatomic,strong)UITextField *textField;
/*! label文字大小 */
@property(nonatomic,assign)CGSize size;
@end;

@implementation ZWSearchBar

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.textField];
        [self baseSetting];
        [_textField addSubview:self.placeholderLabel];
        [_textField addSubview:self.searchImage];
        [self setAllFrame];
        [self addSubview:self.cancelButton];
    }
    return self;
}
/*! 基础配置 */

- (void)baseSetting{
    /*! 边框处理 */
    _textField.layer.borderColor = [UIColor colorWithHexString:@"C3C3C5"].CGColor;
    _textField.layer.borderWidth = 1;
    _textField.layer.cornerRadius = 5;
    _textField.layer.masksToBounds = YES;
    /*! 字体其他 */
    _textField.font = [UIFont zwwNormalFont:12];
    _textField.tintColor = [UIColor colorWithHexString:@"C3C3C5"];
    _textField.keyboardType = UIKeyboardTypeDefault;
    _textField.delegate =self;
    /*! 设置键盘return样式为搜索样式 */
    _textField.returnKeyType = UIReturnKeySearch;
    /*! 设置为无文字就灰色不可点 */
    _textField.enablesReturnKeyAutomatically = YES;
    /*! 开启系统清除样式 */
    _textField.clearButtonMode = UITextFieldViewModeAlways;
    /*! 添加左边遮盖 */
    [_textField setTextOffsetWithLeftViewRect:CGRectMake(0, 0, leftViewWidth, self.frame.size.height) WithMode:UITextFieldViewModeAlways];
    /*! 编辑事件观察 */
    [_textField addTarget:self action:@selector(textFieldDidEditing:) forControlEvents:UIControlEventEditingChanged];
    _textField.backgroundColor = [UIColor whiteColor];
}

#pragma mark --- 懒加载

- (UITextField *)textField{
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width-25, self.frame.size.height)];
    }
    return _textField;
}
-(void)setZWPlaceholder:(NSString *)ZWPlaceholder{
    self.placeholderLabel.text = ZWPlaceholder;
}
- (UILabel *)placeholderLabel{
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _placeholderLabel.textColor = [UIColor colorWithHexString:@"#BBBBBB"];
        _placeholderLabel.font = [UIFont zwwNormalFont:12];
        _placeholderLabel.text = @"请输入好友账号/手机号或者姓名";
    }
    return _placeholderLabel;
}

- (UIImageView *)searchImage{
    if (!_searchImage) {
        _searchImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        _searchImage.image = [UIImage imageNamed:@"addfriendSearch"];
    }
    return _searchImage;
}
- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(CGRectGetMaxX(_textField.frame)+10, 0, 40, self.frame.size.height);
        [_cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"464646"] forState:UIControlStateNormal];
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _cancelButton;
}

#pragma mark --- 设置尺寸
- (void)setAllFrame{
    _size = [_placeholderLabel.text boundingRectWithSize:CGSizeMake(600, 44) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont zwwNormalFont:12]} context:nil].size;
    [_placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_textField).offset(0);
        make.size.mas_equalTo(CGSizeMake(_size.width, _textField.frame.size.height));
        make.centerX.mas_equalTo(_textField).offset(-_textField.frame.size.width/2+leftViewWidth+_size.width/2+5);
    }];
    [_searchImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerX.mas_equalTo(_textField).offset(-_textField.frame.size.width/2-space+leftViewWidth);
        make.centerY.mas_equalTo(_textField);
    }];
}
#pragma mark --- 取消按钮点击事件
- (void)cancelAction{
    [self endEditing:YES];
    _placeholderLabel.hidden  = NO;
    _textField.text = @"";
    [_SearchDelegate cancleWithStr];
    [UIView animateWithDuration:0.25 animations:^{
        //        执行更新
        [self.textField layoutIfNeeded];
    }];
}

#pragma mark --- UITextFieldDelegate

/*! 当输入框开始编辑的时候 */
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    /*! _placeholderLabel移动到关标右边*/
//    [_placeholderLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(_textField).offset(-_textField.frame.size.width/2+leftViewWidth+_size.width/2+5);
//    }];
//    /*! _searchImage移动到关标左边 */
//    [_searchImage mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(_textField).offset(-_textField.frame.size.width/2-space+leftViewWidth);
//    }];
    [UIView animateWithDuration:0.25 animations:^{
//        执行更新
        [self layoutIfNeeded];
    }];
    
}
/*! 输入框结束编辑 */
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.text.length>0) {
        //NSLog(@"进行搜索");
        [_SearchDelegate searchWithStr:textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_textField resignFirstResponder];
    [_SearchDelegate searchWithStr:textField.text];
    //NSLog(@"点击了搜索");
    return YES;
}
#pragma mark --- textFieldDidEditing:
/*! 输入框编辑中 */
- (void)textFieldDidEditing:(UITextField *)textField{
    [self isHiddenLabel:textField];
}
- (void)isHiddenLabel:(UITextField *)textField{
    if (textField.text.length==0) {
        _placeholderLabel.hidden  = NO;
    }else{
        _placeholderLabel.hidden = YES;
    }
}
- (void)dealloc{
    NSLog(@"%@ 已经dealloc",NSStringFromClass(self.class));
}
@end
