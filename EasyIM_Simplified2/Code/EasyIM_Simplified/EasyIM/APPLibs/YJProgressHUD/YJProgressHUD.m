//


#import "YJProgressHUD.h"
//#import "AppDelegate.h"
#import "AppDelegate+ZWAppDelegate.h"
// 背景视图的宽度/高度
#define BGVIEW_WIDTH 100.0f
// 文字大小
#define TEXT_SIZE    16.0f

@implementation YJProgressHUD

+ (instancetype)sharedHUD {
    static id hud;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hud = [[self alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    });
    return hud;
}

+ (void)showStatus:(YJProgressHUDStatus)status text:(NSString *)text {
    YJProgressHUD *HUD = [YJProgressHUD sharedHUD];
    HUD.customView.backgroundColor = [UIColor blackColor];
    [HUD show:YES];
    [HUD setShowNow:YES];
    //蒙版显示 YES , NO 不显示
    //HUD.dimBackground = YES;
    HUD.labelText = text;
    HUD.labelColor = [UIColor whiteColor];
    [HUD setRemoveFromSuperViewOnHide:YES];
    HUD.labelFont = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    [HUD setMinSize:CGSizeMake(BGVIEW_WIDTH, BGVIEW_WIDTH)];
//    AppDelegate *appdelete = [AppDelegate shareAppDelegate];
//    [appdelete.window addSubview:HUD];
//    UIViewController *vc = [appdelete getCurrentUIVC];
//    [vc.view addSubview:HUD];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:HUD];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"YJProgressHUD" ofType:@"bundle"];
    
    switch (status) {
        case YJProgressHUDStatusSuccess: {
            NSString *sucPath = [bundlePath stringByAppendingPathComponent:@"MBHUD_Success.png"];
            UIImage *sucImage = [UIImage imageWithContentsOfFile:sucPath];
            HUD.mode = MBProgressHUDModeCustomView;
            UIImageView *sucView = [[UIImageView alloc] initWithImage:sucImage];
            HUD.customView = sucView;
            //[HUD hideAnimated:YES afterDelay:1.5f];
            [HUD hide:YES afterDelay:1.5f];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HUD setShowNow:NO];
                [HUD hide:YES];
            });
        }
            break;
        case YJProgressHUDStatusError: {
            NSString *errPath = [bundlePath stringByAppendingPathComponent:@"MBHUD_Error.png"];
            UIImage *errImage = [UIImage imageWithContentsOfFile:errPath];
            HUD.mode = MBProgressHUDModeCustomView;
            UIImageView *errView = [[UIImageView alloc] initWithImage:errImage];
            HUD.customView = errView;
            [HUD hide:YES afterDelay:1.5f];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HUD setShowNow:NO];
                 [HUD hide:YES];
            });
        }
            break;
            
        case YJProgressHUDStatusLoading: {
            HUD.mode = MBProgressHUDModeIndeterminate;
        }
            break;
            
            
        case YJProgressHUDStatusWaitting: {
            NSString *infoPath = [bundlePath stringByAppendingPathComponent:@"MBHUD_Warn.png"];
            UIImage *infoImage = [UIImage imageWithContentsOfFile:infoPath];
            
            HUD.mode = MBProgressHUDModeCustomView;//自定义视图
            UIImageView *infoView = [[UIImageView alloc] initWithImage:infoImage];
            HUD.customView = infoView;
            [HUD hide:YES afterDelay:1.5f];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HUD setShowNow:NO];
                 [HUD hide:YES];
            });

        }
            break;
            
        case YJProgressHUDStatusInfo: {
            
            NSString *infoPath = [bundlePath stringByAppendingPathComponent:@"MBHUD_Info.png"];
            UIImage *infoImage = [UIImage imageWithContentsOfFile:infoPath];
            
            HUD.mode = MBProgressHUDModeCustomView;
            UIImageView *infoView = [[UIImageView alloc] initWithImage:infoImage];
            HUD.customView = infoView;
            [HUD hide:YES afterDelay:1.5f];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [HUD setShowNow:NO];
                 [HUD hide:YES];
            });
        }
            break;
            
        default:
            break;
    }
}

+ (void)showMessage:(NSString *)text {
    YJProgressHUD *HUD = [YJProgressHUD sharedHUD];
    [HUD show:YES];
    [HUD setShowNow:YES];
    HUD.labelText = text;
    HUD.labelColor=[UIColor whiteColor];
    [HUD setMinSize:CGSizeZero];
    [HUD setMode:MBProgressHUDModeText];
    //    HUD.dimBackground = YES;
    [HUD setRemoveFromSuperViewOnHide:YES];
    HUD.labelFont = [UIFont boldSystemFontOfSize:TEXT_SIZE];
    AppDelegate *appdelete = [AppDelegate shareAppDelegate];
    UIViewController *vc = [appdelete getCurrentUIVC];
    [vc.view addSubview:HUD];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[YJProgressHUD sharedHUD] setShowNow:NO];
        [[YJProgressHUD sharedHUD] hide:YES];
    });
}

+ (void)showWaiting:(NSString *)text {
    
    [self showStatus:YJProgressHUDStatusWaitting text:text];
}

+ (void)showError:(NSString *)text {
    
    [self showStatus:YJProgressHUDStatusError text:text];
}

+ (void)showSuccess:(NSString *)text {
    
    [self showStatus:YJProgressHUDStatusSuccess text:text];
}

+ (void)showLoading:(NSString *)text {
    
    [self showStatus:YJProgressHUDStatusLoading text:text];
}

+ (void)hideHUD {
    [[YJProgressHUD sharedHUD] setShowNow:NO];
    [[YJProgressHUD sharedHUD] hide:YES];
}


@end
