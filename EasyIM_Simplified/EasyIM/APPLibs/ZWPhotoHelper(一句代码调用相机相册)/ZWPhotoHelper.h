//
//  ZWPhotoHelper.h
//  ShareBee
//
//  Created by  on 2017/12/20.
//  Copyright © 2017年 . All rights reserved.
//@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

/*
 // 创建UIAlertController
 UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:@"请选择" preferredStyle:UIAlertControllerStyleActionSheet];
 
 [alertController addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 NSLog(@"相册");
 [self getSourceWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
 }]];
 [alertController addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 NSLog(@"相机");
 [self getSourceWithSourceType:UIImagePickerControllerSourceTypeCamera];
 }]];
 [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
 
 // 弹出
 [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
 
 
 - (void)getSourceWithSourceType:(UIImagePickerControllerSourceType)sourceType {
 =====配置弹出导航栏的颜色
 ZWPhotoConfig *config = [[ZWPhotoConfig alloc] init];
 config.navBarTintColor = [UIColor greenColor];
 config.navBarBgColor = [UIColor purpleColor];
 config.navBarTitleColor = [UIColor yellowColor];
 
 [[ZWPhotoHelper creatWithSourceType:sourceType config:config] getSourceWithSelectImageBlock:^(id data) {
 if ([data isKindOfClass:[UIImage class]]) { // 图片
 [self.imageView setImage:(UIImage *)data];
 } else {
 NSLog(@"所选内容非图片对象");
 }
 }];
 }
 */




#import <UIKit/UIKit.h>
@class ZWPhotoConfig;
// data可能是image对象，也可能是视频的NSURL
typedef void(^ZWPhotoHelperBlock)(id data);
@interface ZWPhotoHelper : UIImagePickerController
/**
 *  @param sourceType  类型
 */
+ (instancetype)creatWithSourceType:(UIImagePickerControllerSourceType)sourceType config:(ZWPhotoConfig *)config;

/**
 *  选择照片后回调
 */
- (void)getSourceWithSelectImageBlock:(ZWPhotoHelperBlock)selectImageBlock;
@end
#pragma mark - LXFPhotoConfig
@interface ZWPhotoConfig: NSObject
/** 导航条颜色 */
@property(nonatomic, strong) UIColor *navBarBgColor;
/** item的tintcolor */
@property(nonatomic, strong) UIColor *navBarTintColor;
/** titleView的字体颜色 */
@property(nonatomic, strong) UIColor *navBarTitleColor;
/** 图片是否可以编辑 */
@property(nonatomic, assign) BOOL allowsEditing;
@end



