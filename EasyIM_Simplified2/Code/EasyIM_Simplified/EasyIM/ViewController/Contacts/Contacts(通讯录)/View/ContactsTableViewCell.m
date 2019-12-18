//
//  ContactsTableViewCell.m
//  EasyIM
//
//  Created by apple on 2019/8/24.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ContactsTableViewCell.h"

static CGFloat const cell_height = 60;
static NSString *const cell_identify = @"contact_cell_identify";

@interface ContactsTableViewCell()

@property(nonatomic,strong) UIImageView *imgPic;
@property(nonatomic,strong) UILabel *labTitle;
@property(nonatomic,strong) UILabel *labNO;
@end

@implementation ContactsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initCell];
    }
    return self;
}

-(void)initCell{
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //MARK:图像
    [self.contentView addSubview:self.imgPic];
    
    //MARK:标题
    [self.contentView addSubview:self.labTitle];
    
    //MARK:气泡
    [self.contentView addSubview:self.labNO];
}

+(CGFloat)getCellHeight{
    return cell_height;
}

+(NSString *)getCellIdentify{
    return cell_identify;
}

-(void)cellInitDataForName:(NSString *_Nullable)strName
                    AndPic:(NSString *_Nullable)strPicurl{
    
    //图像赋值
    if (strPicurl.checkTextEmpty) {
        if ([strPicurl hasPrefix:@"http"]) {
            [_imgPic sd_setImageWithURL:strPicurl.mj_url placeholderImage:K_DEFAULT_USER_PIC];
        }
        else{
            _imgPic.image = [UIImage imageNamed:strPicurl];
        }
    }
    else{
        _imgPic.image = K_DEFAULT_USER_PIC;
    }
    [_imgPic wyh_autoSetImageCornerRedius:3 ConrnerType:UIRectCornerAllCorners];
    
    //标题
    _labTitle.text = strName;
}

-(void)setRightBadgeForNO:(NSInteger)intNO{
    if (intNO <= 0) {
        self.labNO.hidden = YES;
    }
    else{
       self.labNO.text = [NSString stringWithFormat:@"%ld",intNO];
       self.labNO.hidden = NO;
    }
}


//MARK: - lazy load
- (UIImageView *)imgPic{
    if (!_imgPic) {
  
        CGFloat w = 36;
        CGFloat h = 36;
        CGFloat y = (cell_height - h) * 0.5;
        _imgPic = [[UIImageView alloc]initWithFrame:CGRectMake(16, y, w, h)];
//        _imgPic = [BaseUIView createImage:CGRectMake(16, y, w, h)
//                                AndImage:K_DEFAULT_USER_PIC
//                      AndBackgroundColor:nil
//                               AndRadius:YES
//                             WithCorners:3];
    }
    return _imgPic;
}

- (UILabel *)labTitle{
    if (!_labTitle) {
        CGFloat h = 21;
        CGFloat x = _imgPic.width + _imgPic.x + 11;
        CGFloat y = (cell_height - h) * 0.5;
        _labTitle = [BaseUIView createLable:CGRectMake(x, y, 120, h)
                                   AndText:nil
                              AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                AndTxtFont:FONT(13)
                        AndBackgroundColor:nil];
        _labTitle.textAlignment = NSTextAlignmentLeft;
    }
    return _labTitle;
}

- (UILabel *)labNO{
    if (!_labNO) {
        CGFloat w = 40;
        CGFloat h = 21;
        CGFloat x = G_SCREEN_WIDTH - w - 16;
        CGFloat y = (cell_height - h) * 0.5;
        _labNO = [BaseUIView createLable:CGRectMake(x, y, w, h)
                                 AndText:@""
                            AndTextColor:[UIColor whiteColor]
                              AndTxtFont:FONT(11)
                      AndBackgroundColor:[UIColor colorWithHexString:@"#ff544b"]];
        
        _labNO.textAlignment = NSTextAlignmentCenter;
        _labNO.layer.cornerRadius = h * 0.5;
        _labNO.layer.masksToBounds = YES;
        _labNO.hidden = YES;
    }
    return _labNO;
}
@end
