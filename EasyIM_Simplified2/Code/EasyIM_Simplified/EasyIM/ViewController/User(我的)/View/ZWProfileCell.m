//
//  ZWProfileCell.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/3.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWProfileCell.h"
@interface ZWProfileCell()
@property(nonatomic,strong)UILabel *titleLB;
@property(nonatomic,strong)UIImageView *headImageView;
@property(nonatomic,strong)UIImageView *QRcodeImageView;
@property(nonatomic,strong)UILabel *subTitle;
@end
@implementation ZWProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)updateWithTitle:(NSString *)title subTitle:(NSString *)subtitle indexPath:(NSIndexPath*)indexpath{
    if (indexpath.section == 0) {
        self.titleLB.text = title;
        switch (indexpath.row) {
            case 0:
            {
                ZWWLog(@"subtitle= %@",subtitle)
                [self.headImageView sd_setImageWithURL:[NSURL URLWithString:subtitle] placeholderImage:[UIImage imageNamed:@"setting_default_icon"]];
                self.QRcodeImageView.hidden = YES;
                self.subTitle.hidden = YES;
            }
                break;
            case 1:
            {
                self.subTitle.text = subtitle;
                self.QRcodeImageView.hidden = YES;
                self.headImageView.hidden = YES;
            }
            break;
            case 2:
            {
                self.subTitle.text = subtitle;
                self.QRcodeImageView.hidden = YES;
                self.headImageView.hidden = YES;
            }
            break;
            case 3:
            {
                self.subTitle.text = subtitle;
                self.QRcodeImageView.hidden = YES;
                self.headImageView.hidden = YES;
            }
            break;
            case 4:
            {   self.headImageView.hidden = YES;
                self.subTitle.hidden = YES;
            }
            break;
                
            default:
                break;
        }
    }else{
        self.titleLB.text = title;
        switch (indexpath.row) {
            case 0:
            {
                self.subTitle.text = subtitle;
                self.QRcodeImageView.hidden = YES;
                self.headImageView.hidden = YES;
            }
                break;
            case 1:
            {
                self.subTitle.text = subtitle;
                self.QRcodeImageView.hidden = YES;
                self.headImageView.hidden = YES;
            }
                break;
            case 2:
            {
                self.subTitle.text = subtitle;
                self.QRcodeImageView.hidden = YES;
                self.headImageView.hidden = YES;
            }
                break;
                
            default:
                break;
        }
    }
}
-(void)zw_setupViews{
    [self.contentView addSubview:self.titleLB];
    [self.titleLB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).with.mas_offset(15);
    }];
    [self.contentView addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.mas_offset(-30);
        make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    self.headImageView.layer.cornerRadius = 5;
    self.headImageView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.subTitle];
    [self.subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.mas_offset(-30);
    }];
    [self.contentView addSubview:self.QRcodeImageView];
    [self.QRcodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.mas_offset(-30);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    UIImageView *rightImage = [[UIImageView alloc]init];
    rightImage.image = [UIImage imageNamed:@"forward_icon"];
    [self.contentView addSubview:rightImage];
    [rightImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).with.mas_offset(-15);
        make.size.mas_equalTo(CGSizeMake(11, 15));
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (UILabel *)titleLB{
    if (_titleLB == nil) {
        _titleLB = [[UILabel alloc]init];
        _titleLB.font = [UIFont zwwNormalFont:13];
        _titleLB.textColor = [UIColor blackColor];
    }
    return _titleLB;
}
-(UILabel *)subTitle{
    if (_subTitle == nil) {
        _subTitle = [[UILabel alloc]init];
        _subTitle.font = [UIFont zwwNormalFont:12];
        _subTitle.textColor = [UIColor colorWithHexString:@"#787878"];
        _subTitle.textAlignment = NSTextAlignmentRight;
    }
    return _subTitle;
}//forward_icon
-(UIImageView *)headImageView{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc]init];
        _headImageView.image = [UIImage imageNamed:@"setting_default_icon"];
    }
    return _headImageView;
}
-(UIImageView *)QRcodeImageView{
    if (_QRcodeImageView == nil) {
        _QRcodeImageView = [[UIImageView alloc]init];//
        _QRcodeImageView.image = [UIImage imageNamed:@"mine_qrcode"];
    }
    return _QRcodeImageView;
}

@end
