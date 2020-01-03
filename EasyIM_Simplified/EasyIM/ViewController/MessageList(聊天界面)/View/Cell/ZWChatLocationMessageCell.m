//
//  ZWChatLocationMessageCell.m
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWChatLocationMessageCell.h"
@interface ZWChatLocationMessageCell(){
    MMMessageFrame *_FramMessage;
}
@property (nonatomic, strong) UIImageView *locationIV;
@property (nonatomic, strong) UILabel *locationAddressL;
@end
@implementation ZWChatLocationMessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initView];
    }
    return self;
}
- (void)setModelFrame:(MMMessageFrame *)modelFrame
{
    [super setModelFrame:modelFrame];
    _FramMessage = modelFrame;
    _locationAddressL.text= modelFrame.aMessage.slice.address;
}
-(void)initView{
    [self.contentView addSubview:self.locationIV];
    [self.locationIV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bubbleView.mas_left);
        make.top.equalTo(self.bubbleView.mas_top);
        make.width.equalTo(@230);
        make.height.equalTo(@127);
    }];
    [self.contentView addSubview:self.locationAddressL];
    [self.locationAddressL mas_makeConstraints:^(MASConstraintMaker *make)
        {
            make.left.equalTo(self.locationIV.mas_left).with.offset(8);
            make.top.equalTo(self.locationIV.mas_top);
            make.right.equalTo(self.bubbleView.mas_right).with.offset(-8);
        }];
    
    self.bubbleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapGestureAction:)];
    [self.bubbleView addGestureRecognizer:tapGest];
}
-(void)tapGestureAction:(UITapGestureRecognizer *)sender{
    if (_FramMessage && _FramMessage.aMessage.slice.address.checkTextEmpty) {
        if (self.AddeesscellUserClick) {
      self.AddeesscellUserClick(_FramMessage.aMessage.slice.address,_FramMessage.aMessage.slice.jingDu,_FramMessage.aMessage.slice.weiDu);
            return;
        }
    }
    
    [MMProgressHUD showHUD:@"联系人信息不存在"];
}
- (UILabel *)locationAddressL
{
    if (!_locationAddressL)
    {
        _locationAddressL = [[UILabel alloc] init];
        _locationAddressL.textColor = [UIColor blackColor];
        _locationAddressL.font = [UIFont systemFontOfSize:16.0f];
        _locationAddressL.numberOfLines = 3;
        _locationAddressL.textAlignment = NSTextAlignmentNatural;
        _locationAddressL.lineBreakMode = NSLineBreakByTruncatingTail;
        _locationAddressL.text = @"上海市浦东新区环湖西一路99号";
    }
    return _locationAddressL;
}
- (UIImageView *)locationIV
{
    if (!_locationIV)
    {
        _locationIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location"]];
    }
    return _locationIV;
}
@end
