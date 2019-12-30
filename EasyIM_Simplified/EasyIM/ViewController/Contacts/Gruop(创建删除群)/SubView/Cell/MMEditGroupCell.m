//
//  MMEditGroupCell.m
//  EasyIM
//
//  Created by momo on 2019/6/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMEditGroupCell.h"

@implementation MMEditGroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setUI];
    }
    return self;
}
-(void)setUI{
    self.headImage.frame = CGRectMake(10, 10, 40, 40);
    [self.contentView addSubview:self.headImage];
    self.nameLbl.frame = CGRectMake(62, 23, 200, 14);
    [self.contentView addSubview:self.nameLbl];
}
-(UIImageView *)headImage{
    if (_headImage == nil) {
        _headImage = [[UIImageView alloc]init];
    }
    return _headImage;
}
-(UILabel *)nameLbl{
    if (_nameLbl == nil) {
        _nameLbl = [[UILabel alloc]init];
        _nameLbl.textColor = [UIColor blackColor];
        _nameLbl.font = [UIFont zwwNormalFont:13];
    }
    return _nameLbl;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
