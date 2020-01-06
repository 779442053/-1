

#import "ZWRequest.h"
#import "ZWMessage.h"
#import "YJProgressHUD.h"

#import "ZWAPIConseKey.h"
@implementation ZWRequest

+(instancetype)request{
    return [[self alloc]init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.operationManager = [AFHTTPSessionManager manager];
        self.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
        self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
        //self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    }
    return self;
}

- (void)GET:(NSString *)URLString
 parameters:(NSDictionary*)parameters
    success:(void (^)(ZWRequest *request, NSMutableDictionary *responseObject,NSDictionary *data))success
    failure:(void (^)(ZWRequest *request, NSError *error))failure {
    
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];//声明返回的结果是json类型
    self.operationManager.requestSerializer.timeoutInterval = 8.f;
    [self.operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:RequestContentTypeText,RequestContentTypeJson,RequestContentTypePlain, @"application/json",nil];
    NSString *URL = [NSString stringWithFormat:@"%@%@",HTURL,URLString];
    ZWWLog(@"url=%@",URL)
    NSString *str1 = [URL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.operationManager GET:str1 parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        
        ZWWLog(@"downloadProgress=%@",downloadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, NSMutableDictionary* responseObject) {
        NSDictionary *data;
        if (responseObject[@"data"] && [responseObject[@"data"] isKindOfClass:[NSString class]]) {
             data = [self convertjsonStringToDict:responseObject[@"data"]];
        }
        
        //NSString *responseJson = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        ZWWLog(@"[ZWRequest请求成功]: %@",responseObject);
        
        success(self,responseObject,data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        ZWWLog(@"[ZWRequest请求失败了]: %@",error.localizedDescription);
        [YJProgressHUD hideHUD];
        if (error.code == -1001) {
            ZWWLog(@"请求超时啦")
            [ZWMessage error:@"请求超时,请稍后再来" title:@"温馨提示"];
        }else if (error.code == -1009){
            [ZWMessage error:@"似乎已断开与互联网的连接" title:@"温馨提示"];
        }else{
            ZWWLog(@"[ZWRequest请求失败]: %@  \n %@",error.localizedDescription,error);
            [ZWMessage error:error.localizedDescription title:@"温馨提示"];
        }
        failure(self,error);
        
    }];
    
}
- (void)POSTTWO:(NSString *)URLString
  parameters:(NSDictionary*)parameters
     success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
     failure:(void (^)(ZWRequest *request, NSError *error))failure{
    
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];//声明返回的结果是json类型
    self.operationManager.requestSerializer.timeoutInterval = 8.f;
    [self.operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
   self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain", @"text/javascript", nil];
    NSString *URL = [NSString stringWithFormat:@"%@%@",HTURL,URLString];
    ZWWLog(@"请求地址=%@,请求参数=%@",URL,parameters);
    [self.operationManager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, NSMutableDictionary* responseObject) {
        NSDictionary *data;
        if (responseObject[@"data"] && [responseObject[@"data"] isKindOfClass:[NSString class]]) {
            data = [self convertjsonStringToDict:responseObject[@"data"]];
        }
        success(self,responseObject,data);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [YJProgressHUD hideHUD];
        if (error.code == -1001) {
            ZWWLog(@"请求超时啦")
            [ZWMessage error:@"请求超时,请稍后再来" title:@"温馨提示"];
        }else if (error.code == -1009){
            [ZWMessage error:@"似乎已断开与互联网的连接" title:@"温馨提示"];
        }else{
            ZWWLog(@"[ZWRequest请求失败]: %@  \n %@",error.localizedDescription,error);
            [ZWMessage error:error.localizedDescription title:@"温馨提示"];
        }
        failure(self,error);
    }];
}
- (void)POST:(NSString *)URLString
  parameters:(NSDictionary*)parameters
     success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
     failure:(void (^)(ZWRequest *request, NSError *error))failure{
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];//声明返回的结果是json类型
    self.operationManager.requestSerializer.timeoutInterval = 8.f;
    [self.operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json",@"text/plain", @"text/javascript", nil];
    NSString *token = [ZWUserModel currentUser].token;
    [self.operationManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
   
    NSString *URL = [NSString stringWithFormat:@"%@%@",HTURL,URLString];
    ZWWLog(@"请求地址=%@,请求参数=%@",URL,parameters);
    [self.operationManager POST:URL parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        
        //ZWWLog(@"uploadProgress=%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, NSMutableDictionary* responseObject) {
        NSDictionary *data;
        ZWWLog(@"[ZWRequest成功]: %@",responseObject);
        success(self,responseObject,data);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [YJProgressHUD hideHUD];
        if (error.code == -1001) {
            ZWWLog(@"请求超时啦")
            [ZWMessage error:@"请求超时,请稍后再来" title:@"温馨提示"];
        }else if (error.code == -1009){
            [ZWMessage error:@"似乎已断开与互联网的连接" title:@"温馨提示"];
        }else{
            ZWWLog(@"[ZWRequest请求失败]: %@  \n %@",error.localizedDescription,error);
            [ZWMessage error:error.localizedDescription title:@"温馨提示"];
        }
        failure(self,error);
    }];
    
}

- (void)postWithURL:(NSString *)URLString parameters:(NSMutableDictionary *)parameters {
    
    [self POST:URLString
    parameters:parameters
       success:^(ZWRequest *request, NSMutableDictionary *responseString,NSDictionary *data) {
           if ([self.delegate respondsToSelector:@selector(ZWRequest:finished:)]) {
               [self.delegate ZWRequest:request finished:responseString];
               
           }
       }
       failure:^(ZWRequest *request, NSError *error) {
           if ([self.delegate respondsToSelector:@selector(ZWRequest:Error:)]) {
               [self.delegate ZWRequest:request Error:error.description];
           }
       }];
}

- (void)getWithURL:(NSString *)URLString {
    
    [self GET:URLString parameters:nil success:^(ZWRequest *request, NSMutableDictionary *responseString,NSDictionary *data) {
        if ([self.delegate respondsToSelector:@selector(ZWRequest:finished:)]) {
            [self.delegate ZWRequest:request finished:responseString];
        }
    } failure:^(ZWRequest *request, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(ZWRequest:Error:)]) {
            [self.delegate ZWRequest:request Error:error.description];
        }
    }];
}

- (void)cancelAllOperations{
    [self.operationQueue cancelAllOperations];
}


- (void)upload:(NSString*)URLString withFileData:(NSData*)fileData mimeType:(NSString*)mimeType name:(NSString*)name
    parameters:(NSDictionary*)parameters
       success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
       failure:(void (^)(ZWRequest *request, NSError *error))failure
{
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];
    self.operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",@"text/javascript,multipart/form-data",nil];
    self.operationManager.requestSerializer.timeoutInterval = 8.f;
    [self.operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSString *token = [ZWUserModel currentUser].token;
    [self.operationManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    NSString *URL = [NSString stringWithFormat:@"%@%@",HTURL,URLString];
    ZWWLog(@"请求地址=%@,请求参数=%@",URL,parameters);
    [self.operationManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%.0f.%@", timestamp, name];
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
         ZWWLog(@"上传进度=%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *data;
        ZWWLog(@"[ZWRequest成功]: %@",responseObject);
        if (responseObject[@"imgurl"] && [responseObject[@"imgurl"] isKindOfClass:[NSString class]]) {
            data = [self convertjsonStringToDict:responseObject[@"data"]];
        }
        success(self,responseObject,data);
        ZWWLog(@"============上传文件成功啦==========")
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         failure(self,error);
        ZWWLog(@"===上传失败啦===上传失败啦====上传失败啦")
        if (error.code == -1001) {
            ZWWLog(@"请求超时啦")
            [ZWMessage error:@"请求超时,请稍后再来" title:@"温馨提示"];
        }else if (error.code == -1009){
            [ZWMessage error:@"似乎已断开与互联网的连接" title:@"温馨提示"];
        }else{
            ZWWLog(@"[ZWRequest请求失败]: %@  \n %@",error.localizedDescription,error);
            [ZWMessage error:error.localizedDescription title:@"温馨提示"];
        }
        failure(self,error);
    }];
    
}
- (void)uploadIMFile:(NSString *)URLString
parameters:(NSDictionary*)parameters
   success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
             failure:(void (^)(ZWRequest *request, NSError *error))failure{
    
}
- (void)uploadFile:(NSString*)URLString withFileData:(NSData*)fileData mimeType:(NSString*)mimeType name:(NSString*)name
    parameters:(NSDictionary*)parameters
       success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
       failure:(void (^)(ZWRequest *request, NSError *error))failure{
    
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    self.operationManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    self.operationManager.requestSerializer.timeoutInterval = 10.f;
    [self.operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    self.operationManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",@"text/javascript,multipart/form-data",nil];
     [self.operationManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSString *token = [ZWUserModel currentUser].token;
    [self.operationManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    
    NSString *URL = [NSString stringWithFormat:@"%@%@",HTURL,URLString];
    ZWWLog(@"请求地址=%@,请求参数=%@",URL,parameters);
    [self.operationManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //当前时间戳
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSString *fileName = [NSString stringWithFormat:@"%.0f.%@", timestamp, name];
        ZWWLog(@"name = %@ ,fileName = %@  ,mimeType=%@",name,fileName,mimeType)
        [formData appendPartWithFileData:fileData name:name fileName:fileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        ZWWLog(@"上传进度====%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         ZWWLog(@"============上传成功啦==========\n ")
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * dicTemp;
            NSString *strJson = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dicTemp = [[NSDictionary dictionaryWithJsonString:strJson] mutableCopy];
            ZWWLog(@"============上传成功啦==========\n %@",dicTemp)
            success(self,dicTemp,nil);
        }else{
            success(self,responseObject,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ZWWLog(@"===上传失败啦===上传失败啦====上传失败啦 \n= %@",error)
        if (error.code == -1001) {
            ZWWLog(@"请求超时啦")
            [ZWMessage error:@"请求超时,请稍后再来" title:@"温馨提示"];
        }else if (error.code == -1009){
            [ZWMessage error:@"似乎已断开与互联网的连接" title:@"温馨提示"];
        }else{
            ZWWLog(@"[ZWRequest请求失败]: %@  \n %@",error.localizedDescription,error);
            [ZWMessage error:error.localizedDescription title:@"温馨提示"];
        }
        failure(self,error);
    }];
}

- (void)uploadMoreFile:(NSString*)URLString withFileDataARR:(NSMutableArray*)fileDataARR mimeType:(NSString*)mimeType nameARR:(NSMutableArray*)nameARR
        parameters:(NSDictionary*)parameters
           success:(void (^)(ZWRequest *request, NSMutableDictionary* responseString,NSDictionary *data))success
           failure:(void (^)(ZWRequest *request, NSError *error))failure{
    
    self.operationQueue=self.operationManager.operationQueue;
    self.operationManager.responseSerializer = [AFJSONResponseSerializer serializer];//声明返回的结果是json类型
    self.operationManager.requestSerializer.timeoutInterval = 8.f;
    [self.operationManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    NSString *URL = [NSString stringWithFormat:@"%@%@",HTURL,URLString];
    [self.operationManager POST:URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i = 0; i < fileDataARR.count; i++){
//            ZWWLog(@"=nameARR==%@",fileDataARR[i])
//            ZWWLog(@"=nameARR==%@",nameARR[i])
            NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
            NSString *fileName = [NSString stringWithFormat:@"%.0f.%@", timestamp, nameARR[i]];
            [formData appendPartWithFileData:fileDataARR[i] name:nameARR[i] fileName:fileName mimeType:mimeType];
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        ZWWLog(@"上传进度=%@",uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        ZWWLog(@"============上传成功啦==========\n =%@",responseObject)
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary * dicTemp;
            NSString *strJson = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            dicTemp = [[NSDictionary dictionaryWithJsonString:strJson] mutableCopy];
            success(self,dicTemp,nil);
        }else{
            success(self,responseObject,nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        ZWWLog(@"===上传失败啦===上传失败啦====上传失败啦=%@",[error description])
        failure(self,error);
    }];
}
- (NSDictionary *)convertjsonStringToDict:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}












@end
