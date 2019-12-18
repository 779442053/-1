//
//  GroupCompleteViewController.m
//  EasyIM
//
//  Created by 魏冰杰 on 2019/2/28.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "GroupCompleteViewController.h"
#import "UserFriendModel.h"
#import "NewGroupViewCell.h"

@interface GroupCompleteViewController()<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *logoBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTextF;
@property (nonatomic, strong) NSMutableData *data;
@end

@implementation GroupCompleteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}


#pragma mark -- init

- (void)initView
{
    [self setTitle:@"新建群组"];
    
    //[self addRightBtnWithImage:[UIImage imageNamed:@"newGroup_tick"]];
    
    //
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([NewGroupViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([NewGroupViewCell class])];
    
}

//
- (void)rightAction {
    
    if ([_nameTextF.text isEqualToString:@""]) {
        [MBProgressHUD showError:@"群组名称不能为空！"];
        return;
    }

    NSString *userIDs = [self.userIdArr componentsJoinedByString:@"|"];
    
    [MMRequestManager addGroupWithGroupName:_nameTextF.text bulletin:@"" theme:@"" photo:@"" userlist:userIDs aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
        if (!error) {
            if ([dic[@"ret"] isEqualToString:@"succ"]) {
                MMLog(@"%@",dic);
                [MMProgressHUD showHUD:dic[@"desc"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_RELOAD object:nil];
                [self performSelector:@selector(delayAction) withObject:nil afterDelay:1.0];
            }
        }else{
            [MMProgressHUD showHUD: MMDescriptionForError(error)];
        }
    }];
    

}

- (void)delayAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //viewforHeader
    id label = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"headerView"];
    if (!label) {
        label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14.5f]];
        [label setTextColor:[UIColor grayColor]];
        [label setBackgroundColor:[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1]];
    }
    [label setText:[NSString stringWithFormat:@"  %ld位成员",self.memberArray.count]];
    return label;
}


#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIde=@"NewGroupViewCell";
    NewGroupViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell==nil) {
        cell=[[NewGroupViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIde];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.userInteractionEnabled = NO;
    ContactsModel *model= self.memberArray[indexPath.row];
    
    [cell.name setText:model.nickName];
    [cell.logoImage sd_setImageWithURL:[NSURL URLWithString:model.photoUrl] placeholderImage:K_DEFAULT_USER_PIC];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}


@end
