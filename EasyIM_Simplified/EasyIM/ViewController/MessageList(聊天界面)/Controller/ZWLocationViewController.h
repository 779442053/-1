//
//  ZWLocationViewController.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZWLocationManager.h"
#import "MMBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN
@protocol LocationViewControllerDelegate <NSObject>

- (void)cancelLocation;
- (void)sendLocation:(CLPlacemark *)placemark;

@end
@interface ZWLocationViewController : MMBaseViewController
@property (weak, nonatomic) id<LocationViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
