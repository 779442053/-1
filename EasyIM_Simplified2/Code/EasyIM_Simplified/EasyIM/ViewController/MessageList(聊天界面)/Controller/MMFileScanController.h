//
//  MMFileScanController.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//
// 判断文件类型并查看
#import "MMFileScanController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MMFileScanController : UIViewController

// 文件路径
@property (nonatomic, copy) NSString *filePath;

// 原文件名
@property (nonatomic, copy) NSString *orgName;

@end

NS_ASSUME_NONNULL_END
