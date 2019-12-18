//
//  RegisterViewController.h
//  EasyIM
//
//  Created by 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 用户注册
 */
@interface RegisterViewController : MMBaseViewController


/**
 注册成功回调
 @param strPhone 手机号
 @param strPwd   密码(没有加密)
 */
@property(nonatomic,copy) void(^registerFinish)(NSString *_Nonnull strPhone,NSString *_Nonnull strPwd);

@end

NS_ASSUME_NONNULL_END
