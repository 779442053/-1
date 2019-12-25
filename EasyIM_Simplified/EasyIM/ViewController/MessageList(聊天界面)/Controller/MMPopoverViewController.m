//
//  MMPopoverViewController.m
//  EasyIM
//
//  Created by momo on 2019/7/15.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMPopoverViewController.h"

#import "MMCommonModel.h"

@interface MMPopoverViewController ()

@property (nonatomic, strong) NSMutableArray *forwardDataArr;

/** 发送给/分别发送给*/
@property (nonatomic, strong) UILabel *sendObject;

/** 上面的线*/
@property (nonatomic, strong) UILabel *topLine;

/** 下面的线*/
@property (nonatomic, strong) UILabel *bottomLine;

/**头像昵称View*/
@property (nonatomic, strong) UIView  *topView;

/**消息View*/
@property (nonatomic, strong) UIView  *bottomView;

/**取消发送View*/
@property (nonatomic, strong) UIView  *sendView;

@end
@implementation MMPopoverViewController
#pragma mark - Init
- (instancetype)initWithDataSource:(NSMutableArray *)forwardDataArr
{
    self = [super init];
    if (self) {
        [self.forwardDataArr addObjectsFromArray:forwardDataArr];
    }

    return self;
}
#pragma mark - Getter
- (NSMutableArray *)forwardDataArr
{
    if (!_forwardDataArr) {
        _forwardDataArr = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _forwardDataArr;
}

-(UILabel *)sendObject
{
    if (!_sendObject) {
        _sendObject = [[UILabel alloc] init];
        _sendObject.font = [UIFont boldSystemFontOfSize:17.0f];
    }
    return _sendObject;
}

- (UILabel *)topLine
{
    if (!_topLine) {
        _topLine = [[UILabel alloc] init];
        _topLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _topLine;
}

- (UILabel *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UILabel alloc] init];
        _bottomLine.backgroundColor = [UIColor lightGrayColor];
    }
    return _bottomLine;
}

- (UIView *)topView
{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.backgroundColor = [UIColor whiteColor];
    }
    return _topView;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}

- (UIView *)sendView
{
    if (!_sendView) {
        _sendView = [[UIView alloc] init];
        _sendView.backgroundColor = [UIColor whiteColor];
    }
    return _sendView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //1.设置页面
    [self settingUp];
    //2.创建UI
    [self setupUI];
}
#pragma mark - Private
- (void)settingUp
{
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view.layer setMasksToBounds:YES];
    [self.view.layer setCornerRadius:8.0f];
}
- (void)setupUI
{
    [self.view addSubview:self.sendObject];
    [self.view addSubview:self.topView];
    [self.view addSubview:self.topLine];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.bottomLine];
    [self.view addSubview:self.sendView];
    //赋值 布局
    [self uploadValue];
    
}

- (void)uploadValue
{
    
    MMCommonModel *model = self.forwardDataArr[0];
    
    [self.sendObject mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.view.mas_top).offset(20);
        make.left.mas_equalTo(self.view.mas_left).offset(20);
        make.right.mas_equalTo(self.view.mas_right).offset(-20);
        make.height.mas_equalTo(30);
    }];
    
    if (self.forwardDataArr.count == 1) {
        
        self.sendObject.text = @"发送给:";
    
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.sendObject.mas_bottom);
            make.left.right.mas_equalTo(self.sendObject);
            make.height.mas_equalTo(56);
        }];
        
        //头像
        UIImageView *headView = [[UIImageView alloc] init];
        [headView sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:K_DEFAULT_USER_PIC];
        [headView setFrame:CGRectMake(0, 8, 40, 40)];
        [headView.layer setMasksToBounds:YES];
        [headView.layer setCornerRadius:20];
        [self.topView addSubview:headView];
        
        //昵称
        UILabel *nickLabel = [[UILabel alloc] init];
        nickLabel.text = model.name;
        [nickLabel setFont:[UIFont systemFontOfSize:17.0f]];
        [nickLabel setFrame:CGRectMake(CGRectGetMaxX(headView.frame)+8, 0, CGRectGetWidth(self.topView.frame)-CGRectGetMaxX(headView.frame)-8, 30)];
        [self.topView addSubview:nickLabel];
    
        [nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(headView.mas_right).offset(8);
            make.right.mas_equalTo(self.topView.mas_right).offset(-8);
            make.height.mas_equalTo(30);
            make.centerY.mas_equalTo(headView.mas_centerY);
        }];
        
    }else{
        self.sendObject.text = @"分别发送给:";
    }
    
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sendObject);
        make.top.mas_equalTo(self.topView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(40);
        make.left.right.mas_equalTo(self.sendObject);
        make.top.top.mas_equalTo(self.topLine.mas_bottom).offset(8);
    }];

    UIImageView *rightView = [[UIImageView alloc] init];
    [rightView setImage:[UIImage imageNamed:@"forward_icon"]];
    [self.bottomView addSubview:rightView];
    
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(15, 15));
        make.centerY.mas_equalTo(self.bottomView.mas_centerY);
        make.right.mas_equalTo(self.bottomView.mas_right);
    }];
    
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.text = @"Android-liuwei 你的客户端有什么查询和提交类的接口需要修改和增加的,找~~~";
    textLabel.numberOfLines = 2;
    textLabel.font = [UIFont systemFontOfSize:13];
    textLabel.textColor = [UIColor lightGrayColor];
    [self.bottomView addSubview:textLabel];
    
    [textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.bottomView);
        make.right.mas_equalTo(rightView.mas_left);
    }];
    
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.sendObject);
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(8);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.sendView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.bottomLine.mas_bottom);
    }];
    
    UIButton *cancle = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancle setTitle:@"取消" forState:UIControlStateNormal];
    [cancle setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancle.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [cancle addTarget:self action:@selector(cancle:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendView addSubview:cancle];
    
    CGFloat width = (SCREEN_WIDTH-2*30)/2;
    [cancle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sendView.mas_left);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.sendView.mas_top);
        make.width.mas_equalTo(width);
    }];
    
    UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
    [send setTitle:@"发送" forState:UIControlStateNormal];
    [send setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [send.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    [send addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendView addSubview:send];
    
    [send mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(width);
        make.height.mas_equalTo(50);
        make.top.mas_equalTo(self.sendView.mas_top);
        make.right.mas_equalTo(self.sendView.mas_right);
    }];

    [self.view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.sendView.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left).offset(30);
        make.right.mas_equalTo(self.view.mas_right).offset(-30);
        make.centerY.mas_equalTo(self.view.mas_centerY);
    }];
    
}

#pragma mark - Action

- (void)cancle:(UIButton *)sender
{
    MMLog(@"取消");
}

- (void)send:(UIButton *)sender
{
    MMLog(@"发送");
}

@end
