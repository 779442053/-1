//
//  ZWLocationManager.h
//  EasyIM
//
//  Created by step_zhang on 2020/1/3.
//  Copyright © 2020 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZWLocationManager : NSObject
@property (nonatomic,strong) void(^locationCompleteBlock)(CLLocationCoordinate2D coordinate2D);

@property (assign, nonatomic, readonly) CLLocationDegrees longitude; /**< 经度 */
@property (assign, nonatomic, readonly) CLLocationDegrees latitude; /**< 纬度 */

+ (instancetype)shareManager;

/**
 *  获取用户授权
 */
- (void)requestAuthorization;
/**
 *  开始定位
 */
- (void)startLocation;
/**
 *  停止定位
 */
- (void)stopLocation;

/**
 *  地理编码 （通过地址获取经纬度）
 *
 *  @param address       输入的地址
 *  @param success       成功block，返回pm
 *  @param failure       失败block
 */
- (void)geocode:(NSString *)address success:(void(^)(CLPlacemark *pm))success failure:(void(^)())failure;


/**
 *  反地理编码 （通过经纬度获取地址）
 *
 *  @param latitude      输入的纬度
 *  @param longitude     输入经度
 *  @param success       成功block，返回pms
 *  @param failure       失败block
 */
- (void)reverseGeocodeWithCoordinate2D:(CLLocationCoordinate2D)coordinate2D success:(void(^)(NSArray *placemarks))success failure:(void(^)())failure;


/**
 *  系统方法计算两点之间距离
 *
 *  @param endCoordinate2D   终点经纬度
 *  @param startCoordinate2D 起始点经纬度
 *
 *  @return 计算好的距离
 */
- (double)systemDistanceWithEndCoordinate2D:(CLLocationCoordinate2D)endCoordinate2D fromStartCoordinate2D:(CLLocationCoordinate2D)startCoordinate2D;


/**
 *  自定义方法计算两点之间距离
 *
 *  @param endCoordinate2D   终点经纬度
 *  @param startCoordinate2D 起始点经纬度
 *
 *  @return 计算好的距离
 */
- (double)customDistanceWithEndCoordinate2D:(CLLocationCoordinate2D)endCoordinate2D fromStartCoordinate2D:(CLLocationCoordinate2D)startCoordinate2D;


@end

NS_ASSUME_NONNULL_END
