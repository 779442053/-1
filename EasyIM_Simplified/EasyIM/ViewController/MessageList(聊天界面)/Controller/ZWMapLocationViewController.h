//
//  ZWMapLocationViewController.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMBaseViewController.h"
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface MyAnnoation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@end
@interface ZWMapLocationViewController : MMBaseViewController
@property(nonatomic,strong) CLLocation *location;
@end

NS_ASSUME_NONNULL_END
