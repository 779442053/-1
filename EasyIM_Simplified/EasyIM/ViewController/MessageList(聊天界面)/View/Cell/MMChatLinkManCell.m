//
//  MMChatLinkManCell.m
//  EasyIM
//
//  Created by apple on 2019/8/19.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMChatLinkManCell.h"

static CGFloat const k_margin = 15;

@interface MMChatLinkManCell (){
    MMChatContentModel *_model;
}

@property(nonatomic,strong) UILabel     *labTitle;
@property(nonatomic,strong) UIView      *topLine;
@property(nonatomic,strong) UIImageView *imgPic;
@property(nonatomic,strong) UILabel     *labNickname;
@property(nonatomic,strong) UILabel     *labUsername;

@end

@implementation MMChatLinkManCell
- (void)awakeFromNib {
    [super awakeFromNib];
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
    _model = modelFrame.aMessage.slice;
    self.labNickname.text = _model.nickName;
    self.labUsername.text = [NSString stringWithFormat:@"账号：%@",_model.userID.checkTextEmpty?_model.userID:@""];

    if (_model.photo.checkTextEmpty) {
        [self.imgPic sd_setImageWithURL:_model.photo.mj_url placeholderImage:K_DEFAULT_USER_PIC];
    }
    else{
        self.imgPic.image = K_DEFAULT_USER_PIC;
    }
    
    //发送者
    if (modelFrame.aMessage.isSender) {
        _labTitle.textColor = [UIColor whiteColor];
        _labUsername.textColor = [UIColor whiteColor];
        _labNickname.textColor = [UIColor whiteColor];
    }
    //接收者
    else{
        _labTitle.textColor = [UIColor lightGrayColor];
        _labUsername.textColor = [UIColor lightGrayColor];
        _labNickname.textColor = [UIColor blackColor];
    }
}
-(void)initView{
    [self.contentView addSubview:self.labTitle];
    [self.labTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 21));
        make.left.equalTo(self.bubbleView).offset(k_margin);
        make.top.equalTo(self.bubbleView).offset(10);
    }];
    [self.contentView addSubview:self.topLine];
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(0.5);
        make.right.equalTo(self.bubbleView).offset(-k_margin);
        make.left.equalTo(self.bubbleView).offset(k_margin);
        make.top.equalTo(self.labTitle.mas_bottom).offset(0.5 * k_margin);
    }];
    
    [self.contentView addSubview:self.imgPic];
    [self.imgPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(45, 45));
        make.left.equalTo(self.labTitle.mas_left).offset(0);
        make.top.equalTo(self.topLine.mas_bottom).offset(10);
    }];
    [self.contentView addSubview:self.labNickname];
    [self.labNickname mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bubbleView).offset(-k_margin);
        make.height.offset(21);
        make.left.mas_equalTo(self.imgPic.mas_right).offset(10);
        make.top.mas_equalTo(self.imgPic.mas_top).offset(0);
    }];
    [self.contentView addSubview:self.labUsername];
    [self.labUsername mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.offset(21);
        make.left.mas_equalTo(self.imgPic.mas_right).offset(10);
        make.right.mas_equalTo(self.bubbleView).offset(-k_margin);
        make.bottom.mas_equalTo(self.imgPic.mas_bottom).offset(0);
    }];
    //MARK:点击事件
    self.bubbleView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(tapGestureAction:)];
    [self.bubbleView addGestureRecognizer:tapGest];
}


//MARK: - 名片点击事件
-(void)tapGestureAction:(UITapGestureRecognizer *)sender{
 
    if (_model && _model.userID.checkTextEmpty) {
        
        if (self.cellUserClick) {
            self.cellUserClick(_model.userID);
            return;
        }
    }
    
    [MMProgressHUD showHUD:@"联系人信息不存在"];
}


//MARK: - lazy load
- (UILabel *)labTitle{
    if (!_labTitle) {
        _labTitle = [BaseUIView createLable:CGRectZero
                                   AndText:@"推荐好友"
                              AndTextColor:[UIColor lightGrayColor]
                                AndTxtFont:FONT(12)
                        AndBackgroundColor:nil];
        
        _labTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _labTitle;
}

- (UIView *)topLine{
    if (!_topLine) {
        _topLine = [BaseUIView createView:CGRectZero
                       AndBackgroundColor:G_EEF0F3_COLOR
                              AndisRadius:NO
                                AndRadiuc:NO
                           AndBorderWidth:0
                           AndBorderColor:nil];
    }
    return _topLine;
}

- (UIImageView *)imgPic{
    if (!_imgPic) {
        _imgPic = [BaseUIView createImage:CGRectMake(0, 0, 45, 45)
                                 AndImage:K_DEFAULT_USER_PIC
                       AndBackgroundColor:nil
                             WithisRadius:YES];
    }
    return _imgPic;
}

- (UILabel *)labNickname{
    if (!_labNickname) {
        _labNickname = [BaseUIView createLable:CGRectZero
                                       AndText:nil
                                  AndTextColor:[UIColor blackColor]
                                    AndTxtFont:FONT(15)
                            AndBackgroundColor:nil];
        _labNickname.textAlignment = NSTextAlignmentLeft;
    }
    return _labNickname;
}

- (UILabel *)labUsername{
    if (!_labUsername) {
        _labUsername = [BaseUIView createLable:CGRectZero
                                       AndText:@"账号："
                                  AndTextColor:[UIColor lightGrayColor]
                                    AndTxtFont:FONT(13)
                            AndBackgroundColor:nil];
        _labUsername.textAlignment = NSTextAlignmentLeft;
    }
    return _labUsername;
}
@end
