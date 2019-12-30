//
//  NewFriendCell.m
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/15.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "NewFriendCell.h"
#import "MMDateHelper.h"

@interface NewFriendCell()

@end

@implementation NewFriendCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSeparatorStyleNone;
        [self setUI];
    }
    return self;
}
- (void)setUI {
    UIImageView *headerImgView = [[UIImageView alloc] init];
    headerImgView.image = K_DEFAULT_USER_PIC;
    headerImgView.layer.masksToBounds = YES;
    headerImgView.layer.cornerRadius = 3;
    self.headerImgView = headerImgView;
    [self.contentView addSubview:headerImgView];
    UILabel *nickNameLabel = [[UILabel alloc] init];
    nickNameLabel.text = @"";
    nickNameLabel.textColor = MMRGB(0x333333);
    nickNameLabel.font = [UIFont systemFontOfSize:15];
    self.nickNameLabel = nickNameLabel;
    [self.contentView addSubview:nickNameLabel];
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.text = @"";
    infoLabel.textColor = MMRGB(0x9DA1A7);
    infoLabel.font = [UIFont systemFontOfSize:14];
    self.infoLabel = infoLabel;
    [self.contentView addSubview:infoLabel];
    UIButton *certainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [certainBtn addTarget:self action:@selector(certainBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [certainBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [self.contentView addSubview:certainBtn];
    self.certainBtn = certainBtn;
    [headerImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.centerY.mas_equalTo(self.contentView);
        make.width.height.mas_equalTo(60);
    }];
    [nickNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerImgView.mas_right).offset(10);
        make.top.mas_equalTo(headerImgView.mas_top).offset(8);
    }];
    [certainBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.centerY.mas_equalTo(headerImgView);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(80);
    }];
    [certainBtn.layer setMasksToBounds:YES];
    [certainBtn.layer setCornerRadius:5];
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(nickNameLabel);
        make.bottom.mas_equalTo(headerImgView.mas_bottom).offset(-8);
        make.right.mas_equalTo(certainBtn.mas_left);
    }];
}
- (void)certainBtnClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didAgreeWithCell:)]) {
        [self.delegate didAgreeWithCell:self];
    }
}
- (void)setModel:(NewFriendModel *)model
{
    _model = model;
    [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:model.fromPhoto] placeholderImage:K_DEFAULT_USER_PIC];
    self.nickNameLabel.text = [model.fromNick isEqualToString:@""] || model.fromNick == nil? model.fromName: model.fromNick;
    switch (model.bulletinType) {
        case BULLETIN_TYPE_ADD_FRIEND:
        {
            self.certainBtn.userInteractionEnabled = YES;
            [self.certainBtn setTitle:@"接受" forState:UIControlStateNormal];
            self.infoLabel.text = @"申请添加您为好友";
            self.certainBtn.backgroundColor = [UIColor colorWithHexString:@"#01A1EF"];
            [self.certainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_ACCEPT_FRIEND:
        {
            self.certainBtn.userInteractionEnabled = NO;
            self.infoLabel.text = @"您已经同意添加对方为好友";
            [self.certainBtn setTitle:@"已接受" forState:UIControlStateNormal];
            [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
            [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_REJECT_FRIEND:
        {
            self.certainBtn.userInteractionEnabled = NO;
            self.infoLabel.text = @"您已拒绝添加对方为好友";
            [self.certainBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
            [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
            [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_BE_ACCEPT_FRIEND://被同意加好友(群)
        {
            self.certainBtn.userInteractionEnabled = NO;
            self.infoLabel.text = @"对方同意您的添加好友请求";
            [self.certainBtn setTitle:@"已添加" forState:UIControlStateNormal];
            [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
            [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_BE_REJECT_FRIEND://被拒绝加好友(群)
        {
            self.certainBtn.userInteractionEnabled = NO;
            self.infoLabel.text = @"您的加好友请求已被对方拒绝";
            [self.certainBtn setTitle:@"已被对方拒绝" forState:UIControlStateNormal];
            [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
            [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_BE_DEL_FRIEND://被好友移除
        {
            self.certainBtn.userInteractionEnabled = NO;
            self.infoLabel.text = @"对方已经将您移除";
            [self.certainBtn setTitle:@"对方已删除您" forState:UIControlStateNormal];
            [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
            [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_BE_INVITE_INTO_GROUP://邀请加入群
        {
            self.certainBtn.userInteractionEnabled = YES;
            self.infoLabel.text = @"邀请您加入群聊";
            [self.certainBtn setTitle:@"同意加入群" forState:UIControlStateNormal];
            self.certainBtn.backgroundColor = [UIColor colorWithHexString:@"#01A1EF"];
            [self.certainBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
            break;
        case BULLETIN_TYPE_BE_KICK_OUT_GROUP://被提出群
        {
            self.certainBtn.userInteractionEnabled = NO;
            self.infoLabel.text = @"您已经被提出群聊";
            [self.certainBtn setTitle:@"被移出群聊" forState:UIControlStateNormal];
            [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
            [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
            break;
        default:
            {
                self.certainBtn.userInteractionEnabled = NO;
                self.infoLabel.text = @"未知通知类型";
                [self.certainBtn setTitle:@"未知" forState:UIControlStateNormal];
                [self.certainBtn setBackgroundColor:[UIColor whiteColor]];
                [self.certainBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            }
            break;
    }
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
