//
//  YKImagePickerController.m
//  auction
//
//  Created by 源库 on 2017/4/17.
//  Copyright © 2017年 yuanku. All rights reserved.
//

#import "YKImagePickerControllerUtils.h"

@interface YKImagePickerControllerUtils ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) void(^returnImageData)(NSData *imageData);

@end

@implementation YKImagePickerControllerUtils

+ (instancetype)sharedManager {
    static YKImagePickerControllerUtils *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self new];
    });
    
    return _sharedManager;
}

/**
 展示相机相册访问选项
 
 @param viewController 当前视图
 @param returnImageData 返回图片block
 */
- (void)showCameraAndPhotoLibrary:(UIViewController *)viewController returnImageData:(void(^)(NSData *imageData))returnImageData {
    _returnImageData = returnImageData;
    //相机相册选项
    if ([[[UIDevice currentDevice] systemVersion]intValue] > 7.99) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {}];
        UIAlertAction* fromPhotoAction = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault                                                                 handler:^(UIAlertAction * action) {
            //info.plist NSPhotoLibraryUsageDescription   App需要您的同意,才能访问相册
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [viewController presentViewController:imagePicker animated:YES completion:nil];
            }
        }];
        UIAlertAction* fromCameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault                                                             handler:^(UIAlertAction * action) {
            //info.plist NSCameraUsageDescription   App需要您的同意,才能访问相机
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
                imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                [viewController presentViewController:imagePicker animated:YES completion:nil];
            }
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:fromCameraAction];
        [alertController addAction:fromPhotoAction];
        [viewController presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        if (_returnImageData) _returnImageData(UIImageJPEGRepresentation(portraitImg, 0.1));
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

