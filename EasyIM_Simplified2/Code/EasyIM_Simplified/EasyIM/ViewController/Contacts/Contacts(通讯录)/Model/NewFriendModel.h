//
//  NewFriendModel.h
//  EasyIM
//
//  Created by 栾士伟 on 2019/4/15.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NewFriendModel : NSObject

@property (nonatomic, copy)   NSString *fromID;
@property (nonatomic, copy)   NSString *fromName;
@property (nonatomic, copy)   NSString *fromNick;
@property (nonatomic, copy)   NSString *fromPhoto;
@property (nonatomic, copy)   NSString *toID;
@property (nonatomic, copy)   NSString *time;
@property (nonatomic, copy)   NSString *bulletinType;
@property (nonatomic, copy)   NSString *msg;
@property (nonatomic, copy)   NSString *groupID;

@end

NS_ASSUME_NONNULL_END
