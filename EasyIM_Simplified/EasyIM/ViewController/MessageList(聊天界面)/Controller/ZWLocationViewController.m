//
//  ZWLocationViewController.m
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import "ZWLocationViewController.h"

@interface ZWLocationViewController ()<UITableViewDelegate,UITableViewDataSource,MKMapViewDelegate>
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UIButton *showUserLocationButton;
@property (strong, nonatomic) UIImageView *locationImageView;
@property (strong, nonatomic) NSMutableArray *placemarkArray;
@property (assign, nonatomic) BOOL isFirstLocateUser;
@property (weak, nonatomic) NSIndexPath *selectedIndexPath;
@end

@implementation ZWLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationView.backgroundColor = [UIColor clearColor];;
    self.navigationBgView.backgroundColor = [UIColor clearColor];
    [self setTitle:@"选取位置"];
    UIButton *cancleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    cancleBtn.frame = CGRectMake(15, ZWStatusBarHeight + 5, 45, 35);
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    [cancleBtn addTarget:self action:@selector(cancel) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView addSubview:cancleBtn];
    
    UIButton *subBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    subBtn.frame = CGRectMake(KScreenWidth - 15 - 45, ZWStatusBarHeight + 5, 45, 35);
    [subBtn setTitle:@"发送" forState:UIControlStateNormal];
    [subBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    subBtn.titleLabel.font = [UIFont zwwNormalFont:13];
    [subBtn addTarget:self action:@selector(sendLocation) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView addSubview:subBtn];

    self.placemarkArray = [NSMutableArray array];
    self.isFirstLocateUser = YES;
    [self.mapView addSubview:self.locationImageView];
    [self.mapView addSubview:self.showUserLocationButton];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
    [[ZWLocationManager shareManager] requestAuthorization];
    [self.view updateConstraintsIfNeeded];
}
- (void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.locationImageView mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.centerX.equalTo(self.mapView.mas_centerX);
        make.centerY.equalTo(self.mapView.mas_centerY);
    }];
    
    [self.showUserLocationButton mas_makeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.mapView.mas_left).with.offset(8);
        make.bottom.equalTo(self.mapView.mas_bottom).with.offset(-8);
    }];
    
    [self.mapView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.height.mas_equalTo(KScreenHeight-400);
    }];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make)
    {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.mapView.mas_bottom);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.placemarkArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    if (indexPath.row == self.selectedIndexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.row >= self.placemarkArray.count)
    {
        return cell;
    }
    if (indexPath.row == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"[位置] \n%@",[self.placemarkArray[indexPath.row] name]];
    }
    else
    {
        cell.textLabel.text = [self.placemarkArray[indexPath.row] name];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectedIndexPath = indexPath;
    [tableView reloadData];
}
#pragma mark - MKMapViewDelegate
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
    if (!self.isFirstLocateUser)
    {
        return;
    }
    [mapView setShowsUserLocation:YES];
}
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.isFirstLocateUser = NO;
    [self showUserLocation];
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (!animated)
    {
        self.showUserLocationButton.selected = NO;
        [self updateCenterLocation:mapView.centerCoordinate];
    }
}
- (void)searchNearBy:(CLLocationCoordinate2D)coordinate{
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, 500, 500);
    MKLocalSearchRequest * req = [[MKLocalSearchRequest alloc]init];
    req.region=region;
    //兴趣点关键字
    req.naturalLanguageQuery = @"路";
    MKLocalSearch * ser = [[MKLocalSearch alloc]initWithRequest:req];
    [ser startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
    {
        NSArray * array = [NSArray arrayWithArray:response.mapItems];
        for (MKMapItem *mapItem in array)
        {
            [self.placemarkArray addObject:mapItem.placemark];
        }
        [self.tableView reloadData];
    }];
}
- (void)updateCenterLocation:(CLLocationCoordinate2D)centerCoordinate{
    MKCoordinateSpan span;
    span.latitudeDelta=0.001;
    span.longitudeDelta=0.001;
    MKCoordinateRegion region = {centerCoordinate,span};
    [self.mapView setRegion:region animated:YES];
    [self.placemarkArray removeAllObjects];
    [[ZWLocationManager shareManager] reverseGeocodeWithCoordinate2D:centerCoordinate success:^(NSArray *placemarks)
     {
        [self.placemarkArray addObjectsFromArray:placemarks];
        [self searchNearBy:centerCoordinate];
    }
    failure:^
    {
        [self searchNearBy:centerCoordinate];
    }];
}
- (void)showUserLocation
{
    self.showUserLocationButton.selected = YES;
    [self updateCenterLocation:self.mapView.userLocation.coordinate];
}
- (void)cancel
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelLocation)])
    {
        [self.delegate cancelLocation];
    }
}
- (void)sendLocation
{
    if (self.placemarkArray.count > self.selectedIndexPath.row)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendLocation:)])
        {
            [self.delegate sendLocation:self.placemarkArray[self.selectedIndexPath.row]];
        }
    }
}
- (MKMapView *)mapView
{
    if (!_mapView)
    {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
    }
    return _mapView;
}
- (UITableView *)tableView
{
    if (!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 200) style:UITableViewStylePlain];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor redColor];
    }
    return _tableView;
}
- (UIButton *)showUserLocationButton
{
    if (!_showUserLocationButton)
    {
        _showUserLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_showUserLocationButton setBackgroundImage:[UIImage imageNamed:@"show_user_location_normal"] forState:UIControlStateNormal];
        [_showUserLocationButton setBackgroundImage:[UIImage imageNamed:@"show_user_location_pressed"] forState:UIControlStateHighlighted];
        [_showUserLocationButton setBackgroundImage:[UIImage imageNamed:@"show_user_location_selected"] forState:UIControlStateSelected];
        [_showUserLocationButton addTarget:self action:@selector(showUserLocation) forControlEvents:UIControlEventTouchUpInside];
    }
    return _showUserLocationButton;
}
- (UIImageView *)locationImageView
{
    if (!_locationImageView)
    {
        _locationImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_green_icon"]];
    }
    return _locationImageView;
}
@end
