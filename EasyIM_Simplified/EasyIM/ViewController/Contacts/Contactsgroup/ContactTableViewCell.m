//
//  ContactTableViewCell.m
//  WeChatContacts-demo
//
//  Created by shen_gh on 16/3/12.
//  Copyright © 2016年 com.joinup(Beijing). All rights reserved.
//

#import "ContactTableViewCell.h"

#import "MMDateHelper.h"

@implementation ContactTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //布局View
        [self setUpView];
        
        UILongPressGestureRecognizer *longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressRecognizer:)];
        longRecognizer.minimumPressDuration = 0.5;//定义按的时间
        //        longRecognizer.numberOfTapsRequired = 1;
        [self.contentView addGestureRecognizer:longRecognizer];
        
    }
    return self;
}

#pragma mark - setUpView
- (void)setUpView{
    //头像
    [self.contentView addSubview:self.headImageView];
    //姓名
    [self.contentView addSubview:self.nameLabel];
    //底线
    [self.contentView addSubview:self.lineView];
    //详情
    [self.contentView addSubview:self.detailLabel];
    //时间
    [self.contentView addSubview:self.timeLabel];
    //未读数
    [self.contentView addSubview:self.unReadLabel];
}

#pragma mark - Lazy
- (UIImageView *)headImageView{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
        [_headImageView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _headImageView;
}

- (UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel=[[UILabel alloc] init];
        [_nameLabel setFont:[UIFont systemFontOfSize:14.0]];
    }
    return _nameLabel;
}

- (UILabel *)detailLabel{
    if (!_detailLabel) {
        _detailLabel=[[UILabel alloc] init];
        [_detailLabel setFont:[UIFont systemFontOfSize:11.0]];
        [_detailLabel setText:@"185xxxxxxxx"];
        [_detailLabel setTextColor:[UIColor lightGrayColor]];
    }
    return _detailLabel;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView=[[UIView alloc] initWithFrame:CGRectMake(0.0, 49.5, SCREEN_WIDTH, 0.5)];
        [_lineView setBackgroundColor:[UIColor colorWithRed:247.0/255 green:247.0/255 blue:247.0/255 alpha:1.0]];
    }
    return _lineView;
}

- (UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:12.0f];
        _timeLabel.textColor = [UIColor lightGrayColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
    }
    return _timeLabel;
}

- (UILabel *)unReadLabel{
    if (!_unReadLabel) {
        _unReadLabel = [[UILabel alloc] init];
        _unReadLabel.textColor = [UIColor whiteColor];
        _unReadLabel.backgroundColor = [UIColor redColor];
        _unReadLabel.textAlignment = NSTextAlignmentCenter;
        _unReadLabel.font = [UIFont systemFontOfSize:11];
        
        //        _unReadLabel.size = CGSizeMake(10, 10);
        //        [_unReadLabel.layer setMasksToBounds:YES];
        //        [_unReadLabel.layer setCornerRadius:5];
        
        _unReadLabel.hidden = YES;
    }
    return _unReadLabel;
}

#pragma mark - Pravite

- (void)setContactsModel:(ContactsModel *)contactsModel
{
    [self.imageView setHidden:YES];
    [self.textLabel setHidden:YES];
    [self.unReadLabel setHidden:YES];
    
    [self.headImageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.detailLabel setHidden:NO];
    
    NSURL *url = [NSURL URLWithString:[contactsModel.photoUrl containsString:@"http"]?contactsModel.photoUrl:@""];
    [self.headImageView sd_setImageWithURL:url placeholderImage:K_DEFAULT_USER_PIC];
    [self.nameLabel setText:contactsModel.remarkName== nil || [contactsModel.remarkName isEqualToString:@""]?contactsModel.nickName:contactsModel.remarkName];
    if ([contactsModel.online isEqualToString:@"1"]) {
        NSString *str = [NSString stringWithFormat:@"[在线]%@",contactsModel.userName];
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attriStr addAttribute:NSForegroundColorAttributeName
                         value:[UIColor blueColor]
                         range:NSMakeRange(0, 4)];
        [self.detailLabel setAttributedText:attriStr];
    }else{
        //        [self.detailLabel setText:model.userName];
        NSString *str = [NSString stringWithFormat:@"[离线]%@",contactsModel.userName];
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attriStr addAttribute:NSForegroundColorAttributeName
                         value:[UIColor lightGrayColor]
                         range:NSMakeRange(0, 4)];
        [self.detailLabel setAttributedText:attriStr];
    }
    
    [self setCellFrame];
}

//设置最近联系人Model
- (void)setRecentContacts:(MMRecentContactsModel *)recentContacts
{
    
    if (!recentContacts) {
        return;
    }
    
    [self.imageView setHidden:YES];
    [self.textLabel setHidden:YES];
    
    [self.headImageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.detailLabel setHidden:NO];
    [self.timeLabel setHidden:NO];
    
    NSURL *url = [NSURL URLWithString:[recentContacts.targetPhoto containsString:@"http"]?recentContacts.targetPhoto:@""];
    [self.headImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"contacts_group_icon"]];
    [self.nameLabel setText:recentContacts.targetNick.length?recentContacts.targetNick:recentContacts.targetName];
    [self.detailLabel setText:recentContacts.latestMsgStr];
    
    
    [self setCellFrame];
}


/** 设置*/
- (void)recentContactsWithModel:(MMRecentContactsModel *)model
{
    if (!model) {
        return;
    }
    [self.imageView setHidden:YES];
    [self.textLabel setHidden:YES];
    [self.headImageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.detailLabel setHidden:NO];
    [self.timeLabel setHidden:NO];
    
    NSURL *url = [NSURL URLWithString:[model.latestHeadImage containsString:@"http"]?model.latestHeadImage:@""];
    if ([model.latestHeadImage isEqualToString:@"tongzhi"]) {
        self.headImageView.image = [UIImage imageNamed:model.latestHeadImage];
    }else{
        [self.headImageView sd_setImageWithURL:url placeholderImage:K_DEFAULT_USER_PIC];
    }
    [self.nameLabel setText:model.latestnickname];
    [self.detailLabel setText:model.latestMsgStr];
    NSDate *date = [MMDateHelper dateWithTimeIntervalInMilliSecondSince1970:model.latestMsgTimeStamp];
    [self.timeLabel setText:[MMDateHelper formattedTime:date]];
    [self updateUnreadCount:model.unReadCount];
    [self setCellFrame];
    
}
- (void)searchWithModel:(SearchFriendModel *)model
{
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:K_DEFAULT_USER_PIC];
    [self.nameLabel setText:model.nickname];
    [self.detailLabel setText:model.mobile];
    [self setCellFrame];
}
- (void)setGroupModel:(MMGroupModel *)groupModel
{
    [self.imageView setHidden:YES];
    [self.textLabel setHidden:YES];
    [self.timeLabel setHidden:YES];
    [self.unReadLabel setHidden:YES];
    [self.headImageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.detailLabel setHidden:NO];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"contacts_group_icon"]];
    [self.nameLabel setText:groupModel.name];
    NSString *timeStr =  [MMDateHelper formattedTimeFromTimeInterval:groupModel.time];
    [self.detailLabel setText:timeStr];
    [self setCellFrame];
}
-(void)setZWgroupModel:(ZWGroupModel *)ZWgroupModel{
    [self.imageView setHidden:YES];
    [self.textLabel setHidden:YES];
    [self.timeLabel setHidden:YES];
    [self.unReadLabel setHidden:YES];
    [self.headImageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.detailLabel setHidden:YES];
    self.headImageView.image = [UIImage imageNamed:@"zwgroupIcon"];
    [self.nameLabel setText:ZWgroupModel.name];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.height.width.mas_equalTo(41);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(12);
        make.centerY.mas_equalTo(self.headImageView.mas_centerY);
        make.height.mas_equalTo(15);
    }];
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
        make.left.mas_equalTo(self.contentView.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth - 15, 0.5));
    }];
    
    
}
- (void)updateUnreadCount:(NSInteger)messageUnCount
{
    
    if (messageUnCount<1) {
        [self.unReadLabel setHidden:YES];
        return;
    }
    
    [self.unReadLabel setHidden:NO];
    NSString *numUnRead = messageUnCount > 99 ? @"99+" : [NSString stringWithFormat:@"%ld", messageUnCount];
    [self.unReadLabel setText:numUnRead];
}
-(void)updateNotifionModel:(ZWNotionModel *)Model{
    if (!Model) {
        return;
    }
    [self.imageView setHidden:YES];
    [self.textLabel setHidden:YES];
    [self.headImageView setHidden:NO];
    [self.nameLabel setHidden:NO];
    [self.detailLabel setHidden:NO];
    [self.timeLabel setHidden:NO];
    
    NSURL *url = [NSURL URLWithString:[Model.fromPhoto containsString:@"http"]?Model.fromPhoto:@""];
    [self.headImageView sd_setImageWithURL:url placeholderImage:K_DEFAULT_USER_PIC];
    [self.nameLabel setText:Model.fromName];
    NSString * latestMsgStr;
    switch (Model.bulletinType) {
        case BULLETIN_TYPE_ADD_FRIEND:
        {
            latestMsgStr = @"请求添加你为好友";
        }
            break;
        case BULLETIN_TYPE_BE_DEL_FRIEND:
        {
            latestMsgStr = @"被好友移除";
        }
            break;
        case BULLETIN_TYPE_ACCEPT_FRIEND:
        {
            latestMsgStr = @"同意加好友";
        }
            break;
        case BULLETIN_TYPE_BE_INVITE_INTO_GROUP:
        {
            latestMsgStr = @"邀请您加入群聊";
        }
            break;
        case BULLETIN_TYPE_REJECT_FRIEND://2
        {
            latestMsgStr = @"别人拒绝我加好友的申请";
        }
            break;
    default:
            {
                latestMsgStr = @"未定义的通知消息";
            }
        break;
    }
    [self.detailLabel setText:latestMsgStr];
    NSDate *date = [MMDateHelper dateWithTimeIntervalInMilliSecondSince1970:[Model.time doubleValue]];
    [self.timeLabel setText:[MMDateHelper formattedTime:date]];
    [self updateUnreadCount:1];
    [self setCellFrame];
}
- (void)setCellFrame
{
    
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.left.mas_equalTo(self.contentView.mas_left).offset(8);
        make.height.width.mas_equalTo(30);
    }];
    
    [self.headImageView.layer setCornerRadius:3];
    [self.headImageView.layer setMasksToBounds:YES];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImageView.mas_right).offset(8);
        make.top.mas_equalTo(self.headImageView.mas_top);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(15);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.nameLabel.mas_centerY);
        make.left.mas_equalTo(self.nameLabel.mas_right);
        make.height.mas_equalTo(15);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
    }];
    
    [self.unReadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom);
        make.right.mas_equalTo(self.timeLabel.mas_right);
        make.width.height.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    [self.unReadLabel.layer setMasksToBounds:YES];
    [self.unReadLabel.layer setCornerRadius:9];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nameLabel.mas_left);
        make.top.mas_equalTo(self.nameLabel.mas_bottom).offset(3);
        make.height.mas_equalTo(15);
        make.width.mas_equalTo(150);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@1);
    }];
    
}


#pragma mark - longPress delegate

- (void)longPressRecognizer:(UILongPressGestureRecognizer *)recognizer
{
    if ([self.delegate respondsToSelector:@selector(longPress:)]) {
        [self.delegate longPress:recognizer];
    }
}


@end
