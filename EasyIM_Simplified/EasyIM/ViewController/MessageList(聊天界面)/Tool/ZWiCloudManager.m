//
//  ZWiCloudManager.m
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWiCloudManager.h"
#import "ZWDocument.h"


@implementation ZWiCloudManager
+ (BOOL)iCloudEnable {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSURL *url = [manager URLForUbiquityContainerIdentifier:nil];

    if (url != nil) {
        
        return YES;
    }
    return NO;
}
+ (void)downloadWithDocumentURL:(NSURL*)url callBack:(downloadBlock)block {
    ZWDocument *iCloudDoc = [[ZWDocument alloc]initWithFileURL:url];
    [iCloudDoc openWithCompletionHandler:^(BOOL success) {
        if (success) {
            [iCloudDoc closeWithCompletionHandler:^(BOOL success) {
                NSLog(@"关闭成功");
            }];
            if (block) {
                block(iCloudDoc.data);
            }
        }
    }];
}
@end
