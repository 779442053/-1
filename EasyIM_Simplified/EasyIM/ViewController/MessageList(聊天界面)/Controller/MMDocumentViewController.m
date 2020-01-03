//
//  MMDocumentViewController.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMDocumentViewController.h"
#import "MMFileTool.h"
#import "MMDocumentCell.h"
#import "MMFileScanController.h"
#import "ZWiCloudManager.h"
#import "ZWMessage.h"
#import "YJProgressHUD.h"
@interface MMDocumentViewController ()<UITableViewDataSource,UITableViewDelegate,MMDocumentCellDelegate,UIDocumentPickerDelegate, UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) NSString *name;
@end
@implementation MMDocumentViewController
#pragma mark - Getter
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - ZWTabbarSafeBottomMargin) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        _tableView.firstReload = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
//    [self setupSubviews];
//    [self loadData];
    
    [self presentDocumentPicker];
}
- (void)presentDocumentPicker {
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code ", @"public.image", @"public.audiovisual-content", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    
    UIDocumentPickerViewController *documentPickerViewController = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes
                                                                                                                          inMode:UIDocumentPickerModeOpen];
    documentPickerViewController.delegate = self;
    documentPickerViewController.modalPresentationStyle = 0;
    [self presentViewController:documentPickerViewController animated:YES completion:nil];
}
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url{
    NSArray *array = [[url absoluteString] componentsSeparatedByString:@"/"];
    NSString *fileName = [array lastObject];
    fileName = [fileName stringByRemovingPercentEncoding];
    if ([ZWiCloudManager iCloudEnable]) {
        [ZWiCloudManager downloadWithDocumentURL:url callBack:^(id obj) {
            NSData *data = obj;
            //写入沙盒Documents
             NSString *path = [MMFileTool fileMainPath];
            [data writeToFile:path atomically:YES];
        }];
    }else{
        //[ZWMessage success:@"温馨提示" title:@"iCloud 不可用! 由于苹果的限制,你不得不去开发者中心申请当前bundleid 获取icloud 权限"];
        [YJProgressHUD showError:@"iCloud 不可用! 由于苹果的限制,需要配置开发者中心权限"];
    }
}
- (void)setupNav
{
    self.view.backgroundColor = [UIColor whiteColor];
    [self setTitle:@"选择文件"];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeSystem];
    leftButton.frame = CGRectMake(15, ZWStatusBarHeight + 5, 45, 35);
    [leftButton setTitle:@"取消" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    leftButton.titleLabel.font = [UIFont zwwNormalFont:17];
    [leftButton addTarget:self action:@selector(leftBarButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeSystem];
    rightButton.frame = CGRectMake(KScreenWidth - 15 - 45, ZWStatusBarHeight + 5, 45, 35);
    [rightButton setTitle:@"发送" forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightButton.titleLabel.font = [UIFont zwwNormalFont:17];
    [rightButton addTarget:self action:@selector(rightBarButtonClicked) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView addSubview:rightButton];
    
}
- (void)rightBarButtonClicked
{
    if (!self.name) return;
    if ([self.delegate respondsToSelector:@selector(selectedFileName:)]) {
        [self.delegate selectedFileName:self.name];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)leftBarButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)loadData
{
    NSDirectoryEnumerator * enumer = [[NSFileManager defaultManager] enumeratorAtPath:[MMFileTool fileMainPath]];
    ZWWLog(@"========%@",enumer)
    NSString *name;
    while (name = [enumer nextObject]) {
        if ([name isEqualToString:@".DS_Store"]) continue;
        if (![[name pathExtension] isEqualToString:@"DS_Store"]&&[name length]>0) {
            [self.dataArr addObject:name];
        }
    }
        ZWWLog(@"fileMainPath=======%@",[MMFileTool fileMainPath]);
}
#pragma mark - UI
- (void)setupSubviews
{
    [self.view addSubview:self.tableView];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMDocumentCell *cell = [MMDocumentCell cellWithTableView:tableView];
    cell.delegate = self;
    cell.name = self.dataArr[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MMDocumentCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    MMFileScanController *scanVC = [[MMFileScanController alloc] init];
    scanVC.filePath              = cell.filePath;
    scanVC.orgName               = cell.name;
    [self.navigationController pushViewController:scanVC animated:YES];
}

#pragma mark - ICDocumentCellDelegate

- (void)selectBtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    MMDocumentCell *cell = (MMDocumentCell *)[[button superview] superview];
    NSIndexPath *curIndexPath = [self.tableView indexPathForCell:cell];
    for (int row = 0; row < self.dataArr.count; row++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        if (curIndexPath != indexPath) {
            MMDocumentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            cell.selectBtn.selected = NO;
        }
    }
    self.name = cell.name;
    button.selected = !button.selected;
    if (button.selected) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [self.rightBtn setTitleColor:MMRGB(0x018eb0)forState:UIControlStateNormal];
    }else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        [self.rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}
- (NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}


@end
