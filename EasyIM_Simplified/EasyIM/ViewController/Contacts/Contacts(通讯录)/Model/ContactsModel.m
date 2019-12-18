//
//  ContactsModel.m
//  EasyIM
//
//  Created by momo on 2019/4/15.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import "ContactsModel.h"

@implementation ContactsModel

-(NSString *)userName{
    return [_userName stringByRemovingPercentEncoding];
}

-(NSString *)remarkName{
    return [_remarkName stringByRemovingPercentEncoding];
}

-(NSString *)nickName{
    return [_nickName stringByRemovingPercentEncoding];
}

-(NSString *)getName{
    NSString *strInfo = self.remarkName;
    if (!strInfo.checkTextEmpty) {
        strInfo = self.nickName;
    }
    if (!strInfo.checkTextEmpty) {
        strInfo = self.userName;
    }
    
    return strInfo;
}

@end
