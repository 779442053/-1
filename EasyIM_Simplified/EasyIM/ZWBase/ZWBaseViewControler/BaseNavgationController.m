//


////在这里,将系统的导航栏隐藏,显示出来自己定义的导航栏
#import "BaseNavgationController.h"


@interface BaseNavgationController ()<UINavigationControllerDelegate>

@end

@implementation BaseNavgationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationBar.hidden = YES;
}
-(void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion{
    ZWWLog(@"基类 拦截带有导航的present 方法==基类 拦截带有导航的present 方法")
    viewControllerToPresent.modalPresentationStyle = 0;
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

//push时隐藏tabbar
-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
    [self.view endEditing:YES];//无论push还是pop  都将当前界面的键盘消失
    //拦截push进来的控制器.在这里拿到控制器进行控制器的布局
}
// 是否支持自动转屏
- (BOOL)shouldAutorotate
{
    return [self.visibleViewController shouldAutorotate];
}
// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.visibleViewController supportedInterfaceOrientations];
}
// 默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
