//
//  SearchFriendCell.m
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/14.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "SearchFriendCell.h"
#import "MMGroupModel.h"

@interface SearchFriendCell()
@property (nonatomic, strong)   UIImageView *headView;
@property (nonatomic, strong)   UILabel *titleLabel;
@property (nonatomic, strong)   UILabel *desLabel;
@end

@implementation SearchFriendCell

- (UIImageView *)headView{
    if (!_headView) {
        _headView = [[UIImageView alloc] init];
        [_headView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _headView;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel=[[UILabel alloc] init];
        [_titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    return _titleLabel;
}

- (UILabel *)desLabel{
    if (!_desLabel) {
        _desLabel=[[UILabel alloc] init];
        [_desLabel setFont:[UIFont systemFontOfSize:11.0]];
        [_desLabel setText:@"---"];
        [_desLabel setTextColor:[UIColor lightGrayColor]];
    }
    return _desLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setUI];
    }
    return self;
}


- (void)setUI {
    
    [self.contentView addSubview:self.headView];
    
    [self.contentView addSubview:self.titleLabel];
    
    [self.contentView addSubview:self.desLabel];
    
//    [self.contentView addSubview:self.lineView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(50, 0, 48, 48)];
    [button setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
//    button.imageView.size = CGSizeMake(22, 22);
//    [button setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
    [self.contentView addSubview:button];
    self.button = button;
    
    [self setMasonry];
}

- (void)setMasonry {
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(8);
        make.height.width.mas_equalTo(30);
    }];
    
    [self.headView.layer setCornerRadius:15];
    [self.headView.layer setMasksToBounds:YES];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headView.mas_right).offset(8);
        make.top.mas_equalTo(self.headView.mas_top);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(15);
    }];
    
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel.mas_left);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(250);
    }];
    
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(48);
        make.height.mas_equalTo(48);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setModel:(SearchFriendModel *)model
{
    if (model.photoUrl.checkTextEmpty) {
        [self.headView sd_setImageWithURL:model.photoUrl.mj_url
                         placeholderImage:K_DEFAULT_USER_PIC];
    }
    else{
        self.headView.image = K_DEFAULT_USER_PIC;
    }
    
    [self.titleLabel setText:model.nickname.length ? model.nickname : model.username];
    [self.desLabel setText:model.mobile];

}

- (void)cellInitGroupData:(MMGroupModel *_Nullable)model{
    if (!model) {
        NSLog(@"群组数据不存在");
        return;
    }
    if (model.photo.checkTextEmpty) {
        [self.headView sd_setImageWithURL:model.photo.mj_url
                         placeholderImage:[UIImage imageNamed:@"contacts_group_icon"]];
    }
    else{
        self.headView.image = [UIImage imageNamed:@"contacts_group_icon"];
    }
    
    [self.titleLabel setText:model.name.checkTextEmpty ? model.name : @"佚名群"];
    [self.desLabel setText:model.bulletin];
}

@end
