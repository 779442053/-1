//
//  MMEditGroupViewController.m
//  EasyIM
//
//  Created by momo on 2019/6/2.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMEditGroupViewController.h"
#import "FriendInfoViewController.h"
#import "MMEditGroupCell.h"
#import "GroupMemberModel.h"
#import "ZWGroudDetailViewModel.h"
@interface MMEditGroupViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView     *tableView;         //表格
@property (nonatomic, strong) NSMutableArray  *creatorData;       //数据源
@property (nonatomic, strong) ZWGroudDetailViewModel     *ViewModel;
@end
@implementation MMEditGroupViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"群聊成员"];
    [self showLeftBackButton];
    [self.view addSubview:self.tableView];
}
-(void)zw_bindViewModel{
    [self.dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MemberList *member = self.dataSource[idx];
        if ([member.memberId isEqualToString:self.creatorId]) {
            [self.creatorData addObject:member];
            [self.dataSource removeObject:member];
            [self.tableView reloadData];
        }
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.creatorData.count;
            break;
        case 1:
            return self.dataSource.count;
            break;
        default:
            break;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIde = @"MMEditGroupCell";
    MMEditGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell==nil) {
        cell = [[MMEditGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MMEditGroupCell"];
    }
    MemberList *model;
    if (indexPath.section == 0) {
        model = self.creatorData[indexPath.row];
    }else{
        model = self.dataSource[indexPath.row];
    }
    [cell.headImage sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:K_DEFAULT_USER_PIC];
    [cell.nameLbl setText:model.username];
    return cell;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headSection = [[UIView alloc] init];
    headSection.backgroundColor = MMColor(242, 242, 242);
    UILabel *sectionLbl = [[UILabel alloc] init];
    if(section == 0){
        sectionLbl.text = @"群主";
    }else{
        sectionLbl.text = @"群成员";
    }
    sectionLbl.frame = CGRectMake(15, 0, 80, 30);
    sectionLbl.font = [UIFont systemFontOfSize:15];
    sectionLbl.textColor = [UIColor blackColor];
    [headSection addSubview:sectionLbl];
    return headSection;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    return NO;
}
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        //设置删除按钮
        UITableViewRowAction * deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"移除群组" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self deleteFriend:indexPath];
        }];
        return @[deleteRowAction];
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section !=0 ) {
        MemberList *model = self.dataSource[indexPath.row];
        FriendInfoViewController *friend = [[FriendInfoViewController alloc] init];
        friend.userId = model.memberId;
        friend.isFriend = NO;
        [self.navigationController pushViewController:friend animated:YES];
    }
}
#pragma mark - 移除群组
- (void)deleteFriend:(NSIndexPath *)indexPath
{
    //判断当前身份,群主才能踢人
    NSString *userID = [ZWUserModel currentUser].userId;
    if (!self.creatorId.checkTextEmpty || ![self.creatorId isEqualToString:userID]) {
        [MMProgressHUD showHUD:@"非群主无法踢人"];
        return;
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否移除" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"移除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        MemberList *member = self.dataSource[indexPath.row];
        //开始踢人
        [[self.ViewModel.kickPeopleFromGroupCommand execute:@{@"groupID":self.groupId,@"memberID":member.memberId}] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
        }];
        
    }];
    UIAlertAction *cancerAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [alertController addAction:deleteAction];
    [alertController addAction:cancerAction];
    [self.navigationController  presentViewController:alertController animated:YES completion:nil];

}
- (UITableView *)tableView
{
    if (!_tableView) {
        CGFloat h = SCREEN_HEIGHT - ZWStatusAndNavHeight - (ISIphoneX?ZWTabbarSafeBottomMargin:0);
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, SCREEN_WIDTH, h) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = G_EEF0F3_COLOR;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = MMColor(242, 242, 242);
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[MMEditGroupCell class] forCellReuseIdentifier:@"MMEditGroupCell"];
    }
    return _tableView;
}
- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}
- (NSMutableArray *)creatorData
{
    if (!_creatorData) {
        _creatorData = [[NSMutableArray alloc] init];
    }
    return _creatorData;
}
-(ZWGroudDetailViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWGroudDetailViewModel alloc]init];
    }
    return _ViewModel;
}
@end
