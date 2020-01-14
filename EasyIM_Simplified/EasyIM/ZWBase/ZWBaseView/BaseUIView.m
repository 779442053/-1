//
//  BaseUIView.m
//  KuaiZhu
//
//  Created by Ghy on 2019/5/9.
//  Copyright © 2019年 su. All rights reserved.
//

#import "BaseUIView.h"
#import "MMTools.h"
#import <Photos/Photos.h>

/**
 * UI快捷创建
 */
@implementation BaseUIView

//MARK: - CreateUI
/** 创建按钮 */
+(UIButton *)createBtn:(CGRect)rect AndTitle:(NSString *)strTitle AndTitleColor:(UIColor *)tColor AndTxtFont:(UIFont *)tFont AndImage:(UIImage *)img AndbackgroundColor:(UIColor *)bgColor AndBorderColor:(UIColor *)bdColor AndCornerRadius:(CGFloat)radiuc WithIsRadius:(BOOL)isRadius WithBackgroundImage:(UIImage *)bgImg WithBorderWidth:(CGFloat)bdWidth{
    
    UIButton *btnTemp = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btnTemp.frame = rect;
    btnTemp.titleLabel.font = tFont;
    
    if (bgColor != nil) {
        btnTemp.backgroundColor = bgColor;
    }
    
    if (strTitle != nil) {
        [btnTemp setTitle:strTitle forState:UIControlStateNormal];
    }
    
    if (tColor != nil) {
        [btnTemp setTitleColor:tColor forState:UIControlStateNormal];
    }
    
    if (tFont != nil) {
        [btnTemp.titleLabel setFont:tFont];
    }
    
    if (img != nil) {
        [btnTemp setImage:img forState:UIControlStateNormal];
    }
    
    if (bgImg != nil) {
        [btnTemp setBackgroundImage:bgImg forState:UIControlStateNormal];
    }
    
    //圆角
    if (isRadius) {
        btnTemp.layer.borderColor = [UIColor clearColor].CGColor;
        if (bdColor != nil) {
            btnTemp.layer.borderColor = bdColor.CGColor;
        }
        
        btnTemp.layer.cornerRadius = radiuc;
        btnTemp.layer.masksToBounds = YES;
    }
    
    btnTemp.layer.borderWidth = bdWidth;
    
    return btnTemp;
}

/** 创建图片 */
+(UIImageView *)createImage:(CGRect)rect
                   AndImage:(UIImage *)img
         AndBackgroundColor:(UIColor *)bgColor
               WithisRadius:(BOOL)isRadius{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    
    if (bgColor != nil) {
        imageView.backgroundColor = bgColor;
    }
    
    if (img != nil) {
        imageView.image = img;
    }
    
    if (isRadius == YES) {
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = rect.size.height / 2;
    }
    
    return imageView;
}

+(UIImageView *)createImage:(CGRect)rect
                   AndImage:(UIImage *)img
         AndBackgroundColor:(UIColor *)bgColor
                  AndRadius:(BOOL)isRadius
                WithCorners:(CGFloat)corners{
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    
    if (bgColor != nil) {
        imageView.backgroundColor = bgColor;
    }
    
    if (img != nil) {
        imageView.image = img;
    }
    
    if (isRadius == YES) {
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = corners;
    }
    
    return imageView;
}

/** 创建UILable */
+(UILabel *)createLable:(CGRect)rect
                AndText:(NSString *)txt
           AndTextColor:(UIColor *)tColor
             AndTxtFont:(UIFont *)tFont
     AndBackgroundColor:(UIColor *)bgColor{
    
    UILabel *labTemp =[[UILabel alloc] initWithFrame:rect];
    
    if (bgColor != nil) {
        labTemp.backgroundColor = bgColor;
    }
    
    labTemp.textAlignment = NSTextAlignmentLeft;
    
    if (txt != nil) {
        labTemp.text = txt;
    }
    
    if (tFont != nil) {
        labTemp.font = tFont;
    }
    
    if (tColor != nil) {
        labTemp.textColor = tColor;
    }
    
    return labTemp;
}

/** 创建UITextField */
+(UITextField *)createTextField:(CGRect)rect
                        AndText:(NSString *)txt
                   AndTextColor:(UIColor *)tColor
                     AndTxtFont:(UIFont *)tFont
                  AndPlacehodle:(NSString *)strPlacehodel
             AndPlacehodleColor:(UIColor *)placeColor
             AndBackgroundColor:(UIColor *)bgColor{
    
    UITextField *_txtField = [[UITextField alloc] initWithFrame:rect];
    _txtField.borderStyle = UITextBorderStyleNone;
    
    if (bgColor != nil) {
        _txtField.backgroundColor = bgColor;
    }

    _txtField.textAlignment = NSTextAlignmentLeft;
    _txtField.clearButtonMode = UITextFieldViewModeAlways;

    if (txt != nil) {
        _txtField.text = txt;
    }
    
    if (strPlacehodel) {
        _txtField.placeholder = strPlacehodel;
    }

    if (tFont != nil) {
        _txtField.font = tFont;
    }

    if (tColor != nil) {
        _txtField.textColor = tColor;
    }

    return _txtField;
}

-(NSMutableAttributedString *)placeholder:(NSString *)text Tcolor:(UIColor *)tColor Font:(UIFont *)font{
    if (text.length == 0) {
        return nil;
    }
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc]initWithString:text attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:tColor}];
    return att;
}
/** 根据背景色创建视图 */
+(UIView *)createView:(CGRect)rect
   AndBackgroundColor:(UIColor *)bgcolor
          AndisRadius:(BOOL)radius
            AndRadiuc:(CGFloat)radiuc
       AndBorderWidth:(CGFloat)bdWidth
       AndBorderColor:(UIColor *)bdColor{
    
    UIView *_view = [[UIView alloc] initWithFrame:rect];
    
    if (bgcolor) {
        _view.backgroundColor = bgcolor;
    }
    else{
        _view.backgroundColor = [UIColor clearColor];
    }
    
    if (radius) {
        _view.layer.cornerRadius = radiuc;
        _view.layer.masksToBounds = YES;
        
        _view.layer.borderWidth = bdWidth;
        if (bdColor)
            _view.layer.borderColor = bdColor.CGColor;
        else
            _view.layer.borderColor = UIColor.clearColor.CGColor;
    }
    
    return _view;
}

/** 根据背景图创建UIView */
+(UIView *)createView:(CGRect)rect
     AndBackgroundImg:(UIImage *_Nullable)bgimage
          AndisRadius:(BOOL)radius
            AndRadiuc:(CGFloat)radiuc
       AndBorderWidth:(CGFloat)bdWidth
       AndBorderColor:(UIColor *)bdColor{
    
    UIView *_view = [[UIView alloc] initWithFrame:rect];
    
    if (bgimage) {
        UIImageView *img = [[UIImageView alloc] initWithImage:bgimage];
        img.frame = _view.bounds;
        [_view addSubview:img];
    }
    _view.backgroundColor = [UIColor clearColor];
    
    if (radius) {
        _view.layer.cornerRadius = radiuc;
        _view.layer.masksToBounds = YES;
        
        _view.layer.borderWidth = bdWidth;
        if (bdColor)
            _view.layer.borderColor = bdColor.CGColor;
        else
            _view.layer.borderColor = UIColor.clearColor.CGColor;
    }
    
    return _view;
}

/** 弹框选择图片或从相册获取 */
+(void)createPhotosAndCameraPickerForMessage:(NSString * _Nonnull)strMessage
                          andAlertController:(void(^ _Nonnull)(UIAlertController * _Nullable _alertVC))alertVCBack
                   withImagePickerController:(void(^ _Nonnull)(UIImagePickerController *_Nullable _imgPickerVC))imgPickerVCBack{
    
    //MARK:相册权限检测
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status != PHAuthorizationStatusAuthorized) {
            NSLog(@"开启权限设置");
            [MMTools openSetting];
            return;
        }
    }];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:strMessage preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *canceAction = [UIAlertAction actionWithTitle:@"取消"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];
    
    UIAlertAction *takePhotoAction =  [UIAlertAction actionWithTitle:@"拍摄"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 {
                                                                     //相机
                                                                     [self chooseImageBy:UIImagePickerControllerSourceTypeCamera andImgPickerVC:^(UIImagePickerController * _Nullable _imgPickCon) {
                                                                         imgPickerVCBack(_imgPickCon);
                                                                     }];
                                                                 }
                                                             }];
    
    UIAlertAction *photoAction =  [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //相册
        [self chooseImageBy:UIImagePickerControllerSourceTypePhotoLibrary andImgPickerVC:^(UIImagePickerController * _Nullable _imgPickCon) {
            imgPickerVCBack(_imgPickCon);
        }];
    }];
    
    [alertController addAction:canceAction];
    [alertController addAction:takePhotoAction];
    [alertController addAction:photoAction];
    
    alertVCBack(alertController);
}

+(void)chooseImageBy:(UIImagePickerControllerSourceType)sourceType
      andImgPickerVC:(void(^ _Nonnull)(UIImagePickerController * _Nullable _imgPickCon))imgPickerConBack{
    
    if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]
        && sourceType == UIImagePickerControllerSourceTypeCamera) {
        [MBProgressHUD showError:@"摄像头不可用"];
        return;
    }
    
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
    imagePickController.sourceType = sourceType;
    
    //默认前置摄像头
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    
    imgPickerConBack(imagePickController);
}

@end
