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
#import "ZWGroudDetailViewModel.h"

@interface GroupCompleteViewController()<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDataDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *logoBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTextF;
@property (nonatomic, strong) NSMutableData *data;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TopPadding;
@property (nonatomic, strong) ZWGroudDetailViewModel     *ViewModel;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) NSString *filePath;
@property(nonatomic,copy)NSString *HeadImageUrl;
@end

@implementation GroupCompleteViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_addSubviews{
    [self setTitle:@"新建群组"];
    [self showLeftBackButton];
    self.TopPadding.constant = ZWStatusAndNavHeight;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(KScreenWidth - 44 - 20, ZWStatusBarHeight, 44, 44);
    [button setTitle:@"完成" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#01A1EF"] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont zwwNormalFont:13];
    [self.navigationView addSubview:button];
    [self.tableView registerClass:[NewGroupViewCell class] forCellReuseIdentifier:@"NewGroupViewCell"];
}
- (void)rightAction {
    if ([_nameTextF.text isEqualToString:@""] ||_nameTextF.text.length == 0 ) {
        [MBProgressHUD showError:@"群组名称不能为空！"];
        return;
    }
    NSString *userIDs = [self.userIdArr componentsJoinedByString:@","];
    //开始发送请求
    NSMutableDictionary *parma = [[NSMutableDictionary alloc]init];
    parma[@"name"] = self.nameTextF.text;
    parma[@"photoUrl"] = self.HeadImageUrl;
    parma[@"friendID"] = userIDs;
    [[self.ViewModel.creatGroupCommand execute:parma] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            [self delayAction];
        }
    }];

}
- (void)delayAction
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.memberArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
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
    cell.selBtn.hidden = YES;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(ZWGroudDetailViewModel *)ViewModel{
    if (_ViewModel == nil) {
        _ViewModel = [[ZWGroudDetailViewModel alloc]init];
    }
    return _ViewModel;
}
- (IBAction)LogoImageBtnClick:(UIButton *)sender {
    __block typeof(self) weakSelf = self;
    [BaseUIView createPhotosAndCameraPickerForMessage:@"请选择图片来源"
                                   andAlertController:^(UIAlertController * _Nullable _alertVC) {
                                       [weakSelf presentViewController:_alertVC animated:YES completion:nil];
                                   }
                        withImagePickerController:^(UIImagePickerController * _Nullable _imgPickerVC) {
                                _imgPickerVC.delegate = self;
                                [weakSelf presentViewController:_imgPickerVC animated:YES completion:nil];
                            }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *simpleImg = [UIImage simpleImage:orgImage];
    [self sendFileWithFilePath:simpleImg];
}
- (void)sendFileWithFilePath:(UIImage *)filePath
{
    [YJProgressHUD showLoading:@"照片上传中..."];
    [[self.ViewModel.UploadImageToSeverCommand execute:@{@"code":@"image",@"res":filePath}] subscribeNext:^(id  _Nullable x) {
        if ([x[@"code"] intValue] == 0) {
            self.HeadImageUrl = x[@"res"];
            NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.HeadImageUrl]];
            UIImage *image = [[UIImage alloc]initWithData:imageData];
            [self.logoBtn setImage:image forState:UIControlStateNormal];
            [YJProgressHUD showSuccess:@"图片上传成功"];
        }
    }];
}
@end
