//
//  MMCommonModel.h
//  EasyIM
//
//  Created by momo on 2019/7/12.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMCommonModel : NSObject

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *photoUrl;

@property (nonatomic, assign) BOOL isSelect;

@end

NS_ASSUME_NONNULL_END
