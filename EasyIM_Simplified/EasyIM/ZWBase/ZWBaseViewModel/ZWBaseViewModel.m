//
//  ZWBaseViewModel.m
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "ZWBaseViewModel.h"

@implementation ZWBaseViewModel
@synthesize request  = _request;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    ZWBaseViewModel *viewModel = [super allocWithZone:zone];
    
    if (viewModel) {
        
        [viewModel zw_initialize];
    }
    return viewModel;
}
- (instancetype)initWithModel:(id)model {
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (ZWRequest *)request {
    
    if (!_request) {
        
        _request = [ZWRequest request];
    }
    return _request;
}
- (void)zw_initialize {
    
}
-(NSString *)randomString:(NSInteger )num{
    char data[num];
    for (int x=0;x<num;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:num encoding:NSUTF8StringEncoding];
}
-(NSString *)convertToJsonData:(NSMutableDictionary *)parma{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parma options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}
-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
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
        ZWWLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
-(NSArray *)JSONArrStrTransFromJsonStr:(NSString *)jsonString;{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray * jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:nil];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
}


@end
