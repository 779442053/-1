//
//  SweepViewController.h
//  YouXun
//
//  Created by laouhn on 15/12/22.
//  Copyright © 2015年 Xboker. All rights reserved.
//

#import <UIKit/UIKit.h>

//MARK: - SweepViewControllerDelegate
@protocol SweepViewControllerDelegate<NSObject>

/**
 * 扫描成功
 * id sweepResult 扫描结果
 */
-(void)sweepViewDidFinishSuccess:(id)sweepResult;

/**
 * 扫描失败
 */
-(void)sweepViewDidFinishError;

@end


//MARK: - SweepViewController
/**
 * 二维码\条形码扫描
 */
@interface SweepViewController : UIViewController{}

/**
 * 需要指定委托
 */
@property (nonatomic, weak) id<SweepViewControllerDelegate> delegate;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
