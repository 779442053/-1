//
//  MMImageBrowser.h
//  EasyIM
//
//  Created by momo on 2019/4/25.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMImageBrowser : NSObject

+ (instancetype)sharedBrowser;

- (void)showImages:(NSArray *)aImageArray
    fromController:(UIViewController *)aController;

- (void)dismissViewController;

@end

NS_ASSUME_NONNULL_END
