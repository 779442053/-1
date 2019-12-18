//
//  MMSelectBankMViewController.h
//  EasyIM
//
//  Created by momo on 2019/9/11.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBaseViewController.h"


@protocol MMSelectBankDelegate <NSObject>

- (void)selectBankWithTitle:(NSString *)title andIndexPath:(NSIndexPath *)indexPath;

@end


/**
 选择银行或者添加银行
 */
@interface MMSelectBankMViewController : MMBaseViewController

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, weak) id <MMSelectBankDelegate> delegate;

@end


