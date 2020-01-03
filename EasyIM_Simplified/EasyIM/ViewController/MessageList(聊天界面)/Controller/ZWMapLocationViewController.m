//
//  ZWMapLocationViewController.m
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWMapLocationViewController.h"
@implementation MyAnnoation
@end
@interface ZWMapLocationViewController ()<MKMapViewDelegate>
@property(nonatomic,strong)  MKMapView *mapView;
@end

@implementation ZWMapLocationViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.mapView];
    [self setMapPosition:self.location];
    self.navigationView.backgroundColor = [UIColor clearColor];;
    self.navigationBgView.backgroundColor = [UIColor clearColor];
    [self showLeftBackButton];
}
- (void)setMapPosition:(CLLocation *)location
{
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
    CLLocationCoordinate2D center = location.coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.009310,0.007812);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    [self.mapView  setRegion:region animated:YES];
    self.mapView .rotateEnabled    = YES;
    self.mapView .showsUserLocation = NO;
    MyAnnoation *annotation=[[MyAnnoation alloc]init];
    annotation.coordinate = location.coordinate;
    [self.mapView addAnnotation:annotation];
}
- (MKMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
        _mapView.delegate = self;
    }
    
    return _mapView;
}


@end
