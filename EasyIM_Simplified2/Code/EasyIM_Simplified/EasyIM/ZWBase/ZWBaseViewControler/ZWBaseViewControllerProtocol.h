//
//  ZWBaseViewModelProtocol.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ZWBaseViewModelProtocol;
@protocol ZWBsaeViewcontrollerProtocal <NSObject>

//绑定modelview
- (instancetype)initWithViewModel:(id <ZWBaseViewModelProtocol>)viewModel;

- (void)zw_bindViewModel;
- (void)zw_addSubviews;
- (void)zw_layoutNavigation;
- (void)zw_getNewData;
@end


