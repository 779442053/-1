//
//  ListFriendModel.h
//  EasyIM
//
//  Created by 魏勇城 on 2019/2/22.
//  Copyright © 2019年 余谦. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListFriendModel : NSObject

@property (nonatomic, copy) NSNumber *section; //区
@property (nonatomic, copy) NSNumber *row; //列
@property (nonatomic, copy) NSString *userid; //数
@property (nonatomic, copy) NSString *userName; //名字

@end

NS_ASSUME_NONNULL_END
