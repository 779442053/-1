//
//  SHBCustomTextField.h
//  SaleTool
//
//  Created by ganshiwei on 16/10/31.
//  Copyright © 2016年 rongkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANCustomTextFieldDelegate <NSObject>

- (void)textFieldRightViewDidSelect:(UITextField *)textField selected:(BOOL)seleted;

@end

@interface ANCustomTextField : UITextField

@property (assign, nonatomic) BOOL hasBorder;
@property (assign, nonatomic) BOOL hasBottomBorder;
@property (assign, nonatomic) CGFloat leftPadding;
@property (strong, nonatomic) UIImage *rightNormalImage;
@property (strong, nonatomic) UIImage *rightSelectedImage;
@property (strong, nonatomic) UIImage *leftNormalImage;
@property (strong, nonatomic) UILabel *bottomLine;

@property (weak, nonatomic) IBOutlet id<ANCustomTextFieldDelegate> p_delegate;

@end
