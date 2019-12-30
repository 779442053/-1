//
//  ZWAddFriendViewController.m
//  EasyIM
//
//  Created by step_zhang on 2019/12/5.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWAddFriendViewController.h"
//手机通讯录
#import "AddressBookViewController.h"
/** 通讯录 */
#import <Contacts/Contacts.h>
//工具栏
#import "MMTools.h"
//相册
#import <Photos/Photos.h>
#import "SweepViewController.h"
#import "QRCodeViewController.h"
#import "ZWAddFriendViewModel.h"

#import "SearchFriendsViewController.h"
@interface ZWAddFriendViewController ()<UISearchBarDelegate,SweepViewControllerDelegate>
@property (nonatomic,strong) UIButton *searchBar;//搜索框
@property (nonatomic,strong) UIButton *myCoderBtn;
@property (nonatomic,strong) UIView *contactbtn;
@property (nonatomic,strong) UIView *ScanBtn;
@property (nonatomic,strong) NSMutableArray *dataScoure;
@property(nonatomic,strong)ZWAddFriendViewModel *ViewModel;
@end
@implementation ZWAddFriendViewController
- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)zw_bindViewModel{
    UITapGestureRecognizer *Contacttap = [[UITapGestureRecognizer alloc] init];
    [[Contacttap rac_gestureSignal] subscribeNext:^(id x) {
        ZWWLog(@"手机通讯录")
        if([CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusRestricted || [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts] == CNAuthorizationStatusDenied){
            [MMProgressHUD showHUD:@"请开启通讯录访问权限"];
            [MMTools openSetting];
        }
        else{
            //获取通讯录数据
            [self getAddressData];
            AddressBookViewController *vc = [[AddressBookViewController alloc] init];
            vc.arrAddressData = self.dataScoure;
            vc.addFriendFinishBack = ^{
                ZWWLog(@"拿到通讯录里面的好友,进行添加好友请求")
            };
            [self.navigationController pushViewController:vc animated:YES];
        }
    }];
    [self.contactbtn addGestureRecognizer:Contacttap];
    
    UITapGestureRecognizer *scantap = [[UITapGestureRecognizer alloc] init];
    [[scantap rac_gestureSignal] subscribeNext:^(id x) {
        ZWWLog(@"扫一扫")
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status != PHAuthorizationStatusAuthorized) {
                NSLog(@"开启权限设置");
                [MMTools openSetting];
                return;
            }
        }];
        SweepViewController *sweepVC = [[SweepViewController alloc] init];
        sweepVC.delegate = (id<SweepViewControllerDelegate>)self;
        [self presentViewController:sweepVC animated:YES completion:nil];
    }];
    [self.ScanBtn addGestureRecognizer:scantap];
    
    [[self.myCoderBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        ZWWLog(@"我的二维码")
        QRCodeViewController *codeVC = [[QRCodeViewController alloc]
        initWithType:0
        AndFromId:[ZWUserModel currentUser].userId
        AndFromName:[ZWUserModel currentUser].nickName
        WithFromPic:[ZWUserModel currentUser].photoUrl];;
        
        [self.navigationController pushViewController:codeVC animated:YES];
    }];
    
    [[self.searchBar rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        SearchFriendsViewController *vc  = [[SearchFriendsViewController alloc] init];
        vc.item = self.item;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}
-(void)sweepViewDidFinishSuccess:(id)sweepResult
{
    NSString *strInfo = [NSString stringWithFormat:@"%@",sweepResult];
    ZWWLog(@"扫描成功，详见：%@",sweepResult);
    NSArray *arrTemp = [strInfo componentsSeparatedByString:@"://"];
    NSString *strId = [NSString stringWithFormat:@"%@",arrTemp.lastObject];
    if (!strId.checkTextEmpty) {
        [MMProgressHUD showHUD:@"信息不存在"];
        return;
    }
    //MARK:扫码添加用户
    if ([strInfo containsString:K_APP_QRCODE_USER]) {
        if ([strId isEqualToString:[ZWUserModel currentUser].userId]) {
            [MMProgressHUD showHUD:@"不能添加自己为好友"];
            return;
        }
        [[self.ViewModel.addFriendCommand execute:strId] subscribeNext:^(id  _Nullable x) {
            if ([x[@"code"] intValue] == 0) {
                [MMProgressHUD showHUD: @"请求成功"];
            }
        }];
    }
    //MARK:扫码加群
    else if([strInfo containsString:K_APP_QRCODE_GROUP]){
        [MMRequestManager inviteFrd2GroupWithGroupId:strId
                                            friendId:[ZWUserModel currentUser].userId
                                         aCompletion:^(NSDictionary * _Nonnull dic, NSError * _Nonnull error) {
                                             if (K_APP_REQUEST_OK(dic[K_APP_REQUEST_CODE])) {
                                                 [MMProgressHUD showHUD:@"入群申请发送成功"];
                                             }else{
                                                 [MMProgressHUD showHUD:error?MMDescriptionForError(error):dic[K_APP_REQUEST_MSG]];
                                             }
                                         }];
    }
}

-(void)sweepViewDidFinishError
{
    MMLog(@"扫描失败");
}
-(void)zw_addSubviews{
    if (self.item == MMConGroup_Group) {
        [self setTitle:@"添加群"];
    }else{
        [self setTitle:@"添加好友"];
    }
    [self showLeftBackButton];
    
    UIView *searchView = [[UIView alloc]init];
    searchView.frame = CGRectMake(0, 15+ZWStatusAndNavHeight, KScreenWidth, 50);
    searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:searchView];
    [searchView addSubview:self.searchBar];
    UIImageView *rightImageView = [[UIImageView alloc]init];
    rightImageView.image = [UIImage imageNamed:@"addfriendSearch"];
    rightImageView.frame = CGRectMake(14, 15, 14, 14);
    [searchView addSubview:rightImageView];
    rightImageView.userInteractionEnabled = YES;
    
    UILabel *telelb = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(rightImageView.frame) + 15, 15, 160, 13)];
    telelb.userInteractionEnabled = YES;
    telelb.font = [UIFont zwwNormalFont:13];
    if (self.item == MMConGroup_Group) {
        telelb.text = @"请输入群号/群名称";
    }else{
        telelb.text = @"请输入好友账号/手机号";
    }
    telelb.textColor = [UIColor colorWithHexString:@"#BBBBBB"];
    [searchView addSubview:telelb];
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(12, CGRectGetMaxY(rightImageView.frame) + 7, KScreenWidth - 24, 1)];
    lineView1.backgroundColor = [UIColor colorWithHexString:@"#DCDCDC"];
    lineView1.userInteractionEnabled = YES;
    [searchView addSubview:lineView1];
    
    
    UIButton *qrcodeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    qrcodeBtn.frame = CGRectMake((KScreenWidth - 100)*0.5, CGRectGetMaxY(searchView.frame) + 10, 100, 15);
    [qrcodeBtn setImage:[UIImage imageNamed:@"addFriendQrcodeImage"] forState:UIControlStateNormal];
    [qrcodeBtn setImgViewStyle:ButtonImgViewStyleRight imageSize:CGSizeMake(15, 15) space:10];
    [qrcodeBtn setTitle:@"我的二维码" forState:UIControlStateNormal];
    [qrcodeBtn setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:UIControlStateNormal];
    qrcodeBtn.titleLabel.font = [UIFont zwwNormalFont:12];
    self.myCoderBtn = qrcodeBtn;
    [self.view addSubview:qrcodeBtn];
    
    UIView *bottomView = [[UIView alloc]init];
    bottomView.backgroundColor = [UIColor whiteColor];
    bottomView.frame = CGRectMake(0, CGRectGetMaxY(searchView.frame) + 52, KScreenWidth, 120);
    [self.view addSubview:bottomView];
    
    UIView *contactView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 59.5)];
    contactView.backgroundColor = [UIColor whiteColor];
    self.contactbtn = contactView;
    [bottomView addSubview:contactView];
    UIImageView *leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 36, 36)];
    leftImageView.userInteractionEnabled = YES;
    
    leftImageView.image = [UIImage imageNamed:@"addfriendContact"];
    [contactView addSubview:leftImageView];
    
    UILabel *topLB = [[UILabel alloc]initWithFrame:CGRectMake(60, 12, 200, 12)];
    topLB.text = @"手机通讯录匹配";
    topLB.font = [UIFont zwwNormalFont:13];
    topLB.textColor = [UIColor colorWithHexString:@"#000000"];
    [contactView addSubview:topLB];
    topLB.userInteractionEnabled = YES;
    UILabel *bottomLb = [[UILabel alloc]initWithFrame:CGRectMake(60, 12 +8 + 12 , 250, 12)];
    bottomLb.text = @"匹配手机通讯录中的朋友";
    bottomLb.font = [UIFont zwwNormalFont:12];
    bottomLb.userInteractionEnabled = YES;
    bottomLb.textColor = [UIColor colorWithHexString:@"#BBBBBB"];
    [contactView addSubview:bottomLb];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(12, CGRectGetMaxY(contactView.frame), KScreenWidth - 24, 1)];
    lineView.backgroundColor = [UIColor colorWithHexString:@"#DCDCDC"];
    [bottomView addSubview:lineView];
    
    UIView *contactView1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame), KScreenWidth, 59.5)];
    contactView1.backgroundColor = [UIColor whiteColor];
    contactView1.userInteractionEnabled = YES;
    self.ScanBtn = contactView1;
    [bottomView addSubview:contactView1];
    UIImageView *leftImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 12, 36, 36)];
    leftImageView1.userInteractionEnabled = YES;
    leftImageView1.image = [UIImage imageNamed:@"addfriendScan"];
    [contactView1 addSubview:leftImageView1];
    
    UILabel *topLB1 = [[UILabel alloc]initWithFrame:CGRectMake(60, 12, 200, 12)];
    topLB1.text = @"扫一扫";
    topLB1.font = [UIFont zwwNormalFont:13];
    topLB1.textColor = [UIColor colorWithHexString:@"#000000"];
    topLB1.userInteractionEnabled = YES;
    [contactView1 addSubview:topLB1];
    UILabel *bottomLb1 = [[UILabel alloc]initWithFrame:CGRectMake(60, 12 +8 + 12 , 250, 12)];
    bottomLb1.userInteractionEnabled = YES;
    bottomLb1.text = @"扫描好友的二维码";
    bottomLb1.font = [UIFont zwwNormalFont:12];
    bottomLb1.textColor = [UIColor colorWithHexString:@"#BBBBBB"];
    [contactView1 addSubview:bottomLb1];

}
//MARK: - 获取通讯录数据
-(void)getAddressData{
    //防止重复操作
    if (!self.dataScoure || [self.dataScoure count] <= 0) {
        //获取指定的字段,并不是要获取所有字段，需要指定具体的字段
        NSArray *keysToFetch = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
        CNContactFetchRequest *fetchRequest = [[CNContactFetchRequest alloc] initWithKeysToFetch:keysToFetch];
        CNContactStore *contactStore = [[CNContactStore alloc] init];
        
        [contactStore enumerateContactsWithFetchRequest:fetchRequest error:nil usingBlock:^(CNContact * _Nonnull contact, BOOL * _Nonnull stop) {
            NSMutableDictionary *myDict = [[NSMutableDictionary alloc] init];
            NSString *givenName = contact.givenName;
            NSString *familyName = contact.familyName;
            NSLog(@"givenName=%@, familyName=%@", givenName, familyName);
            
            NSString *nameStr = [NSString stringWithFormat:@"%@%@",contact.familyName,contact.givenName];
            if (!nameStr) { nameStr = @"";}
            NSArray *phoneNumbers = contact.phoneNumbers;
            [myDict setObject:nameStr forKey:@"aName"];
            
            BOOL isTel = NO;
            for (CNLabeledValue *labelValue in phoneNumbers) {
                NSString *label = labelValue.label;
                phoneNumbers = labelValue.value;
                CNPhoneNumber *phoneNumber = labelValue.value;
                NSLog(@"label=%@ 电话:%@\n", label,phoneNumber.stringValue);
                
                [myDict setObject:phoneNumber.stringValue forKey:@"cellphone"];
                
                isTel = YES;
            }
            
            if (isTel == NO) {[myDict setObject:@"" forKey:@"cellphone"];}
            
            if (!self.dataScoure) {
                self.dataScoure = [NSMutableArray array];
            }
            [self.dataScoure addObject:myDict];
        }];
    }
    
    //电话去重
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary<NSString *,id> * bindings) {
        NSInteger i = 0;
        NSString *strPhone = [NSString stringWithFormat:@"%@",[evaluatedObject valueForKey:@"cellphone"]];
        
        if (self.dataScoure && [self.dataScoure count] > 0) {
            i = 0;
            
            for (NSDictionary *object in self.dataScoure) {
                if([[object valueForKey:@"cellphone"] isEqualToString:strPhone]){
                    i++;
                }
            }
            
            return i > 1?NO:YES;
        }
        else{
            return NO;
        }
        
        return YES;
    }];
    
    NSArray *arrTemp = [self.dataScoure filteredArrayUsingPredicate:predicate];
    self.dataScoure = [NSMutableArray arrayWithArray:arrTemp];
    
    //NSLog(@"通讯录条数:%zd",self.dataScoure.count);
}
- (UIButton *)searchBar{
    if (!_searchBar) {
        _searchBar=[UIButton buttonWithType:UIButtonTypeSystem];
        _searchBar.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
        _searchBar.backgroundColor = [UIColor whiteColor];
    }
    return _searchBar;
}

@end
