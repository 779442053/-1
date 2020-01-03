//
//  MMDocumentViewController.h
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMDocumentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MMDocumentDelegate <NSObject>

- (void)selectedFileName:(NSString *)fileName;

@end


@interface MMDocumentViewController : MMBaseViewController

@property (nonatomic, weak) id <MMDocumentDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
