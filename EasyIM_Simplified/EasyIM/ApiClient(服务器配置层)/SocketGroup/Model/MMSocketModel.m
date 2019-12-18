//
//  MMSocketModel.m
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMSocketModel.h"

@implementation MMSocketModel

- (NSString *)socketModelToJSONString {
    NSAssert(self.body != nil, @"Argument must be non-nil");
    if (![self.body isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString *bodyString = [self dictionnaryObjectToString:self.body];
    self.body = (NSDictionary *)bodyString;
    NSString *jsonString = [self toJSONString];
    jsonString = [jsonString stringByAppendingString:@"\r\n"];
    return jsonString;
}

- (NSString *)dictionnaryObjectToString:(NSDictionary *)object {
    NSError *error = nil;
    NSData *stringData =
    [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    // 字典对象用系统JSON序列化之后的data，转UTF-8后的jsonString里面会包含"\n"及" "，需要替换掉
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return jsonString;
}

@end
