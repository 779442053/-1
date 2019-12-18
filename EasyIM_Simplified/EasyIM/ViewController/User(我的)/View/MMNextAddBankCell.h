//
//  MMNextAddBankCell.h
//  EasyIM
//
//  Created by momo on 2019/9/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MMBankInfoModel.h"

@protocol MMAddBankDelegate <NSObject>

- (void)dosomething;

- (void)sendCode;//发送验证码

@end

@interface MMNextAddBankCell : UITableViewCell


@property (nonatomic, strong) MMBankInfoModel *bankInfoModel;

- (void)addDelegate:( id <MMAddBankDelegate>)delegate andIndexPath:(NSIndexPath *)indexPath;


@end


