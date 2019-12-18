//
//  ZWBaseViewProtocal.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZWBaseViewModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol ZWBaseViewModelProtocol;

@protocol ZWBaseViewProtocal <NSObject>
@optional
- (instancetype)initWithViewModel:(id<ZWBaseViewModelProtocol>)viewModel;

- (void)zw_bindViewModel;
- (void)zw_setupViews;
- (void)zw_addReturnKeyBoard;
@end

NS_ASSUME_NONNULL_END
