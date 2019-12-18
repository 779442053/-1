//
//  YKHorizontalSelectView.m
//  auction
//
//  Created by 源库 on 2017/4/14.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "YKHorizontalSelectView.h"
#import "HorizontalSelectCollectionViewCell.h"

@interface YKHorizontalSelectView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation YKHorizontalSelectView

static NSString *const collectionViewCellID = @"HorizontalSelectCollectionViewCell";

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = 0;
        _lineWidth = 40;
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:frame collectionViewLayout:layout];
        [collectionView registerClass:[HorizontalSelectCollectionViewCell class] forCellWithReuseIdentifier:collectionViewCellID];
        collectionView.delegate        = self;
        collectionView.dataSource      = self;
        collectionView.backgroundColor = [UIColor whiteColor];
        [self addSubview:collectionView];
        _collectionView = collectionView;
    }
    return self;
}

- (void)initLineViewWithNumber:(NSInteger)number {
    if (!_lineView) {
        UIView *lineView = [UIView new];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#007bf3"];
        float originX = self.frame.size.width/number/2-_lineWidth/2;
        lineView.frame = CGRectMake(originX, self.frame.size.height-2, _lineWidth, 2);
        [self addSubview:lineView];
        _lineView = lineView;
    }
}

#pragma mark ==================== UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger number = [self.dataSource numberOfItemsInSelectView:self];
    [self initLineViewWithNumber:number];
    return number;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HorizontalSelectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionViewCellID forIndexPath:indexPath];
    UIColor *textColor = [UIColor colorWithHexString:@"3d4245"];
    if (_textColor) textColor = _textColor;
    if (_textfont) cell.button.titleLabel.font = [UIFont systemFontOfSize:_textfont];
    
    [cell.button setTitle:[self.dataSource selectView:self titleForItemWithIndex:indexPath.item] forState:UIControlStateNormal];
    [cell.button setTitleColor:(_selectIndex == indexPath.item)?[UIColor colorWithHexString:@"#007bf3"]:textColor forState:UIControlStateNormal];
    
    if (_selectIndex == indexPath.item) {
        if ([self.dataSource respondsToSelector:@selector(selectView:iconSelectedForItemWithIndex:)]) {
            [cell.button setImage:[UIImage imageNamed:[self.dataSource selectView:self iconSelectedForItemWithIndex:indexPath.item]] forState:UIControlStateNormal];
        }
    } else {
        if ([self.dataSource respondsToSelector:@selector(selectView:iconForItemWithIndex:)]) {
            [cell.button setImage:[UIImage imageNamed:[self.dataSource selectView:self iconForItemWithIndex:indexPath.item]] forState:UIControlStateNormal];
        }
    }

    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (_delegate && [_delegate respondsToSelector:@selector(selectView:shouldSelectWithIndex:)]) {
        return [_delegate selectView:self shouldSelectWithIndex:indexPath.item];
    }
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _selectIndex = indexPath.item;
    [collectionView reloadData];
    [UIView animateWithDuration:0.2 animations:^{
        float originX = self.frame.size.width/[self.dataSource numberOfItemsInSelectView:self]/2*(indexPath.item*2+1)-_lineWidth/2;
        _lineView.frame = CGRectMake(originX, self.frame.size.height-2, _lineWidth, 2);
    }];
    if (_delegate && [_delegate respondsToSelector:@selector(selectView:didSelectWithIndex:)]) {
        [_delegate selectView:self didSelectWithIndex:indexPath.item];
    }
}

#pragma mark ==================== UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bounds.size.width/(float)[self.dataSource numberOfItemsInSelectView:self],self.bounds.size.height);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (void)setSelectIndex:(NSInteger)selectIndex {
    _selectIndex = selectIndex;
    [_collectionView reloadData];
    [self initLineViewWithNumber:selectIndex];
    [UIView animateWithDuration:0.2 animations:^{
        float originX = self.frame.size.width/[self.dataSource numberOfItemsInSelectView:self]/2*(_selectIndex*2+1)-_lineWidth/2;
        _lineView.frame = CGRectMake(originX, self.frame.size.height-2, _lineWidth, 2);
    }];
}

- (void)setTextfont:(NSInteger)textfont {
    _textfont = textfont;
    [_collectionView reloadData];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [_collectionView reloadData];
}

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    [UIView animateWithDuration:0.2 animations:^{
        float originX = self.frame.size.width/[self.dataSource numberOfItemsInSelectView:self]/2*(_selectIndex*2+1)-_lineWidth/2;
        _lineView.frame = CGRectMake(originX, self.frame.size.height-2, _lineWidth, 2);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
