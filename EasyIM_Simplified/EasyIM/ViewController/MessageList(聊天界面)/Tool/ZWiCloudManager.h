//
//  ZWiCloudManager.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^downloadBlock)(id obj);


@interface ZWiCloudManager : NSObject
+ (BOOL)iCloudEnable;

+ (void)downloadWithDocumentURL:(NSURL*)url callBack:(downloadBlock)block;
@end


