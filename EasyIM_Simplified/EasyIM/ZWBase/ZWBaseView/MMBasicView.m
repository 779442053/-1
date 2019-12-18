//
//  MMBasicView.m
//  EasyIM
//
//  Created by momo on 2019/5/11.
//  Copyright © 2019年 Looker. All rights reserved.
//

#import "MMBasicView.h"

@implementation MMBasicView

+ (id)loadFromXibWithClass:(NSString *)string{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:string owner:nil options:nil];
    if (array && [array count]) {
        return array[0];
    }else {
        return nil;
    }
}

@end
