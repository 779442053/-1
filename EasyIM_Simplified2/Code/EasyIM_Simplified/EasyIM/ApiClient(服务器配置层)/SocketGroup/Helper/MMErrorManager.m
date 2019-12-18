//
//  MMErrorManager.m
//  EasyIM
//
//  Created by momo on 2019/4/16.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMErrorManager.h"

@implementation MMErrorManager

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode {
    NSString *errorMessage;
    
    switch (errorCode) {
        case 1:
            errorMessage = MM_REQUEST_ERROR;
            errorCode = 1001;
            break;
        case 2:
            errorMessage = MM_REQUEST_PARAM_ERROR;
            errorCode = 1002;
            break;
        case 3:
            errorMessage = MM_REQUEST_TIMEOUT;
            errorCode = 1003;
            break;
        case 4:
            errorMessage = MM_SERVER_MAINTENANCE_UPDATES;
            errorCode = 1004;
            break;
        case 2001:
            errorMessage = MM_NETWORK_DISCONNECTED;
            break;
        case 2002:
            errorMessage = MM_LOCAL_REQUEST_TIMEOUT;
            break;
        case 2004:
            errorMessage = MM_JSON_PARSE_ERROR;
            break;
        case 2003:
            errorMessage = MM_LOCAL_PARAM_ERROR;
            break;
        default:
            break;
    }
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
}


@end
