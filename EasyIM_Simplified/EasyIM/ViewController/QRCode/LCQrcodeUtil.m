//
//  LCQrcodeUtil.m
//  二维码Demo
//
//  Created by 优裁科技 on 2017/5/15.
//  Copyright © 2017年 优裁科技. All rights reserved.
//

#import "LCQrcodeUtil.h"

/**
 * 生成二维码
 */
@implementation LCQrcodeUtil

#pragma mark 生成二维码
/**
 创建二维码图片

 @param strContent 二维码内容
 @param size 二维码尺寸
 @param color 二维码颜色
 @param pic 需要附加在中间的图片(可选)
 @return UIImage
 */
+(UIImage *)creatQRImageWithContent:(NSString *_Nonnull)strContent
                            andSize:(CGSize)size
                           andColor:(UIColor *_Nonnull)color
                      andAdditional:(UIImage *_Nullable)pic{
    
    CIImage *ciimage = [self createQRForString:strContent];
    UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:ciimage
                                                           withSize:size];
    
    if (color) {
        CGFloat R = 0.0, G = 0.0, B = 0.0;
        
        CGColorRef colorRef = [color CGColor];
        long numComponents = CGColorGetNumberOfComponents(colorRef);
        
        if (numComponents == 4)
        {
            const CGFloat *components = CGColorGetComponents(colorRef);
            R = components[0];
            G = components[1];
            B = components[2];
        }
        
        UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:R andGreen:G andBlue:B];
        
        //设置二维码Logo图
        if (pic) {
            customQrcode = [self setQRCodeLogoImage:customQrcode
                                         AndLogoimg:pic
                                          AndCircle:YES];
        }
        
        return customQrcode;
    }
    
    //设置二维码Logo图
    if (pic) {
        qrcode = [self setQRCodeLogoImage:qrcode
                               AndLogoimg:pic
                                AndCircle:YES];
    }

    return qrcode;
}

#pragma mark - QRCodeGenerator
+ (CIImage *)createQRForString:(NSString *)qrString {
    // Need to convert the string to a UTF-8 encoded NSData object
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create the filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // Set the message content and error-correction level
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    
    /*
     * 二维码容错率用字母表示，容错能力等级分为：L、M、Q、H四级：
       L       7%
       M     15%
       Q      25%
       H     30%
     */
    [qrFilter setValue:@"H" forKey:@"inputCorrectionLevel"];
    
    // Send the image back
    return qrFilter.outputImage;
}

//设置二维码logo图
+ (UIImage *)setQRCodeLogoImage:(UIImage *)imgTemp
                     AndLogoimg:(UIImage *)logo
                      AndCircle:(BOOL)isCircle{
    
    //开启绘图,获取图形上下文
    CGSize tempSize = imgTemp.size;
    UIGraphicsBeginImageContextWithOptions(tempSize, NO, 1);
    
    //把二维码图片画上去. (这里是以,图形上下文,左上角为 (0,0)点)
    [imgTemp drawInRect:CGRectMake(0, 0, tempSize.width, tempSize.height)];
    
    //圆角处理
    CGFloat w = logo.size.width > 50 ?50:logo.size.width;
    CGFloat h = logo.size.height > 50 ?50:logo.size.height;
    CGRect rect = CGRectMake((tempSize.width - w) * 0.5, (tempSize.height - h) * 0.5, w, h);
    if (isCircle) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rect
                                                              cornerRadius:w * 05];
        [bezierPath addClip];
    }
    [logo drawInRect:rect];
    
    UIImage *temp = UIGraphicsGetImageFromCurrentImageContext();
    if (temp == nil) {
        temp = imgTemp;
    }
    
    //结束绘画
    UIGraphicsEndImageContext();
    
    return temp;
}


#pragma mark - InterpolatedUIImage
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image
                                            withSize:(CGSize)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size.width/CGRectGetWidth(extent), size.height/CGRectGetHeight(extent));
    
    // create a bitmap image that we'll draw into a bitmap context at the desired size;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
   
    // Create an image with the contents of our bitmap
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    
    // Cleanup
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - imageToTransparent
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}


+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    // create context
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // traverse pixe
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900){
            // change color
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }else{
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // context to image
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // release
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end
