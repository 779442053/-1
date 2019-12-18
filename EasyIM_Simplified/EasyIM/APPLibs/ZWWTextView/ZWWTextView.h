//
//  ZWWTextView.h
//  MyBaseProgect
//
//  Created by  on 2018/4/27.
//  Copyright © 2018年 . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZWWTextView : UITextView
@property(nonatomic,copy)NSString *placeholder;
@property (nonatomic, copy)void(^MessageTextTFChangeBlock)(NSString *TextStr);
/**
 *  构建方法
 */
+ (instancetype)textView;
@end
