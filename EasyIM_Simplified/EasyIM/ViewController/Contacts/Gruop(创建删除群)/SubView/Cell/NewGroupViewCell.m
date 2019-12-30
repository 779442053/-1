//
//  NewGroupViewCell.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/28.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "NewGroupViewCell.h"
@interface NewGroupViewCell()

@end
@implementation NewGroupViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.logoImage.frame = CGRectMake(10, 10, 42, 42);
        [self.logoImage setLayerBorderWidth:0 borderColor:nil cornerRadius:5];
        [self.contentView addSubview:self.logoImage];
        self.name.frame = CGRectMake(CGRectGetMaxX(self.logoImage.frame) + 12, 23, 200, 15);
        [self.contentView addSubview:self.name];
        self.selBtn.frame = CGRectMake(KScreenWidth - 54, 20, 20, 20);
        [self.contentView addSubview:self.selBtn];
        [self.selBtn addTarget:self action:@selector(clickSelBtn:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (void)clickSelBtn:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectCellWithSelectText:isSelect:indexPath:)]) {
        [self.delegate selectCellWithSelectText:self.name.text
                                       isSelect:sender.isSelected
                                      indexPath:self.indexPath];
    }
}
-(UIImageView *)logoImage{
    if (_logoImage == nil) {
        _logoImage = [[UIImageView alloc]init];
    }
    return _logoImage;
}
-(UIImageView *)selImage{
    if (_selImage == nil) {
        _selImage = [[UIImageView alloc]init];
    }
    return _selImage;
}
-(UIButton *)selBtn{
    if (_selBtn == nil) {
        _selBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_selBtn setBackgroundImage:[UIImage imageNamed:@"group_unSelected"] forState:UIControlStateNormal];
        [_selBtn setBackgroundImage:[UIImage imageNamed:@"group_selected"] forState:UIControlStateSelected];
    }
    return _selBtn;
}
-(UILabel *)name{
    if (_name == nil) {
        _name = [[UILabel alloc]init];
        _name.textColor = [UIColor colorWithHexString:@"#000000"];
        _name.font = [UIFont zwwNormalFont:15];
    }
    return _name;
}
-(UILabel *)desLable{
    if (_desLable == nil) {
        _desLable = [[UILabel alloc]init];
        _desLable.textColor = [UIColor colorWithHexString:@"#333333"];
        _desLable.font = [UIFont zwwNormalFont:12];
        _desLable.text = @"最后上线于:";
    }
    return _desLable;
}

@end
