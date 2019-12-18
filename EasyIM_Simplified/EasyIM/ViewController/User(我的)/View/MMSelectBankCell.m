//
//  MMSelectBankCell.m
//  EasyIM
//
//  Created by momo on 2019/9/12.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMSelectBankCell.h"

@interface MMSelectBankCell ()

@end

@implementation MMSelectBankCell

static CGFloat const padding = 25.0f;

#pragma mark - Init

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self.contentView addSubview:self.bankImageView];
    [self.contentView addSubview:self.bankNameLabel];
    [self.contentView addSubview:self.selectIcon];
}


- (void)layoutSubviews
{
    
    [self.bankImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(padding);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    [self.bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.bankImageView.mas_right).offset(padding);
    }];
    
    [self.selectIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-padding);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
}

- (void)setSelectBankModel:(MMSelectBankModel *)selectBankModel
{
    _selectBankModel = selectBankModel;
    self.bankNameLabel.text = selectBankModel.bankName;
    [self.bankImageView setImage:[UIImage imageNamed:selectBankModel.bankImageName]];
}

#pragma mark - Getter

- (UILabel *)bankNameLabel
{
    if (!_bankNameLabel) {
        _bankNameLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@"刘晓灰的瑞士银行卡(5888)"
                                    AndTextColor:[UIColor blackColor]
                                      AndTxtFont:[UIFont zwwNormalFont:15]
                              AndBackgroundColor:nil
                          ];
    }
    return _bankNameLabel;
}

- (UIImageView *)selectIcon
{
    if (!_selectIcon) {
        _selectIcon =[BaseUIView createImage:CGRectZero
                                       AndImage:[UIImage imageNamed:@"wallet_unselect"]
                             AndBackgroundColor:nil
                                      AndRadius:NO
                                    WithCorners:0
                         ];
    }
    return _selectIcon;
}

- (UIImageView *)bankImageView
{
    if (!_bankImageView) {
        _bankImageView =[BaseUIView createImage:CGRectZero
                                       AndImage:[UIImage imageNamed:@"wallet_small_icbc"]
                             AndBackgroundColor:nil
                                      AndRadius:NO
                                    WithCorners:0
                         ];
    }
    return _bankImageView;
}

@end
