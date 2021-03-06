//
//  MM1v1AudioViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/8.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MM1v1AudioViewController.h"
#import "BaseUIView.h"

static CGFloat const margin_top = 100;
static CGFloat const margin_row_column = 15;
static CGFloat const collection_list_h = 161;

static CGFloat const collection_cell_h = 73;
static CGFloat const collection_cell_w = 65;

static NSString *const cell_identify = @"collection_cell_identify";

#define k_cell_default_img [UIImage imageNamed:@"App_emp_headimg"]
#define k_collection_left_right ((G_SCREEN_WIDTH - 4 * collection_cell_w - 3 * margin_row_column) * 0.5)

@interface MM1v1AudioViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *collectionList;
@end

@implementation MM1v1AudioViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupSubviews];
}


#pragma mark - Subviews

- (void)setupSubviews
{
    //MARK:背景
    self.view.backgroundColor = [UIColor colorWithHexString:@"333333"];
    
    CGFloat size = 50;
    CGFloat padding = ([UIScreen mainScreen].bounds.size.width - size * 2) / 3;
    [self.microphoneButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(padding);
        make.bottom.equalTo(self.hangupButton.mas_top).offset(-40);
        make.width.height.mas_equalTo(size);
    }];
    
    [self.speakerButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-padding);
        make.bottom.equalTo(self.microphoneButton);
        make.width.height.mas_equalTo(size);
    }];
 
    //MARK:用户列表
    [self.view addSubview:self.collectionList];
}


//MARK: - UICollectionView 组头设置
//组头尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeZero;
}

//组尾部尺寸
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeZero;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


//MARK: - UICollectionViewDelegate,UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.arrUserDatas)
        return [self.arrUserDatas count];
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cell_identify forIndexPath:indexPath];
    
    //MARK:图像
    NSInteger tag = 1234;
    UIImageView *imgPic = (UIImageView *)[cell.contentView viewWithTag:tag];
    if (!imgPic) {
        CGFloat w = 52;
        CGFloat h = 52;
        CGFloat x = (collection_cell_w - w) * 0.5;
        imgPic = [BaseUIView createImage:CGRectMake(x, 0, w, h)
                                AndImage:k_cell_default_img
                      AndBackgroundColor:nil
                            WithisRadius:YES];
        
        imgPic.tag = tag;
        [cell.contentView addSubview:imgPic];
    }
    
    //MARK:用户名
    tag = 1235;
    UILabel *labUserName = (UILabel *)[cell.contentView viewWithTag:tag];
    if (!labUserName) {
        labUserName = [BaseUIView createLable:CGRectMake(0, collection_cell_h - 21, collection_cell_w, 21)
                                      AndText:@""
                                 AndTextColor:[UIColor whiteColor]
                                   AndTxtFont:FONT(10)
                           AndBackgroundColor:nil];
        
        labUserName.textAlignment = NSTextAlignmentCenter;
        labUserName.tag = tag;
        [cell.contentView addSubview:labUserName];
    }

    if (self.arrUserDatas && [self.arrUserDatas count] > indexPath.row) {
        NSDictionary *dicData = self.arrUserDatas[indexPath.row];
        
        //图像
        NSString *strInfo = [NSString stringWithFormat:@"%@",dicData[@"photoUrl"]];
        if (strInfo.checkTextEmpty)
            [imgPic sd_setImageWithURL:strInfo.mj_url placeholderImage:k_cell_default_img];
        else
            imgPic.image = k_cell_default_img;
        
        //用户名
        strInfo = [NSString stringWithFormat:@"%@",dicData[@"userName"]];
        if ([dicData[@"initiator"] boolValue] == YES) {
            strInfo = [NSString stringWithFormat:@"(发起人)%@",dicData[@"userName"]];
        }
        labUserName.text = strInfo;
    }
    
    return cell;
}


//MARK: - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.arrUserDatas && [self.arrUserDatas count] > indexPath.row) {
        return  CGSizeMake(collection_cell_w, collection_cell_h);
    }
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, k_collection_left_right, 0, k_collection_left_right);
}

//行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return margin_row_column;
}

//列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}


//MARK: - lazy load
-(UICollectionView *)collectionList{
    if (!_collectionList) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        CGFloat y = (ISIphoneX?44:20) + margin_top;
        _collectionList = [[UICollectionView alloc] initWithFrame:CGRectMake(0, y, G_SCREEN_WIDTH, collection_list_h) collectionViewLayout:layout];
        
        _collectionList.delegate = self;
        _collectionList.dataSource = self;
        
        _collectionList.backgroundColor = [UIColor clearColor];
        
        //注册
        [_collectionList registerClass:[UICollectionViewCell classForCoder] forCellWithReuseIdentifier:cell_identify];
    }
    return _collectionList;
}


@end
