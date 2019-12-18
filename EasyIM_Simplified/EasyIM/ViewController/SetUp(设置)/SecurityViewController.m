//
//  SecurityViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/22.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "SecurityViewController.h"

//修改密码
#import "MMPwdModifyViewController.h"

static CGFloat const margin_left = 14;
static CGFloat const cell_height = 46;
static CGFloat const cell_section_height = 13;
static NSString *const cell_identify = @"security_cell_identify";

@interface SecurityViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong) UITableView *listTableView;
@property(nonatomic,strong) NSArray *arrListData;
@end

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"安全"];
    [self showLeftBackButton];
    [self.view addSubview:self.listTableView];
}

//MARK: -  UITableViewDataSource、UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.arrListData && [self.arrListData count] > 0) {
        return [self.arrListData count];
    }
    return 1;
}

//MARK:组头、组尾
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.arrListData && [self.arrListData count] > 0) {
        return cell_section_height;
    }
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (self.arrListData && [self.arrListData count] > 0) {
        UIView *_sectionHeadView = [BaseUIView createView:CGRectMake(0, 0, G_SCREEN_WIDTH, cell_section_height)
                                       AndBackgroundColor:G_EEF0F3_COLOR
                                              AndisRadius:NO
                                                AndRadiuc:0
                                           AndBorderWidth:0
                                           AndBorderColor:nil];
        return _sectionHeadView;
    }
    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

//MARK:表列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.arrListData && [self.arrListData count] > section) {
        return [[NSArray arrayWithArray:self.arrListData[section]] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_identify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_identify];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //MARK:标题
    NSInteger tag = 1235;
    UILabel *labTitle = (UILabel *)[cell.contentView viewWithTag:tag];
    if (!labTitle) {
        CGFloat h = 21;
        CGFloat y = (cell_height - h) * 0.5;
        labTitle = [BaseUIView createLable:CGRectMake(margin_left, y, 150, h)
                                   AndText:nil
                              AndTextColor:[UIColor colorWithHexString:@"#333333"]
                                AndTxtFont:[UIFont zwwNormalFont:13]
                        AndBackgroundColor:nil];
        labTitle.textAlignment = NSTextAlignmentLeft;
        
        labTitle.tag = tag;
        [cell.contentView addSubview:labTitle];
    }
    
    if (self.arrListData && [self.arrListData count] > indexPath.section) {
        NSArray *arrTemp = [NSArray arrayWithArray:self.arrListData[indexPath.section]];
        if (arrTemp && [arrTemp count] > indexPath.row) {
            
            //标题
            labTitle.text = [NSString stringWithFormat:@"%@",[arrTemp objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cell_height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.arrListData && [self.arrListData count] > indexPath.section) {
        switch (indexPath.section) {
            //MARK:更换手机号
            case 0:{
                [MMProgressHUD showHUD:@"更换手机号"];
            }
                break;
            //MARK:修改登录密码
            case 1:{
                if (indexPath.row == 0) {
                    MMPwdModifyViewController *vc = [[MMPwdModifyViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
                break;
            default:
                break;
        }
    }
}


//MARK: - lazy load
- (NSArray *)arrListData{
    if (!_arrListData) {
        _arrListData = @[
                         @[@"更换手机号"],
                         @[@"修改登录密码"]];
    }
    return _arrListData;
}

- (UITableView *)listTableView{
    if (!_listTableView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight;
        _listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, h)
                                                      style:UITableViewStylePlain];
        _listTableView.backgroundColor = [UIColor clearColor];
        
        //分割线
        _listTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _listTableView.separatorColor = G_EEF0F3_COLOR;
        
        //是否允许选中
        _listTableView.allowsSelection = YES;
        _listTableView.allowsMultipleSelection = NO;
        
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        
        _listTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
        _listTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
       
        //注册
        [_listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cell_identify];
    }
    return _listTableView;
}

@end
