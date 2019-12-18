//
//  UIImage+ZWWOriginImage.m
//  MyBaseProgect
//
//  Created by  on 2018/5/9.
//  Copyright © 2018年 . All rights reserved.
//这里我们写一个UIImage的类目,来保证UIImage,不会被渲染,同时,如果图片为空,会打印提示.

#import "UIImage+ZWWOriginImage.h"
#import <objc/runtime.h>
@implementation UIImage (ZWWOriginImage)
// 加载内存时调用

+ (void)load
{
    // 交换方法
    
    // 获取 ImageOriginalWithStrName: 方法
    Method imageWithName = class_getClassMethod(self, @selector(ImageOriginalWithStrName:));
    
    // 获取 imageName 方法
    Method imageName = class_getClassMethod(self, @selector(imageNamed:));
    
    // 交换方法地址, 相当于交换实现
    
    method_exchangeImplementations(imageWithName, imageName);
    
}
+ (id)ImageOriginalWithStrName:(NSString *)name
{
    UIImage *image = [[self ImageOriginalWithStrName:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if (image == nil) {
        NSLog(@"亲,没有当前的图片,赶紧问UI妹妹要去吧^~^");
    }
    
    return image;
    
}
@end
