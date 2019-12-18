//
//  AddFriViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/8/27.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "AddFriViewController.h"

#import "SendMsgViewController.h"
#import "ZWFriendViewModel.h"
@interface AddFriViewController ()

@property (strong, nonatomic)  UIImageView *imageV;
@property (strong, nonatomic)  UILabel *nickLable;
@property (strong, nonatomic)  UILabel *desLable;
@property (strong, nonatomic)  UILabel *fromLable;
@property (strong, nonatomic)  UIButton *addBtn;
@property (strong, nonatomic)  ZWFriendViewModel *ViewModel;
@end

@implementation AddFriViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_bindViewModel{
    [[self.ViewModel.GetUserInfoCommand execute:self.userID] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            self.model = x[@"res"];
            [self.imageV sd_setImageWithURL:[NSURL URLWithString:self.model.photoUrl] placeholderImage:[UIImage imageNamed:@"setting_default_icon"]];
            self.nickLable.text = self.model.nickname?self.model.nickname:self.model.username;
            self.desLable.text = [NSString stringWithFormat:@"账号:%@",self.model.userid];
            if ([self.model.is_fr intValue] == 1) {
                [self.addBtn setTitle:@"对方已经是你的好友" forState:UIControlStateNormal];
                self.addBtn.enabled = NO;
            }
        }
    }];
}
-(void)zw_addSubviews{
    [self setTitle:@"添加好友"];
    [self showLeftBackButton];
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, ZWStatusAndNavHeight + 15, KScreenWidth, 70)];
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    [topView addSubview:self.imageV];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(topView.mas_centerY);
        make.left.mas_equalTo(topView.mas_left).with.mas_offset(10);
        make.size.mas_equalTo(CGSizeMake(46, 46));
    }];
    [topView addSubview:self.nickLable];
    [self.nickLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_top).with.mas_offset(17);
        make.left.mas_equalTo(self.imageV.mas_right).with.mas_offset(10);
        make.height.mas_equalTo(13);
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
    botomLB.text = @"来自";
    botomLB.font = [UIFont zwwNormalFont:13];
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
        make.right.mas_equalTo(bottomView.mas_right).with.mas_offset(-17);
        make.height.mas_equalTo(15);
    }];
    self.fromLable.text = self.FromType;
    self.addBtn.frame = CGRectMake(10, CGRectGetMaxY(bottomView.frame) + 38, KScreenWidth - 20, 40);
    [self.view addSubview:self.addBtn];
    [self.addBtn setLayerBorderWidth:0 borderColor:nil cornerRadius:5];
    
    [[self.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
         SendMsgViewController *vc = [[SendMsgViewController alloc]init];
           vc.model = _model;
           [self.navigationController pushViewController:vc animated:YES];
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
-(UILabel *)fromLable{
    if (_fromLable == nil) {
        _fromLable = [[UILabel alloc] init];
        _fromLable.textColor = [UIColor colorWithHexString:@"#999999"];
        _fromLable.font = [UIFont zwwNormalFont:12];
        _fromLable.textAlignment = NSTextAlignmentRight;
    }
    return _fromLable;
}
-(UIButton *)addBtn{
    if (_addBtn == nil) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_addBtn setTitle:@"添加" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setBackgroundColor:[UIColor colorWithHexString:@"#21B4FD"]];
        _addBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    }
    return _addBtn;
}
-(ZWFriendViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWFriendViewModel alloc]init];
    }
    return _ViewModel;
}
@end
