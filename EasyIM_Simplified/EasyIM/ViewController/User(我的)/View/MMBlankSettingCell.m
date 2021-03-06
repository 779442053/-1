//
//  MMBlankSettingCell.m
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBlankSettingCell.h"

@interface MMBlankSettingCell ()

@property (nonatomic, strong) UILabel *bankNameLabel;
@property (nonatomic, strong) UILabel *bankNumLabel;
@property (nonatomic, strong) UIImageView *bankIconImage;
@property (nonatomic, strong) UIView *bankView;

@end

@implementation MMBlankSettingCell

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
    [self.contentView addSubview:self.bankView];
    [self.bankView addSubview:self.bankNameLabel];
    [self.bankView addSubview:self.bankNumLabel];
    [self.bankView addSubview:self.bankIconImage];
}

- (void)layoutSubviews
{
    
    [self.bankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(20);
        make.top.bottom.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-20);
    }];
    
    [self.bankIconImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self.bankView).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.bankNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bankIconImage.mas_right).offset(12);
        make.top.mas_equalTo(self.bankIconImage.mas_top);
        make.height.mas_equalTo(30);
    }];
    
    [self.bankNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bankNameLabel.mas_left);
        make.top.mas_equalTo(self.bankNameLabel.mas_bottom);
        make.height.mas_equalTo(30);
    }];
}

- (void)setBankSettingModel:(MMBlankSettingModel *)bankSettingModel
{
    _bankSettingModel = bankSettingModel;
    [self.bankIconImage setImage:[UIImage imageNamed:bankSettingModel.bankIcon]];
    self.bankNumLabel.text = bankSettingModel.bankNum;
    self.bankNameLabel.text = bankSettingModel.bankName;
}

#pragma mark - Getter

- (UILabel *)bankNameLabel
{
    if (!_bankNameLabel) {
        _bankNameLabel = [BaseUIView createLable:CGRectZero
                                       AndText:@"中国银行"
                                    AndTextColor:[UIColor whiteColor]
                                    AndTxtFont:FONT(15)
                            AndBackgroundColor:[UIColor clearColor]
                          ];
    }
    return _bankNameLabel;
}

- (UILabel *)bankNumLabel
{
    if (!_bankNumLabel) {
        _bankNumLabel = [BaseUIView createLable:CGRectZero
                                       AndText:@"**** **** **** 5678"
                                  AndTextColor:[UIColor whiteColor]
                                    AndTxtFont:FONT(13)
                            AndBackgroundColor:[UIColor clearColor]
                         ];
    }
    return _bankNumLabel;
}

- (UIImageView *)bankIconImage
{
    if (!_bankIconImage) {
        _bankIconImage =[BaseUIView createImage:CGRectZero
                                       AndImage:[UIImage imageNamed:@"wallet_boc"]
                             AndBackgroundColor:nil
                                      AndRadius:YES
                                    WithCorners:10
                         ];
    }
    return _bankIconImage;
}

- (UIView *)bankView
{
    if (!_bankView) {
        _bankView = [BaseUIView createView:CGRectZero
                        AndBackgroundColor:RGBCOLOR(255, 131, 97)
                               AndisRadius:YES AndRadiuc:10
                            AndBorderWidth:0
                            AndBorderColor:0
                     ];
        _bankView.layer.shadowOffset = CGSizeMake(0, 2);
        _bankView.layer.shadowOpacity = 1;
        _bankView.layer.shadowRadius = 7;
    }
    return _bankView;
}
@end


