//
//  FindPwdViewController.h
//  EasyIM
//rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 找回密码
 */
@interface FindPwdViewController : MMBaseViewController

/** 找回密码成功回调 */
@property(nonatomic,copy) void(^findPwdFinish)(NSString *_Nonnull strPhone,NSString *_Nonnull strPwd);
@end

NS_ASSUME_NONNULL_END
