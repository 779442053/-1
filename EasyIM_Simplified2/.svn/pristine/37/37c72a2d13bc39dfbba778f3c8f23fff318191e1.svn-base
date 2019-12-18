//
//  MMForwardCell.m
//  EasyIM
//
//  Created by momo on 2019/7/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMForwardCell.h"
#import "MMCommonModel.h"

@interface MMForwardCell ()

@property (nonatomic, strong) UIImageView *headImage;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation MMForwardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //布局View
        [self setupView];
    }
    return self;
}


#pragma mark - Private

- (void)setupView
{
    [self.contentView addSubview:self.headImage];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.identifierImage];
}

#pragma mark - Getter&Setter

- (UIImageView *)headImage
{
    if (!_headImage) {
        _headImage = [[UIImageView alloc] init];
    }
    return _headImage;
}

- (UIImageView *)identifierImage
{
    if (!_identifierImage) {
        _identifierImage = [[UIImageView alloc] init];
        [_identifierImage setImage:[UIImage imageNamed:@"group_unSelected"]];
    }
    return _identifierImage;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.userInteractionEnabled = YES;
    }
    return _titleLabel;
}

- (void)setModel:(MMCommonModel *)model
{
    _model = model;
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:K_DEFAULT_USER_PIC];
    self.titleLabel.text = model.name;
}



#pragma mark -LayoutSubviews

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.isEdit) {
        [self.identifierImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(20, 20));
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(self.contentView.mas_left).offset(8);
        }];
    }else{
        [self.identifierImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(0, 0));
            make.centerY.mas_equalTo(self.contentView.mas_centerY);
            make.left.mas_equalTo(self.contentView.mas_left).offset(8);
        }];
    }
    
    [self.headImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.identifierImage.mas_right).offset(8);
        make.width.height.mas_equalTo(40);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    [self.headImage.layer setCornerRadius:20];
    [self.headImage.layer setMasksToBounds:YES];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImage.mas_right).offset(8);
        make.centerY.mas_equalTo(self.headImage.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(120, 30));
    }];
    
}

- (void)setIsEdit:(BOOL)isEdit
{
    _isEdit = isEdit;
}

@end
