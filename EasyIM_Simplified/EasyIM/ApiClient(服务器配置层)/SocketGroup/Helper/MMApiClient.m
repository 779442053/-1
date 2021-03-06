//
//  MMApiClient.m
//  EasyIM
//
//  Created by momo on 2019/4/25.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMApiClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "GlobalVariable.h"

static MMApiClient *_sharedClient = nil;
static NSMutableArray *_allSessionTask;

@implementation MMApiClient

#pragma mark - 初始化方法
+ (instancetype)sharedClient{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //AFNetWork
        _sharedClient = [MMApiClient manager];
        
        // 设置请求格式（服务端接收的数据格式）
        AFHTTPRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        
        [requestSerializer setHTTPShouldHandleCookies:YES];
        
        // 设置超时时间
        requestSerializer.timeoutInterval = 10.0f;
        
        [requestSerializer setValue:@"application/x-www-form-urlencoded;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        _sharedClient.requestSerializer = requestSerializer;
        
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.securityPolicy.allowInvalidCertificates = NO;
        _sharedClient.securityPolicy.validatesDomainName = YES;
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
        
        // 设置返回格式
        _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*",@"multipart/form-data", nil];
    });
    
    [_sharedClient setValue:[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@""
         forHTTPHeaderField:@"token"];
    
    return _sharedClient;
}

- (NSMutableArray *)allSessionTask{
    if (!_allSessionTask){
        _allSessionTask = [[NSMutableArray alloc] init];
    }
    return _allSessionTask;
}


- (void)cancelAllRequest{
    @synchronized(self){
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self allSessionTask] removeAllObjects];
    }
}


- (void)cancelRequestWithURL:(NSString *)URL{
    if (!URL) { return; }
    @synchronized (self){
        [[self allSessionTask] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL]) {
                [task cancel];
                [[self allSessionTask] removeObject:task];
                *stop = YES;
            }
        }];
    }
}

#pragma mark - 网络请求

- (NSURLSessionTask *)GET:(NSString *)URL parameters:(NSDictionary *)parameters success:(ApiSuccess)success failure:(ApiFailed)failure{
    NSURLSessionTask *sessionTask = [_sharedClient
                                     GET:[self urlControlWithURL:URL param:parameters]
                                     parameters:parameters
                                     progress:nil
                                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        NSDictionary *dicTemp = responseObject;
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *strJson = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dicTemp = [NSDictionary dictionaryWithJsonString:strJson];
        }
        else{
            //超时，重新登录
            if (K_APP_REQUEST_AUTHID(dicTemp)) {
                NSDictionary *dict = @{
                                       @"loginType":@"410",
                                       @"username":[[NSUserDefaults standardUserDefaults] stringForKey:K_APP_LOGIN_USER],
                                       @"userPsw":[YHUtils md5HexDigest:[[NSUserDefaults standardUserDefaults] stringForKey:K_APP_LOGIN_PWD]]
                                       };
                ZWWLog(@"需要重新登录.获取用户的userid或者用户的token");
//                [MMRequestManager imLoginWithParameters:dict
//                                               callBack:^(id  _Nonnull responseData) {
//                                                   NSLog(@"token失效已重连");
//                                                   [sessionTask resume];
//                                               }];
            }
            else if ([dicTemp[@"ret"] isEqualToString:@"fail"]) {
                [MMProgressHUD showHUD:dicTemp[@"desc"]];
            }
        }
        
        success ? success(dicTemp) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}


- (NSURLSessionTask *)POST:(NSString *)URL parameters:(NSDictionary *)parameters success:(ApiSuccess)success failure:(ApiFailed)failure
{
    NSURLSessionTask *sessionTask = [_sharedClient POST:[self urlControlWithURL:URL param:parameters] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}

- (__kindof NSURLSessionTask *)POSTFormData:(NSString *)URL parameters:(NSDictionary *)parameters success:(ApiSuccess)success failure:(ApiFailed)failure
{
    
    [_sharedClient.requestSerializer setValue:[ZWUserModel currentUser]?[ZWUserModel currentUser].sessionID:@"" forHTTPHeaderField:@"token"];
    
    NSURLSessionTask *sessionTask = [_sharedClient POST:[self urlControlWithURL:URL param:parameters] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        
    }progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
        
    }];
    
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    return sessionTask;
}

- (NSURLSessionTask *)UPLOAD_FilePath:(NSString *)URL parameters:(NSDictionary *)parameters  files:(NSArray *)files progress:(ApiProgress)progress success:(ApiSuccess)success failure:(ApiFailed)failure
{
    
    NSURLSessionTask *sessionTask = [_sharedClient POST:[self urlControlWithURL:URL param:parameters] parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSDictionary *fileItem in files) {
            id value = [fileItem objectForKey:@"file"];                     //支持四种数据类型：NSData、UIImage、NSURL、NSString
            NSString *name = [fileItem objectForKey:@"name"];               //服务器字段名
            NSString *fileName = [fileItem objectForKey:@"fileName"];       //要传递的文件名
            NSString *mimeType = [fileItem objectForKey:@"mimeType"];       //文件类型
            mimeType = mimeType ? mimeType : @"image/jpeg";
            name = name ? name : @"file";
            
            if ([value isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:value name:name fileName:fileName mimeType:mimeType];
                
            } else if ([value isKindOfClass:[UIImage class]]) {
                if (UIImagePNGRepresentation(value)) {  //返回为png图像。
                    [formData appendPartWithFileData:UIImagePNGRepresentation(value) name:name fileName:fileName mimeType:mimeType];
                }else {   //返回为JPEG图像。
                    [formData appendPartWithFileData:UIImageJPEGRepresentation(value, 0.5) name:name fileName:fileName mimeType:mimeType];
                }
            }else if ([value isKindOfClass:[NSURL class]]) {
                [formData appendPartWithFileURL:value name:name fileName:fileName mimeType:mimeType error:nil];
            }else if ([value isKindOfClass:[NSString class]]) {
                [formData appendPartWithFileURL:[NSURL URLWithString:value]  name:name fileName:fileName mimeType:mimeType error:nil];            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //上传进度
        progress ? progress(uploadProgress) : nil;
        NSLog(@"上传进度：---------- %f", uploadProgress.fractionCompleted);
        NSLog(@"上传进度:%.2f%%",100.0*uploadProgress.completedUnitCount/uploadProgress.totalUnitCount);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self allSessionTask] removeObject:task];
        success ? success(responseObject) : nil;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [[self allSessionTask] removeObject:task];
        failure ? failure(error) : nil;
    }];
    
    // 添加sessionTask到数组
    sessionTask ? [[self allSessionTask] addObject:sessionTask] : nil ;
    
    return sessionTask;
}


- (NSURLSessionTask *)DOWNLOAD:(NSString *)URL fileDir:(NSString *)fileDir progress:(ApiProgress)progress success:(void (^)(NSString *))success failure:(ApiFailed)failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self urlControlWithURL:URL param:nil]]];
    __block NSURLSessionDownloadTask *downloadTask = [_sharedClient downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        progress ? progress(downloadProgress) : nil;
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *path = [[MMFileTool createPathWithChildPath:fileDir] stringByAppendingString:[NSString stringWithFormat:@"/%@",response.suggestedFilename]];
        
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [[self allSessionTask] removeObject:downloadTask];
        if(failure && error) {
            failure(error);
            return ;
        }
        success ? success(filePath.path /** NSURL->NSString*/) : nil;
    }];
    
    [downloadTask resume];
    
    downloadTask ? [[self allSessionTask] addObject:downloadTask] : nil ;
    return downloadTask;
}


#pragma mark - 重置AFHttpSessionManager相关属性
- (void)setRequestTimeoutInterval:(NSTimeInterval)time
{
    _sharedClient.requestSerializer.timeoutInterval = time;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field
{
    [_sharedClient.requestSerializer setValue:value forHTTPHeaderField:field];
}

- (void)setSecurityPolicyAllowInvalidCertificates:(BOOL)isAllow
{
    _sharedClient.securityPolicy.allowInvalidCertificates = isAllow;
}


#pragma mark - 内外部URL处理
- (NSString *)urlControlWithURL:(NSString *)url param:(NSDictionary *)param
{
    NSLog(@"当前请求网址:%@",url);
    if ([url rangeOfString:@"http:"].location != NSNotFound || [url rangeOfString:@"https:"].location != NSNotFound) {
        return url;
    }
    NSLog(@"当前请求网址%@",[NSString stringWithFormat:@"%@%@",HTURL,url]);
    return [NSString stringWithFormat:@"%@%@",HTURL,url];
}


@end
