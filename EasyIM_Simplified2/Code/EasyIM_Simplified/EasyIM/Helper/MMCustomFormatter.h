//
//  MMCustomFormatter.h
//  EasyIM
//
//  Created by momo on 2019/5/30.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDLog.h"


NS_ASSUME_NONNULL_BEGIN

@interface MMCustomFormatter : NSObject<DDLogFormatter>

+(instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
