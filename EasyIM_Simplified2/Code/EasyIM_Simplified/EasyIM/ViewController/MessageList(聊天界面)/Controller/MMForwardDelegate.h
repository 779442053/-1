//
//  MMForwardDelegate.h
//  EasyIM
//
//  Created by momo on 2019/7/12.
//  Copyright © 2019 Looker. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MMForwardDelegate <NSObject>

- (void)didSelectArr:(NSMutableArray *)arr;

@end

NS_ASSUME_NONNULL_END
