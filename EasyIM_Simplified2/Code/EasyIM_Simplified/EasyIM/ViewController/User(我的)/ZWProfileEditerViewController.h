//
//  ZWProfileEditerViewController.h
//  EasyIM
//
//  Created by step_zhang on 2019/12/9.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZWProfileEditerViewController : MMBaseViewController
@property (nonatomic, copy)void(^confirmIdentity)(NSString * Vuale);
@property (nonatomic, copy)NSString *Type;
@end

NS_ASSUME_NONNULL_END
