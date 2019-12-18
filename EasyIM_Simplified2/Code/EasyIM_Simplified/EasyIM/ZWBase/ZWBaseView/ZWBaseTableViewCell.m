//
//  ZWBaseTableViewCell.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseTableViewCell.h"
#import "UIColor+ZWColor.h"
#import "UIFont+ZWFont.h"
@implementation ZWBaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self zw_setupViews];
        [self zw_bindViewModel];
    }
    return self;
}

- (void)zw_setupViews{}

- (void)zw_bindViewModel{}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
