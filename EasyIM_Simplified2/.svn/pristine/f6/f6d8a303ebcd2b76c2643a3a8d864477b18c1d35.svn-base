//
//  MMAccountInfoCell.m
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMAccountInfoCell.h"

@implementation MMAccountInfoCell

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
    [self.contentView addSubview:self.accountName];
    [self.contentView addSubview:self.accountWallet];
}

- (void)layoutSubviews
{
    [self.accountName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];
    
    [self.accountWallet mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
    }];

}

#pragma mark - Getter

- (UILabel *)accountName
{
    if (!_accountName) {
        _accountName = [BaseUIView createLable:CGRectZero
                                       AndText:@"测试"
                                  AndTextColor:RGBCOLOR(102, 102, 102)
                                    AndTxtFont:FONT(13)
                            AndBackgroundColor:[UIColor whiteColor]];
    }
    return _accountName;
}

- (UILabel *)accountWallet
{
    if (!_accountWallet) {
        _accountWallet = [BaseUIView createLable:CGRectZero
                                       AndText:@"100.00"
                                  AndTextColor:[UIColor blackColor]
                                    AndTxtFont:FONT(13)
                            AndBackgroundColor:[UIColor whiteColor]];
        _accountWallet.textAlignment = NSTextAlignmentRight;
    }
    return _accountWallet;
}


#pragma mark -

- (void)setAccountModel:(MMAccountInfoModel *)accountModel
{
    _accountModel = accountModel;
    self.accountName.text = accountModel.accountName;
    self.accountWallet.text = [NSString stringWithFormat:@"%.2f",accountModel.accountWallet];
}

@end
