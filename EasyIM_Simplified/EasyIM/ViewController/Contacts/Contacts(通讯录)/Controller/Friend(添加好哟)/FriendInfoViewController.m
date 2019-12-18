//
//  FriendInfoViewController.m
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/14.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "FriendInfoViewController.h"
#import "BaseUIView.h"
#import "EditFriendRemarkController.h"
#import "ZWFriendViewModel.h"
#import "SearchFriendModel.h"
@interface FriendInfoViewController ()
@property (nonatomic, strong) SearchFriendModel               *userInfoDic;
@property (nonatomic, strong) ZWFriendViewModel          *ViewModel;
@property (strong, nonatomic)  UIImageView *imageV;
@property (strong, nonatomic)  UIImageView *seximageV;
@property (strong, nonatomic)  UIImageView *RightimageV;
@property (strong, nonatomic)  UILabel *nickLable;
@property (strong, nonatomic)  UILabel *desLable;
@property (strong, nonatomic)  UIButton *addBtn;
@end

@implementation FriendInfoViewController

//MARK: - override
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"详细资料"];
    [self showLeftBackButton];
    [self getUserInfo];
}
-(void)zw_addSubviews{
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
    [self.nickLable sizeToFit];
    [self.view layoutSubviews];
    [topView addSubview:self.seximageV];
    [self.seximageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nickLable.mas_centerY);
        make.left.mas_equalTo(self.nickLable.mas_right).with.mas_offset(7);
        make.size.mas_equalTo(CGSizeMake(15, 15));
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
    botomLB.textColor = [UIColor colorWithHexString:@"#333333"];
    botomLB.userInteractionEnabled = YES;
    [bottomView addSubview:botomLB];
    [botomLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.left.mas_equalTo(bottomView.mas_left).with.mas_offset(17);
        make.height.mas_equalTo(15);
    }];
    
    [bottomView addSubview:self.RightimageV];
    [self.RightimageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(bottomView.mas_centerY);
        make.right.mas_equalTo(bottomView.mas_right).with.mas_offset(-17);
        make.size.mas_equalTo(CGSizeMake(7, 11));
    }];
    
    [bottomView addPanGestureRecognizer:^(UIPanGestureRecognizer * _Nonnull recognizer, NSString * _Nonnull gestureId) {
        ZWWLog(@"设置备注")
        EditFriendRemarkController *editRemarkVC = [[EditFriendRemarkController alloc] init];
        editRemarkVC.strRemarkId = self.userInfoDic.userid;
        editRemarkVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:editRemarkVC animated:YES];
    }];
    
    self.addBtn.frame = CGRectMake(10, CGRectGetMaxY(bottomView.frame) + 38, KScreenWidth - 20, 40);
    [self.view addSubview:self.addBtn];
    [self.addBtn setLayerBorderWidth:0 borderColor:nil cornerRadius:5];
    
    [[self.addBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
         if (self.userInfoDic && self.userInfoDic.userid.checkTextEmpty) {
             [self.navigationController popToRootViewControllerAnimated:YES];
             ContactsModel *model = [[ContactsModel alloc] init];
             model.photoUrl = self.userInfoDic.photoUrl;
             model.userId = self.userId;
             model.cmd = @"sendMsg";
             model.userName = self.userInfoDic.nickname.length ? self.userInfoDic.nickname : self.userInfoDic.username;
             [[NSNotificationCenter defaultCenter] postNotificationName:CHAT_PUSHVIEWCONTROLLER object:model];
         }
         else{
             [MMProgressHUD showHUD:@"用户信息不存在"];
         }
    }];
    
     UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(10,CGRectGetMaxY(self.addBtn.frame)+20, SCREEN_WIDTH - 20, 45);
    [deleteBtn setTitle:@"删除好友" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    deleteBtn.backgroundColor = [UIColor whiteColor];
    [deleteBtn addTarget:self action:@selector(deletefriend) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteBtn];
}
//MARK: - 获取用户详细信息
- (void)getUserInfo {
    [[self.ViewModel.GetUserInfoCommand execute:self.userId] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            self.userInfoDic = x[@"res"];
            self.nickLable.text = self.userInfoDic.nickname.length ? self.userInfoDic.nickname : self.userInfoDic.username;
            self.desLable.text = [NSString stringWithFormat:@"账号:%@",self.userInfoDic.userid];
            [self.imageV sd_setImageWithURL:[NSURL URLWithString:self.userInfoDic.photoUrl] placeholderImage:[UIImage imageNamed:@"setting_default_icon"]];
            if (!ZWWOBJECT_IS_EMPYT(self.userInfoDic.sex)) {
                if ([self.userInfoDic.sex intValue] == 1) {
                    self.seximageV.image = [UIImage imageNamed:@"sexManIcon"];
                }else{
                    self.seximageV.image = [UIImage imageNamed:@"sexWomen"];
                }
            }else{
                //默认女
                self.seximageV.image = [UIImage imageNamed:@"sexWomen"];
            }
        }
    }];
}

//MARK: - 删除好友
- (void)deletefriend {
    //删除好友
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"确定要删除该好友吗？" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alert animated:YES completion:nil];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self toDeletefriend];
        
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"再想想" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
}
//删除好友
- (void)toDeletefriend {
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"type"] =@"req";
    parma[@"xns"] = @"xns_user";
    parma[@"timeStamp"] = [MMDateHelper getNowTime];
    parma[@"cmd"] = @"delFriend";
    parma[@"sessionID"] = [ZWUserModel currentUser].sessionID;;
    parma[@"userId"] = [ZWUserModel currentUser].userId;
    parma[@"frdId"] = self.userInfoDic.userid;
    [ZWSocketManager SendDataWithData:parma];
}
-(ZWFriendViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWFriendViewModel alloc]init];
    }
    return _ViewModel;
}
-(UIImageView *)imageV{
    if (_imageV == nil) {
        _imageV = [[UIImageView alloc]init];
    }
    return _imageV;
}
-(UIImageView *)seximageV{
    if (_seximageV == nil) {
        _seximageV = [[UIImageView alloc]init];
    }
    return _seximageV;
}
-(UIImageView *)RightimageV{
    if (_RightimageV == nil) {
        _RightimageV = [[UIImageView alloc]init];
        _RightimageV.image = [UIImage imageNamed:@"App_rightArrow"];
        _RightimageV.userInteractionEnabled = YES;
    }
    return _RightimageV;
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

-(UIButton *)addBtn{
    if (_addBtn == nil) {
        _addBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_addBtn setTitle:@"发送信息" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_addBtn setBackgroundColor:[UIColor colorWithHexString:@"#21B4FD"]];
        _addBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    }
    return _addBtn;
}

@end
