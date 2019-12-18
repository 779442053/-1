//
//  MMClassListModel.h
//  EasyIM
//
//  Created by momo on 2019/7/8.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MMClassListModel : NSObject

@property (nonatomic, assign) NSInteger classListId;
@property (nonatomic, assign) NSInteger gid;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *c_time;
@property (nonatomic, copy) NSString *info;
@property (nonatomic, copy) NSString *userid;
@property (nonatomic, copy) NSString *fileurl;

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *userImage;

@end

NS_ASSUME_NONNULL_END
