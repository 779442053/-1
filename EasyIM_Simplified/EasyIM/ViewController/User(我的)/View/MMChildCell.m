//
//  MMChildCell.m
//  EasyIM
//
//  Created by momo on 2019/9/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMChildCell.h"

@interface MMChildCell ()

@property (nonatomic, strong) UILabel *bankNameLabel;//银行卡名称
@property (nonatomic, strong) UILabel *bankTimeLabel;//时间
@property (nonatomic, strong) UILabel *bankAmountLabel;//支出或收入
@property (nonatomic, strong) UILabel *bankStateLabel;//状态

@end

@implementation MMChildCell

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
    [self.contentView addSubview:self.bankTimeLabel];
    [self.contentView addSubview:self.bankNameLabel];
    [self.contentView addSubview:self.bankAmountLabel];
    [self.contentView addSubview:self.bankStateLabel];
}


- (void)setChildModel:(MMChildModel *)childModel
{
    _childModel = childModel;
    self.bankNameLabel.text = childModel.bankName;
    self.bankTimeLabel.text = childModel.bankTime;
    self.bankAmountLabel.text = [NSString stringWithFormat:@"%.2f",childModel.bankAmount];
    NSString *state = @"";
    switch (childModel.bankState) {
        case 0:
            state = @"已完成";
            _bankStateLabel.textColor = [UIColor blueColor];
            break;
        case 1:
            state = @"未完成";
            _bankStateLabel.textColor = [UIColor redColor];
            break;
        default:
            state = @"未知";
            _bankStateLabel.textColor = [UIColor orangeColor];
            break;
    }
    self.bankStateLabel.text = state;
}

- (void)layoutSubviews
{
    [self.bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.height.mas_equalTo(30);
    }];
    
    [self.bankTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bankNameLabel.mas_left);
        make.top.mas_equalTo(self.bankNameLabel.mas_bottom).offset(8);
        make.height.mas_equalTo(30);
    }];
    
    [self.bankAmountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.top.mas_equalTo(self.bankNameLabel.mas_top);
        make.height.mas_equalTo(30);
    }];
    
    [self.bankStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.bankAmountLabel.mas_right);
        make.top.mas_equalTo(self.bankTimeLabel.mas_top);
        make.height.mas_equalTo(30);
    }];
}

#pragma mark - Getter

- (UILabel *)bankNameLabel
{
    if (!_bankNameLabel) {
        _bankNameLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@"中国银行(5888)"
                                    AndTextColor:[UIColor blackColor]
                                      AndTxtFont:FONT(15)
                              AndBackgroundColor:nil
                          ];
    }
    return _bankNameLabel;
}

- (UILabel *)bankAmountLabel
{
    if (!_bankAmountLabel) {
        _bankAmountLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@"- 100.00"
                                    AndTextColor:[UIColor blackColor]
                                      AndTxtFont:FONT(15)
                              AndBackgroundColor:nil
                          ];
        _bankAmountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _bankAmountLabel;
}

- (UILabel *)bankStateLabel
{
    if (!_bankStateLabel) {
        _bankStateLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@"已完成"
                                    AndTextColor:[UIColor blueColor]
                                      AndTxtFont:FONT(13)
                              AndBackgroundColor:nil
                          ];
        _bankStateLabel.textAlignment = NSTextAlignmentRight;
    }
    return _bankStateLabel;
}

- (UILabel *)bankTimeLabel
{
    if (!_bankTimeLabel) {
        _bankTimeLabel = [BaseUIView createLable:CGRectZero
                                         AndText:@"9月11日 01:00"
                                    AndTextColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3]
                                      AndTxtFont:FONT(13)
                              AndBackgroundColor:nil
                          ];
    }
    return _bankTimeLabel;
}


@end
