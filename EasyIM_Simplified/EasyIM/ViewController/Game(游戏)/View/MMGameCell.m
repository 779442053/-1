//
//  MMGameCell.m
//  EasyIM
//
//  Created by momo on 2019/9/6.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMGameCell.h"

@interface MMGameCell ()

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, weak) id<MMGameDelegate> delegate;

@end

@implementation MMGameCell


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
    [self.contentView addSubview:self.iconImageView];
//    [self.contentView addSubview:self.enterGameBtn];
}

- (void)layoutSubviews
{
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(self.contentView);
    }];
    
//    [self.enterGameBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.contentView.mas_centerX);
//        make.centerY.mas_equalTo(self.contentView.mas_centerY);
//    }];
    
}

#pragma mark - Getter

- (UIImageView *)iconImageView
{
    if (!_iconImageView) {
        _iconImageView = [BaseUIView createImage:CGRectZero
                                        AndImage:[UIImage imageNamed:@""]
                              AndBackgroundColor:nil
                                       AndRadius:NO
                                     WithCorners:0
                          ];
    }
    return _iconImageView;
}

- (UIButton *)enterGameBtn
{
    if (!_enterGameBtn) {
        _enterGameBtn =  [BaseUIView createBtn:CGRectZero
                                      AndTitle:@"进入游戏"
                                 AndTitleColor:[UIColor whiteColor]
                                    AndTxtFont:FONT(15)
                                      AndImage:nil
                            AndbackgroundColor:[UIColor clearColor]
                                AndBorderColor:[UIColor grayColor]
                               AndCornerRadius:5
                                  WithIsRadius:YES
                           WithBackgroundImage:nil
                               WithBorderWidth:1
                          ];
        [_enterGameBtn addTarget:self action:@selector(enterGameAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _enterGameBtn;
}


- (void)setGameModel:(MMGameModel *)gameModel
{
    _gameModel = gameModel;
    [self.iconImageView setImage:[UIImage imageNamed:gameModel.iconImageStr]];
    [self.enterGameBtn setTitle:gameModel.name forState:UIControlStateNormal];
}

- (void)setDelegate:(id<MMGameDelegate>)delegate andIndexPath:(NSIndexPath *)indexPath
{
    _delegate = delegate;
    _indexPath = indexPath;
}

#pragma mark - Action

- (void)enterGameAction:(UIButton *)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(enterGameWithIndexPath:)]) {
        [self.delegate enterGameWithIndexPath:_indexPath];
    }
}

@end
