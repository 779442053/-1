//
//  FriDetailViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/8/27.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "FriDetailViewController.h"
#import "EditFriendRemarkController.h"


@interface FriDetailViewController ()
@property (strong, nonatomic)  UIImageView *imageV;
@property (strong, nonatomic)  UIImageView *RightImageView;
@property (strong, nonatomic)  UIImageView *sexImage;
@property (strong, nonatomic)  UILabel *nickLable;
@property (strong, nonatomic)  UILabel *desLable;
@property (strong, nonatomic)  UIButton *sendBtn;
@end

@implementation FriDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"详细资料"];
    [self showLeftBackButton];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, ZWStatusAndNavHeight + 15, KScreenWidth, 90)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    [topView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(topView.mas_centerY);
        make.left.mas_equalTo(topView.mas_left).with.mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    [topView addSubview:self.nickLable];
    [self.nickLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top).with.mas_offset(22);
        make.left.mas_equalTo(self.imageV.mas_right).with.mas_offset(10);
        make.height.mas_equalTo(13);
    }];
    self.nickLable.text = _Nmodel.fromNick.length ? _Nmodel.fromNick: _Nmodel.fromName;
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
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 12, KScreenWidth, 40)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UILabel *botomLB = [[UILabel alloc]init];
    botomLB.text = @"设置备注";
    botomLB.font = [UIFont zwwNormalFont:13];
    botomLB.userInteractionEnabled = YES;
    botomLB.textColor = [UIColor colorWithHexString:@"#333333"];
    [bottomView addSubview:botomLB];
    [botomLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.left.mas_equalTo(bottomView.mas_left).with.mas_offset(17);
        make.height.mas_equalTo(15);
    }];
    
    [bottomView addSubview:self.RightImageView];
    [self.RightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.right.mas_equalTo(bottomView.mas_right).with.mas_offset(-11);
        make.size.mas_equalTo(CGSizeMake(11, 11));
    }];
    self.sendBtn.frame = CGRectMake(10, CGRectGetMaxY(bottomView.frame) + 38, KScreenWidth - 20, 40);
    [self.view addSubview:self.sendBtn];
    [self.sendBtn addTarget:self action:@selector(sendMsgEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendBtn setLayerBorderWidth:0 borderColor:nil cornerRadius:5];
    
    [self.imageV sd_setImageWithURL:[NSURL URLWithString:_Nmodel.fromPhoto] placeholderImage:[UIImage imageNamed:@"setting_default_icon"]];
    [self.imageV wyh_autoSetImageCornerRedius:3 ConrnerType:UIRectCornerAllCorners];
    self.desLable.text = [NSString stringWithFormat:@"账号:%@",_Nmodel.fromName];
    
    UITapGestureRecognizer *setNameGesture = [[UITapGestureRecognizer alloc]init];
    [bottomView addGestureRecognizer:setNameGesture];
    [[setNameGesture rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
        EditFriendRemarkController *vc = [[EditFriendRemarkController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
    }];
}


//发送信息
- (void)sendMsgEvent:(id)sender {
    ContactsModel *model = [[ContactsModel alloc] init];
    model.photoUrl = _Nmodel.fromPhoto;
    model.userId = _Nmodel.fromID;//self.userId;
    model.cmd = @"sendMsg";
    model.userName = _Nmodel.fromNick.length ? _Nmodel.fromNick: _Nmodel.fromName;
    [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
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
-(UIButton *)sendBtn{
    if (_sendBtn == nil) {
        _sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_sendBtn setTitle:@"发送信息" forState:UIControlStateNormal];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn setBackgroundColor:[UIColor colorWithHexString:@"#21B4FD"]];
        _sendBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    }
    return _sendBtn;
}
-(UIImageView *)RightImageView{
    if (_RightImageView == nil) {
        _RightImageView = [[UIImageView alloc]init];
        _RightImageView.image = [UIImage imageNamed:@"App_rightArrow"];
        _RightImageView.userInteractionEnabled = YES;
    }
    return _RightImageView;
}
-(UIImageView *)sexImage{
    if (_sexImage == nil) {
        _sexImage = [[UIImageView alloc]init];//sexManIcon sexWomen
        _sexImage.image = [UIImage imageNamed:@"sexManIcon"];
    }
    return _sexImage;
}

@end
