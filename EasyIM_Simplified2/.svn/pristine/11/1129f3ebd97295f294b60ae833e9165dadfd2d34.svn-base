//
//  YKImagePickerController.h
//  auction
//
//  Created by 源库 on 2017/4/17.
//  Copyright © 2017年 yuanku. All rights reserved.
//

//info.plist NSPhotoLibraryUsageDescription App需要您的同意,才能访问相册
//info.plist NSCameraUsageDescription App需要您的同意,才能访问相机

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YKImagePickerControllerUtils : NSObject

+ (instancetype)sharedManager;

/**
 展示相机相册访问选项
 
 @param viewController 当前视图
 @param returnImageData 返回图片block
 */
- (void)showCameraAndPhotoLibrary:(UIViewController *)viewController returnImageData:(void(^)(NSData *imageData))returnImageData;

@end

