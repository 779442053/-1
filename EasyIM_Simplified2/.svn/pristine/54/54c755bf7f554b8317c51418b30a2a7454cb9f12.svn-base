//
//  MMMemberCell.m
//  EasyIM
//
//  Created by momo on 2019/5/27.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMMemberCell.h"

@interface MMMemberCell ()

/** 头像*/
@property(nonatomic, strong) UIImageView *headImageView;

/** 名称*/
@property(nonatomic, strong) UILabel *nameLabel;

@end


@implementation MMMemberCell

#pragma mark - Getter

- (UIImageView *)headImageView
{
    if (!_headImageView) {
        _headImageView = [[UIImageView alloc] init];
    }
    
    return _headImageView;
}

- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:13];
        _nameLabel.textColor = MMColor(242, 242, 242);
    }
    return _nameLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setupUI];
}

#pragma mark - Private

- (void)setupUI
{
    
    self.backgroundColor = [UIColor orangeColor];
//    [self.contentView addSubview:self.headImageView];
//    [self.contentView addSubview:self.nameLabel];
}

- (void)setMemberList:(NSMutableArray *)memberList
{
    
    _memberList = memberList;
    
    CGFloat padding = 16.0f;//距离两边距离
    CGFloat start_x = 16.0f;//第一个按钮的X坐标
    CGFloat start_y = 8.0f;//第一个按钮的Y坐标
    CGFloat image_height = 46.0f;//图片宽
    CGFloat image_width = 46.0f;//图片高
    CGFloat width_space = (SCREEN_WIDTH-2*padding - 5*image_width)/4;//2个图片之间的横间距
    CGFloat height_space = 15.0f;//竖间距
    
    
    if (memberList.count) {
        
        for (int i = 0; i<memberList.count+1; i++) {
            
            NSInteger index = i % 5;
            NSInteger page = i / 5;
            
            UIImageView *headImageView = [[UIImageView alloc] init];
            [self.contentView addSubview:headImageView];
            
            UILabel *nameLabel = [[UILabel alloc] init];
            nameLabel.font = [UIFont systemFontOfSize:13];
            nameLabel.textColor = [UIColor lightGrayColor];
            
            nameLabel.numberOfLines = 1;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:nameLabel];
            
            headImageView.frame = CGRectMake(index *(image_width + width_space) +start_x, page* (image_height +height_space + image_height/2) + start_y, image_width, image_height);
            [headImageView.layer setMasksToBounds:YES];
            [headImageView.layer setCornerRadius:image_height/2];
            
            nameLabel.frame = CGRectMake(CGRectGetMinX(headImageView.frame), CGRectGetMaxY(headImageView.frame) + 5, image_width, image_height/2);
            
            if (i == memberList.count) {
                UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
                tapGesture.numberOfTapsRequired = 1;
                [tapGesture addTarget:self action:@selector(addGroupMember:)];
                
                headImageView.image = [UIImage imageNamed:@"chat_addGroupMem_icon"];
                headImageView.userInteractionEnabled = YES;
                [headImageView addGestureRecognizer:tapGesture];
                nameLabel.text = @"邀请";
                nameLabel.textColor = RGBCOLOR(0, 183, 238);
            }else{
                MemberList *member = memberList[i];
                [headImageView sd_setImageWithURL:member.photoUrl.mj_url placeholderImage:K_DEFAULT_USER_PIC];
                nameLabel.text = member.userName;
            }
        }
        
    }
}

#pragma mark - Tap

- (void)addGroupMember:(UIGestureRecognizer *)gesture
{
    if (_delegate && [_delegate respondsToSelector:@selector(addGroupMemberWithGesR:)]) {
        [self.delegate addGroupMemberWithGesR:gesture];
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
