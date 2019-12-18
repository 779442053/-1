//
//  MMEmotion.m
//  EasyIM
//
//  Created by momo on 2019/4/22.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMEmotion.h"

@implementation MMEmotion

- (BOOL)isEqual:(MMEmotion *)emotion
{
    return [self.face_name isEqualToString:emotion.face_name] || [self.code isEqualToString:emotion.code];
}

@end
