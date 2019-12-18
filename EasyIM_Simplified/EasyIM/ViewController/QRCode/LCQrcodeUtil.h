//
//  LCQrcodeUtil.h
//  二维码Demo
//
//  Created by 优裁科技 on 2017/5/15.
//  Copyright © 2017年 优裁科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 * 生成二维码
 */
@interface LCQrcodeUtil : NSObject

/**
 创建二维码图片
 
 @param strContent 二维码内容
 @param size 二维码尺寸
 @param color 二维码颜色
 @param pic 需要附件在中间的图片(可选)
 @return UIImage
 */
+(UIImage *)creatQRImageWithContent:(NSString *_Nonnull)strContent
                            andSize:(CGSize)size
                           andColor:(UIColor *_Nonnull)color
                      andAdditional:(UIImage *_Nullable)pic;

@end
