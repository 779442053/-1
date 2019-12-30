//
//  MMFriendAppViewController.m
//  EasyIM
//
//  Created by momo on 2019/5/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMFriendAppViewController.h"
#import "NewFriendCell.h"
#import "MMButton.h"

@interface MMFriendAppViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation MMFriendAppViewController
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, SCREEN_WIDTH, SCREEN_HEIGHT - ZWStatusAndNavHeight) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"详细资料"];
    [self.view addSubview:self.tableView];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            NewFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"clnf"];
            if (!cell) {
                cell = [[NewFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"clnf"];
//                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            cell.certainBtn.hidden = YES;
            cell.nickNameLabel.text = _model.fromNick.length ? _model.fromNick: _model.fromName;
            cell.infoLabel.text = [NSString stringWithFormat:@"账号:%@",_model.fromName];//_model.fromName;
            [cell.headerImgView sd_setImageWithURL:[NSURL URLWithString:_model.fromPhoto] placeholderImage:[UIImage imageNamed:@"setting_default_icon"]];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
            break;
        case 1:case 2:
        {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"clng"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            if (indexPath.row == 1) {
//                cell.textLabel.text = _model.fromNick.length ? _model.fromNick: _model.fromName;
                cell.textLabel.text = @"附加信息";
                cell.detailTextLabel.text  = [_model.msg stringByRemovingPercentEncoding];
            }else{
                cell.textLabel.text = @"来自";
                cell.detailTextLabel.text  = @"搜索";
            }
            return cell;
        }
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH, 8)];
    [sectionView setBackgroundColor:MMColor(234, 237, 244)];
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 8;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    switch (_model.bulletinType) {
        case 0:
        {
            UIView *sectionFoot = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
            UIButton *refuseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
            [refuseBtn addTarget:self action:@selector(refuseAction:) forControlEvents:UIControlEventTouchUpInside];
            [refuseBtn setBackgroundColor:MMColor(234, 237, 244)];
            [refuseBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [sectionFoot addSubview:refuseBtn];
            
            UIButton *agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
            [agreeBtn addTarget:self action:@selector(agreeAction:) forControlEvents:UIControlEventTouchUpInside];
            [agreeBtn setBackgroundColor:MMColor(0, 205, 248)];
            [agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [sectionFoot addSubview:agreeBtn];
            
            CGFloat padding = 15;
            CGFloat width = (SCREEN_WIDTH/2)-padding-4 ;
            refuseBtn.frame = CGRectMake(padding, padding, width, 50);
            agreeBtn.frame = CGRectMake(CGRectGetMaxX(refuseBtn.frame)+8, padding, width, 50);
            
            [agreeBtn.layer setMasksToBounds:YES];
            [agreeBtn.layer setCornerRadius:5];
            
            [refuseBtn.layer setMasksToBounds:YES];
            [refuseBtn.layer setCornerRadius:5];
            
            return sectionFoot;
        }
            break;
        case 1:case 2:case 3:case 4:case 5:
        {
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
            [tipLabel setTextColor:[UIColor lightGrayColor]];
            [tipLabel setFont:[UIFont systemFontOfSize:13]];
            [tipLabel setTextAlignment:NSTextAlignmentCenter];
            if (_model.bulletinType == 1) {
                [tipLabel setText:@"已同意申请"];
            }else if (_model.bulletinType == 2){
                [tipLabel setText:@"已拒绝申请"];
            }else if (_model.bulletinType == 3){
                [tipLabel setText:@"对方已同意"];
            }else if (_model.bulletinType == 4){
                [tipLabel setText:@"对方已拒绝"];
            }else if (_model.bulletinType == 5){
                [tipLabel setText:@"对方已删除"];
            }
            return tipLabel;
        }
        default:
            break;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    switch (_model.bulletinType) {
        case 0:
            return 80.0f;
            break;
        case 1:case 2:case 3:case 4:case 5:
            return 30.0f;
            break;
        default:
            return 0.0f;
            break;
    }
    return 0.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            return 76.0f;
            break;
        case 1:case 2:
            return 50.0f;
        default:
            return 0.0f;
            break;
    }
    return 0.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void)agreeAction:(UIButton *)sender
{
//    WEAKSELF
//    if ([self.delegate respondsToSelector:@selector(acceptRquestWithType:aComption:)]) {
//        [self.delegate acceptRquestWithType:MMFAppAccept aComption:^(id  _Nullable data, NSError * _Nullable error) {
//            _model.bulletinType = @"1";
//            [weakSelf.tableView reloadData];
//        }];
//    }
}

- (void)refuseAction:(UIButton *)sender
{
//    WEAKSELF
//    if ([self.delegate respondsToSelector:@selector(rejectRequestWithType:aComption:)]) {
//        [self.delegate rejectRequestWithType:MMFAppRes aComption:^(id  _Nullable data, NSError * _Nullable error) {
//            _model.bulletinType = @"2";
//            [weakSelf.tableView reloadData];
//        }];
//    }
}

@end
