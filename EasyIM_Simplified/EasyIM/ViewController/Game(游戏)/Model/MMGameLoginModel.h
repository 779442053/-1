//
//  MMGameLoginModel.h
//  EasyIM
//
//  Created by momo on 2019/9/10.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MMDgLogin,MMRransferDg;
@interface MMGameLoginModel : NSObject

@property (nonatomic, strong) MMDgLogin *dgLogin;
@property (nonatomic, strong) MMRransferDg *transferDg;

@property (nonatomic, assign) double amount;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *winLimit;


@end


@interface MMDgLogin : NSObject

//"codeId": 0,
//"token": "218eb4101cfc4237b3c40b94cab53275",
//"lang": "cn",
//"random": "OCTqkcstuu",
//"list": [
//         "https://a.2023168.com/?token=",
//         "https://dg-asia.873271.com/wap/index.html?token=",
//         "http://app.wechat668.com/download/cn.html?t="
//         ]

@property (nonatomic, assign) NSInteger codeId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *lang;
@property (nonatomic, copy) NSString *random;
@property (nonatomic, strong) NSArray *list;

@end

@class MMMemberData;
@interface MMRransferDg : NSObject


//    "codeId": 0,
//    "token": "762f3fc9aced713f5a019cea88f8340e",
//    "random": "GzibHSkjJy",
//    "data": "20190906172359MT0ky",
//    "member": {
//        "username": "DGAPP1",
//        "balance": 101
//    }

@property (nonatomic, assign) NSInteger codeId;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *random;
@property (nonatomic, copy) NSString *data;
@property (nonatomic, strong) MMMemberData *member;

@end

@interface MMMemberData : NSObject

@property (nonatomic, copy) NSString *username;
@property (nonatomic, assign) double balance;

@end


