//
//  VerificationViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/8/28.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "VerificationViewController.h"
#import "FriDetailViewController.h"
#import "ZWFriendViewModel.h"
@interface VerificationViewController ()<AddFriendAgreeDelegate2>
@property (strong, nonatomic)  UIImageView *imageV;
@property (strong, nonatomic)  UILabel *nickLable;
@property (strong, nonatomic)  UILabel *desLable;
@property (strong, nonatomic)  UILabel *fromLable;
@property (strong, nonatomic)  UILabel *verifiMsgLable;
@property (strong, nonatomic)  UIButton *verificationBtn;
@property (strong, nonatomic)  UIButton *blacklistBtn;
@property (strong, nonatomic)  UIImageView *sexImage;
@property(nonatomic,strong) ZWFriendViewModel *ViewModel;
@end

@implementation VerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"详细资料"];
    [self showLeftBackButton];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, ZWStatusAndNavHeight + 15, KScreenWidth, 135)];
       topView.backgroundColor = [UIColor whiteColor];
       [self.view addSubview:topView];
    [topView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top).with.mas_offset(20);
        make.left.mas_equalTo(topView.mas_left).with.mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [topView addSubview:self.nickLable];
    [self.nickLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top).with.mas_offset(22);
        make.left.mas_equalTo(self.imageV.mas_right).with.mas_offset(10);
        make.height.mas_equalTo(13);
    }];
    self.nickLable.text = _model.fromNick.length ? _model.fromNick: _model.fromName;
    [self.nickLable sizeToFit];
    [self.view layoutIfNeeded];//拿到fram
    [topView addSubview:self.sexImage];
    [self.sexImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top).with.mas_offset(22);
        make.left.mas_equalTo(self.nickLable.mas_right).with.mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(14, 14));
    }];
    [topView addSubview:self.desLable];
    [self.desLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nickLable.mas_bottom).with.mas_offset(8);
        make.left.mas_equalTo(self.imageV.mas_right).with.mas_offset(10);
        make.height.mas_equalTo(12);
    }];
    
    [topView addSubview:self.verifiMsgLable];
    [self.verifiMsgLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageV.mas_bottom).with.mas_offset(20);
        make.left.mas_equalTo(topView.mas_left).with.mas_offset(17);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth - 17*2, 55));
    }];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 12, KScreenWidth, 40)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UILabel *botomLB = [[UILabel alloc]init];
    botomLB.text = @"来自";
    botomLB.font = [UIFont zwwNormalFont:13];
    botomLB.userInteractionEnabled = YES;
    botomLB.textColor = [UIColor colorWithHexString:@"#333333"];
    [bottomView addSubview:botomLB];
    [botomLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.left.mas_equalTo(bottomView.mas_left).with.mas_offset(17);
        make.height.mas_equalTo(15);
    }];
    [bottomView addSubview:self.fromLable];
    [self.fromLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.right.mas_equalTo(bottomView.mas_right).with.mas_offset(-11);
        make.height.mas_equalTo(11);
    }];
    
    self.verificationBtn.frame = CGRectMake(10, CGRectGetMaxY(bottomView.frame) + 38, KScreenWidth - 20, 40);
    [self.view addSubview:self.verificationBtn];
    [self.verificationBtn addTarget:self action:@selector(verificationEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.verificationBtn setLayerBorderWidth:0 borderColor:nil cornerRadius:5];
    self.blacklistBtn.frame = CGRectMake(10, CGRectGetMaxY(self.verificationBtn.frame) + 12, KScreenWidth - 20, 40);
    [self.view addSubview:self.blacklistBtn];
    [self.blacklistBtn addTarget:self action:@selector(blacklistEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.blacklistBtn setLayerBorderWidth:0 borderColor:nil cornerRadius:5];
    self.desLable.text = [NSString stringWithFormat:@"账号:%@",_model.fromID];
    self.verifiMsgLable.text = [NSString stringWithFormat:@"我是 %@",self.nickLable.text];
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:_model.fromPhoto] placeholderImage:[UIImage imageNamed:@"setting_default_icon"]];
    [self.imageV wyh_autoSetImageCornerRedius:3 ConrnerType:UIRectCornerAllCorners];
}
// 通过验证

- (void)verificationEvent:(id)sender {
    [[self.ViewModel.acceptFriendCommand execute:_model.fromID] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            if ([self.delegate respondsToSelector:@selector(acceptRquestWithType:aComption:)]) {
                [self.delegate acceptRquestWithType:MMFAppAccept aComption:^(id  _Nullable data, NSError * _Nullable error) {
                    ZWWLog(@"接受好友请求的回调")
                }];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}
//加入黑名单
- (void)blacklistEvent:(id)sender {
    [[self.ViewModel.rejectFriendCommand execute:_model.fromID] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            if ([self.delegate respondsToSelector:@selector(rejectRequestWithType:aComption:)]) {
                [self.delegate rejectRequestWithType:MMFAppRes aComption:^(id  _Nullable data, NSError * _Nullable error) {
                    ZWWLog(@"决绝好友请求的回调")
                }];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}

-(UIImageView *)imageV{
    if (_imageV == nil) {
        _imageV = [[UIImageView alloc]init];
    }
    return _imageV;
}
-(UILabel *)nickLable{
    if (_nickLable == nil) {
        _nickLable = [[UILabel alloc] init];
        _nickLable.textColor = [UIColor ZW_colorWithHex:333333];
        _nickLable.font = [UIFont zwwNormalFont:13];
    }
    return _nickLable;
}
-(UILabel *)desLable{
    if (_desLable == nil) {
        _desLable = [[UILabel alloc] init];
        _desLable.textColor = [UIColor colorWithHexString:@"#999999"];
        _desLable.font = [UIFont zwwNormalFont:10];
    }
    return _desLable;
}
-(UILabel *)verifiMsgLable{
    if (_verifiMsgLable == nil) {
        _verifiMsgLable = [[UILabel alloc] init];
        _verifiMsgLable.textColor = [UIColor colorWithHexString:@"#555555"];
        _verifiMsgLable.font = [UIFont zwwNormalFont:12];
        _verifiMsgLable.numberOfLines = 0;
    }
    return _verifiMsgLable;
}
-(UIButton *)verificationBtn{
    if (_verificationBtn == nil) {
        _verificationBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_verificationBtn setTitle:@"通过验证" forState:UIControlStateNormal];
        [_verificationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_verificationBtn setBackgroundColor:[UIColor colorWithHexString:@"#21B4FD"]];
        _verificationBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    }
    return _verificationBtn;
}
-(UIButton *)blacklistBtn{
    if (_blacklistBtn == nil) {
        _blacklistBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_blacklistBtn setTitle:@"加入黑名单" forState:UIControlStateNormal];
        [_blacklistBtn setTitleColor:[UIColor colorWithHexString:@"#4E4E4E"] forState:UIControlStateNormal];
        [_blacklistBtn setBackgroundColor:[UIColor colorWithHexString:@"#FFFFFF"]];
        _blacklistBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    }
    return _blacklistBtn;
}
-(UILabel *)fromLable{
    if (_fromLable == nil) {
        _fromLable = [[UILabel alloc] init];
        _fromLable.textColor = [UIColor colorWithHexString:@"#999999"];
        _fromLable.font = [UIFont zwwNormalFont:12];
        _fromLable.textAlignment = NSTextAlignmentRight;
    }
    return _fromLable;
}
-(UIImageView *)sexImage{
    if (_sexImage == nil) {
        _sexImage = [[UIImageView alloc]init];//sexManIcon sexWomen
        _sexImage.image = [UIImage imageNamed:@"sexManIcon"];
    }
    return _sexImage;
}
-(ZWFriendViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWFriendViewModel alloc]init];
    }
    return _ViewModel;
}
@end
