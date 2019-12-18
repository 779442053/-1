

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

static NSString* const RequestContentTypeText = @"text/html";
static NSString* const RequestContentTypeJson = @"text/json";
static NSString* const RequestContentTypePlain = @"text/plain";
//设置代理
@class ZWRequest;
@protocol ZWRequestDelegate <NSObject>

- (void)ZWRequest:(ZWRequest *)request finished:(NSMutableDictionary *)response;
- (void)ZWRequest:(ZWRequest *)request Error:(NSString *)error;

@end
@interface ZWRequest : NSObject

@property (assign)id <ZWRequestDelegate>delegate;

/**
 *[AFNetWorking]的operationManager对象
 */
@property (nonatomic, strong) AFHTTPSessionManager* operationManager;

/**
 *当前的请求operation队列
 */
@property (nonatomic, strong) NSOperationQueue* operationQueue;

/**
 *功能: 创建CMRequest的对象方法
 */
+ (instancetype)request;

/**
 *功能：GET请求
 *参数：(1)请求的url: urlString
 *     (2)请求成功调用的Block: success
 *     (3)请求失败调用的Block: failure
 */
- (void)GET:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(ZWRequest *request, NSMutableDictionary *responseObject,NSDictionary *data))success
    failure:(void (^)(ZWRequest *request, NSError *error))failure;

/**
 *功能：POST请求
 *参数：(1)请求的url: urlString
 *     (2)POST请求体参数:parameters
 *     (3)请求成功调用的Block: success
 *     (4)请求失败调用的Block: failure
 */
- (void)POST:(NSString *)URLString
  parameters:(NSDictionary*)parameters
     success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
     failure:(void (^)(ZWRequest *request, NSError *error))failure;
- (void)POSTTWO:(NSString *)URLString
     parameters:(NSDictionary*)parameters
        success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
        failure:(void (^)(ZWRequest *request, NSError *error))failure;
/**
 *  post请求
 *
 *  @param URLString  请求网址
 *  @param parameters 请求参数
 */
- (void)postWithURL:(NSString *)URLString parameters:(NSDictionary *)parameters;

/**
 *  get 请求
 *
 *  @param URLString 请求网址
 */
- (void)getWithURL:(NSString *)URLString;

/**
 *  upload 请求
 *  上传图片
 *
 */
- (void)upload:(NSString*)URLString withFileData:(NSData*)fileData mimeType:(NSString*)mimeType name:(NSString*)name
  parameters:(NSDictionary*)parameters
     success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
     failure:(void (^)(ZWRequest *request, NSError *error))failure;

- (void)uploadFile:(NSString*)URLString withFileData:(NSData*)fileData mimeType:(NSString*)mimeType name:(NSString*)name
        parameters:(NSDictionary*)parameters
           success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
           failure:(void (^)(ZWRequest *request, NSError *error))failure;

- (void)uploadIMFile:(NSString *)URLString
parameters:(NSDictionary*)parameters
   success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
   failure:(void (^)(ZWRequest *request, NSError *error))failure;

- (void)uploadMoreFile:(NSString*)URLString withFileDataARR:(NSMutableArray*)fileDataARR mimeType:(NSString*)mimeType nameARR:(NSMutableArray*)nameARR
            parameters:(NSDictionary*)parameters
               success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
               failure:(void (^)(ZWRequest *request, NSError *error))failure;
/**
 *取消当前请求队列的所有请求
 */
- (void)cancelAllOperations;



@end
