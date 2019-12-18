//
//  MMBaseMessageCell.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <SDAutoLayout.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,CellLineStyle) {
    CellLineStyleDefault,
    CellLineStyleFill,
    CellLineStyleNone
};


@interface MMBaseMessageCell : UITableViewCell

/** 边界线 */
@property (nonatomic, assign) CellLineStyle bottomLineStyle;
@property (nonatomic, assign) CellLineStyle topLineStyle;

@property (nonatomic, assign) CGFloat leftFreeSpace; // 低线的左边距

@property (nonatomic, assign) CGFloat rightFreeSpace;

@property (nonatomic, weak) UIView *bottomLine;



@end

NS_ASSUME_NONNULL_END
