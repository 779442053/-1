//
//  BaseUIView.h
//  KuaiZhu
//
//  Created by Ghy on 2019/5/9.
//  Copyright © 2019年 su. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseUIView : NSObject

//MARK: - CreateUI
/** 创建按钮 */
+(UIButton *_Nonnull)createBtn:(CGRect)rect
                      AndTitle:(NSString *_Nullable)strTitle
                 AndTitleColor:(UIColor * _Nullable)tColor
                    AndTxtFont:(UIFont * _Nullable)tFont
                      AndImage:(UIImage * _Nullable)img
            AndbackgroundColor:(UIColor * _Nullable)bgColor
                AndBorderColor:(UIColor * _Nullable)bdColor
               AndCornerRadius:(CGFloat)radiuc
                  WithIsRadius:(BOOL)isRadius
           WithBackgroundImage:(UIImage * _Nullable)bgImg
               WithBorderWidth:(CGFloat)bdWidth;

/** 创建图片 */
+(UIImageView *_Nonnull)createImage:(CGRect)rect
                           AndImage:(UIImage * _Nullable)img
                 AndBackgroundColor:(UIColor * _Nullable)bgColor
                       WithisRadius:(BOOL)isRadius;

+(UIImageView *_Nonnull)createImage:(CGRect)rect
                           AndImage:(UIImage *_Nullable)img
                 AndBackgroundColor:(UIColor *_Nullable)bgColor
                          AndRadius:(BOOL)isRadius
                        WithCorners:(CGFloat)corners;

/** 创建UILable */
+(UILabel *_Nonnull)createLable:(CGRect)rect
                        AndText:(NSString *_Nullable)txt
                   AndTextColor:(UIColor *_Nullable)tColor
                     AndTxtFont:(UIFont *_Nullable)tFont
             AndBackgroundColor:(UIColor *_Nullable)bgColor;

/** 根据背景色创建UIView */
+(UIView *_Nonnull)createView:(CGRect)rect
           AndBackgroundColor:(UIColor *_Nullable)bgcolor
                  AndisRadius:(BOOL)radius
                    AndRadiuc:(CGFloat)radiuc
               AndBorderWidth:(CGFloat)bdWidth
               AndBorderColor:(UIColor *_Nullable)bdColor;

/** 根据背景图创建UIView */
+(UIView *_Nonnull)createView:(CGRect)rect
             AndBackgroundImg:(UIImage *_Nullable)bgimage
                  AndisRadius:(BOOL)radius
                    AndRadiuc:(CGFloat)radiuc
               AndBorderWidth:(CGFloat)bdWidth
               AndBorderColor:(UIColor *)bdColor;

/** 弹框选择图片或从相册获取 */
+(void)createPhotosAndCameraPickerForMessage:(NSString * _Nonnull)strMessage
                          andAlertController:(void(^ _Nonnull)(UIAlertController * _Nullable _alertVC))alertVCBack
                   withImagePickerController:(void(^ _Nonnull)(UIImagePickerController *_Nullable _imgPickerVC))imgPickerVCBack;

/** 创建UITextField */
+(UITextField *_Nonnull)createTextField:(CGRect)rect
                                AndText:(NSString *_Nullable)txt
                           AndTextColor:(UIColor *_Nullable)tColor
                             AndTxtFont:(UIFont *_Nullable)tFont
                          AndPlacehodle:(NSString *_Nullable)strPlacehodel
                     AndPlacehodleColor:(UIColor *_Nullable)placeColor
                     AndBackgroundColor:(UIColor *_Nullable)bgColor;

@end
