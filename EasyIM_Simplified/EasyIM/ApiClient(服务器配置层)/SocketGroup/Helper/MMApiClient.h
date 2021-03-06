//
//  MMApiClient.h
//  EasyIM
//
//  Created by momo on 2019/4/25.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "ZWAPIConseKey.h"
NS_ASSUME_NONNULL_BEGIN

/** 请求成功的Block **/
typedef void(^ApiSuccess)(id responseObject);

/** 请求失败的Block **/
typedef void(^ApiFailed)(NSError *error);

/** 上传或者下载的进度, Progress.completedUnitCount:当前大小 - Progress.totalUnitCount:总大小**/
typedef void (^ApiProgress)(NSProgress *progress);


/**
 请求整理
 */
@interface MMApiClient : AFHTTPSessionManager

#pragma mark - 初始化方法
+ (instancetype)sharedClient;

/**
 取消所有HTTP请求
 */
- (void)cancelAllRequest;

/**
 取消指定URL的HTTP请求
 */
- (void)cancelRequestWithURL:(NSString *)URL;


#pragma mark - 网络请求
/**
 *  GET请求
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (__kindof NSURLSessionTask *)GET:(NSString *)URL parameters:(nullable NSDictionary *)parameters success:( nullable ApiSuccess)success failure:( nullable ApiFailed)failure;

/**
 *  POST请求
 *
 *  @param URL        请求地址
 *  @param parameters 请求参数
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 *
 *nullable: 表示修饰的属性或参数可以为空
 *nonnull:非空,表示修饰的属性或参数不能为空
 *  @return 返回的对象可取消请求,调用cancle方法
 */
- (__kindof NSURLSessionTask *)POST:(NSString *)URL parameters:(nullable NSDictionary *)parameters success:( nullable ApiSuccess)success failure:( nullable ApiFailed)failure;


- (__kindof NSURLSessionTask *)POSTFormData:(NSString *)URL parameters:(NSDictionary *)parameters success:(ApiSuccess)success failure:(ApiFailed)failure;


/**
 *  上传图片文件
 *
 *  @param URL   文件路径
 *  @param progress   上传进度信息
 *  @param success    请求成功的回调
 *  @param failure    请求失败的回调
 */
- (__kindof NSURLSessionTask *)UPLOAD_FilePath:(NSString *)URL parameters:(nullable NSDictionary *)parameters files:(nullable NSArray *)files progress:(nullable ApiProgress)progress success:(nullable ApiSuccess)success failure:( nullable ApiFailed)failure;


/**
 *  下载文件
 *
 *  @param URL      请求地址
 *  @param fileDir  文件存储目录(默认存储目录为Download)
 *  @param progress 文件下载的进度信息
 *  @param success  下载成功的回调(回调参数filePath:文件的路径)
 *  @param failure  下载失败的回调
 *
 *  @return 返回NSURLSessionDownloadTask实例，可用于暂停继续，暂停调用suspend方法，开始下载调用resume方法
 */
- (__kindof NSURLSessionTask *)DOWNLOAD:( nullable NSString *)URL fileDir:( nullable NSString *)fileDir progress:( nullable ApiProgress)progress success:(nullable void(^)(NSString *filePath))success failure:(nullable ApiFailed)failure;


#pragma mark - 配置网络请求
/**
 *  设置请求超时时间:默认为30S
 *
 *  @param time 时长
 */
- (void)setRequestTimeoutInterval:(NSTimeInterval)time;

/**
 *  设置请求头
 */
- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/**
 *  是否验证服务器证书:默认否
 *
 *  @param isAllow YES(是),NO(否)
 */
- (void)setSecurityPolicyAllowInvalidCertificates:(BOOL)isAllow;

@end

NS_ASSUME_NONNULL_END
