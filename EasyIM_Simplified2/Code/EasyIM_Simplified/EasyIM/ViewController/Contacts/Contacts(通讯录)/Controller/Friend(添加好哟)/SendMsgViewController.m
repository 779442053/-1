//
//  SendMsgViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/8/27.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "SendMsgViewController.h"
#import "FriDetailViewController.h"
#import "ZWFriendViewModel.h"

#define MAX_LIMIT_NUMS 100

@interface SendMsgViewController ()<UITextViewDelegate>
@property (strong, nonatomic) CMInputView *contentF;
@property (strong, nonatomic) UILabel *wordsLable;
@property(nonatomic,strong)ZWFriendViewModel *ViewModel;
@end

@implementation SendMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"添加好友"];
    [self showLeftBackButton];
    UIButton *rightSearch = [[UIButton alloc] initWithFrame:CGRectMake(KScreenWidth - 44 - 10, ZWStatusBarHeight, 44, 44)];
    [rightSearch setTitle:@"发送" forState:UIControlStateNormal];
    [rightSearch setTitleColor:[UIColor colorWithHexString:@"#01A1EF"] forState:UIControlStateNormal];
    rightSearch.titleLabel.font = [UIFont zwwNormalFont:13];;
    [self.navigationBgView addSubview:rightSearch];
    
    UILabel *titlb = [[UILabel alloc]initWithFrame:CGRectMake(12, 15 + ZWStatusAndNavHeight, KScreenWidth - 50, 11)];
    titlb.text = @"你需要发送你的验证信息，等待对方通过";
    titlb.font = [UIFont zwwNormalFont:11];
    [self.view addSubview:titlb];
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, ZWStatusAndNavHeight + 40, KScreenWidth, 140)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    [topView addSubview:self.contentF];

    [self.view addSubview:self.wordsLable];
    [self.wordsLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.view.mas_right).with.mas_offset(-12);
        make.top.mas_equalTo(topView.mas_bottom).with.mas_offset(12);
        make.height.mas_equalTo(15);
    }];
    self.contentF.text = [NSString stringWithFormat:@"我是 %@",[ZWUserModel currentUser].nickName];
    self.wordsLable.text = [NSString stringWithFormat:@"%ld/%d",self.contentF.text.length,MAX_LIMIT_NUMS];
    [[rightSearch rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        if (self.contentF.text == nil || self.contentF.text.length <= 0) {
            [MBProgressHUD showError:@"请填写请求信息"];
            return;
        }
        NSString *myName = self.contentF.text;
        [self addFriendrequest:self.model.userid
                           msg:myName];
    }];
}
#pragma mark - 添加好友网络请求
- (void)addFriendrequest:(NSString *)tagUserid msg:(NSString *)msg
{
    if ([tagUserid isEqualToString:[ZWUserModel currentUser].userId]) {
        [MMProgressHUD showHUD:@"不能添加自己为好友"];
        return;
    }
    [[self.ViewModel.addFriendMsgCommand execute:@{@"tid":tagUserid,@"msg":msg}] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [MMProgressHUD showHUD: @"请求成功"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

#pragma mark -限制输入字数(最多不超过100个字)
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //不支持系统表情的输入
    if ([[textView   textInputMode]   primaryLanguage]==nil||[[[textView   textInputMode]   primaryLanguage]isEqualToString:@"emoji"]) {
        [MBProgressHUD showError:@"不能输入表情等特殊字符！"];
        return NO;
    }
    UITextRange *selectedRange = [textView   markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView  positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView   offsetFromPosition:textView.beginningOfDocument   toPosition:selectedRange.start];
        NSInteger endOffset = [textView   offsetFromPosition:textView.beginningOfDocument   toPosition:selectedRange.end];
        NSRange offsetRange =NSMakeRange(startOffset, endOffset - startOffset);
        if (offsetRange.location <MAX_LIMIT_NUMS) {
            return   YES;
        }else{
            return   NO;
        }
    }
    NSString *comcatstr = [textView.text   stringByReplacingCharactersInRange:range   withString:text];
    NSInteger caninputlen =MAX_LIMIT_NUMS - comcatstr.length;
    if (caninputlen >=0){
        return   YES;
    }else{
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        if (rg.length >0){
            NSString *s =@"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text   canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text   substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }else{
                __block   NSInteger idx =0;
                __block   NSString *trimString =@"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text   enumerateSubstringsInRange:NSMakeRange(0, [text   length])
                                           options:NSStringEnumerationByComposedCharacterSequences
                                        usingBlock: ^(NSString* substring,NSRange substringRange,NSRange enclosingRange,BOOL* stop) {
                                            if (idx >= rg.length) {
                                                *stop =YES;//取出所需要就break，提高效率
                                                return ;
                                            }
                                            trimString = [trimString   stringByAppendingString:substring];
                                            idx++;
                                        }];
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView  setText:[textView.text   stringByReplacingCharactersInRange:range withString:s]];
            //既然是超出部分截取了，哪一定是最大限制了。
            self.wordsLable.text = [NSString   stringWithFormat:@"%d/%ld",0,(long)MAX_LIMIT_NUMS];
        }
        return NO;
    }
}


#pragma mark -显示当前可输入字数/总字数
- (void)textViewDidChange:(UITextView *)textView{
    UITextRange *selectedRange = [textView   markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView  positionFromPosition:selectedRange.start offset:0];
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    NSString *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    if (existTextNum >= MAX_LIMIT_NUMS){
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent  substringToIndex:MAX_LIMIT_NUMS];
        [textView setText:s];
        [MBProgressHUD showError:@"已超出最高字数上限"];
    }
    //不让显示负数
    self.wordsLable.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,existTextNum),MAX_LIMIT_NUMS];
}
-(ZWFriendViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWFriendViewModel alloc]init];
    }
    return _ViewModel;
}
-(CMInputView *)contentF{
    if (_contentF == nil) {
        _contentF = [[CMInputView alloc]initWithFrame:CGRectMake(11, 15, KScreenWidth - 22, 140 - 30)];
        _contentF.backgroundColor = [UIColor whiteColor];
        _contentF.placeholderFont = [UIFont zwwNormalFont:13];
    }
    return _contentF;
}
-(UILabel *)wordsLable{
    if (_wordsLable == nil) {
        _wordsLable = [[UILabel alloc]init];
        _wordsLable.font = [UIFont zwwNormalFont:11];
        _wordsLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _wordsLable.textAlignment = NSTextAlignmentRight;
    }
    return _wordsLable;
}
@end
