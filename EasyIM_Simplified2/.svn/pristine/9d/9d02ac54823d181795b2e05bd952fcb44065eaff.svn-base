//
//  NewGroupViewCell.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/28.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "NewGroupViewCell.h"

@implementation NewGroupViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.logoImage setLayerBorderWidth:0 borderColor:nil cornerRadius:self.logoImage.width/2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickSelBtn:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectCellWithSelectText:isSelect:indexPath:)]) {
        [self.delegate selectCellWithSelectText:self.name.text
                                       isSelect:sender.isSelected
                                      indexPath:self.indexPath];
    }
}

@end
