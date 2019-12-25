//
//  SweepViewController.m
//  YouXun
//
//  Created by laouhn on 15/12/22.
//  Copyright © 2015年 Xboker. All rights reserved.
//

#import "SweepViewController.h"
//照片浏览
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
@interface SweepViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>{
   AVCaptureDevice *device;    //电灯对象
}

@property (nonatomic, strong) UIView *scanRectView;
@property (nonatomic, strong) AVCaptureDeviceInput *input;
@property (nonatomic, strong) AVCaptureMetadataOutput *output;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *preView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIButton *btnLight;         //电灯开关
///记录向上滑动最小边界
@property (nonatomic, assign) CGFloat minY;
///记录向下滑动最大边界
@property (nonatomic, assign) CGFloat maxY;
///扫描区域图片
@property (nonatomic, strong) UIImageView *imageV;
///扫描区域的横线是否是应该向上跑动
@property (nonatomic, assign) BOOL shouldUp;
@end

@implementation SweepViewController
- (void)viewWillAppear:(BOOL)animated {
    [self.session startRunning];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //电灯按钮设置为关
    self.btnLight.selected = NO;
    [self lightTenOnOff:NO];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat x = 0.f;
    CGFloat w = 0.f;
    CGFloat h = 0.f;
    CGFloat y = 0.f;
    CGRect rectWindow = [UIScreen mainScreen].bounds;
    //MARK: - 导航
    UIImageView *navImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rectWindow.size.width, 70)];
    navImg.backgroundColor = [UIColor blackColor];
    navImg.alpha = 0.45f;
    [self.view addSubview:navImg];
    //MARK:返回
    w = 24.f;
    h = 24.f;
    x = 10.f;
    y = 30.f;
    UIButton *btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
    btnBack.frame = CGRectMake(x, y, w, h);
    
    [btnBack addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"nav_back.png"] forState:UIControlStateNormal];
    [self.view addSubview:btnBack];
    
    //MARK:相册
    w = 44.f;
    h = 44.f;
    x = rectWindow.size.width - w - 10.f;
    y = 20.f;
    UIButton *btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPhoto.frame = CGRectMake(x, y, w, h);
    
    [btnPhoto addTarget:self action:@selector(btnPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    [btnPhoto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPhoto setTitle:@"相 册" forState:UIControlStateNormal];
    [self.view addSubview:btnPhoto];
    
    
    //MARK:标题
    w = 100.f;
    x = (rectWindow.size.width - w) / 2;
    UILabel *labTitle = [[UILabel alloc] initWithFrame:CGRectMake(x, 31.5, w, 21.f)];
    
    labTitle.text = @"扫一扫";
    labTitle.font = [UIFont systemFontOfSize:18];
    labTitle.textColor = [UIColor whiteColor];
    labTitle.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:labTitle];
    
    //MARK:开灯\关灯
    w = 60.f;
    h = w;
    x = (rectWindow.size.width - w) / 2;
    y = rectWindow.size.height - h - 10.f;
    
    _btnLight = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnLight.frame = CGRectMake(x, y, w, h);
    
    [_btnLight addTarget:self action:@selector(btnLightChange:) forControlEvents:UIControlEventTouchUpInside];
    [_btnLight setBackgroundImage:[UIImage imageNamed:@"message_light_off.png"] forState:UIControlStateNormal];
    [_btnLight setBackgroundImage:[UIImage imageNamed:@"message_light_on.png"] forState:UIControlStateSelected];
    
    [self.view addSubview:_btnLight];
    
    //扫码初始化
    [self sweepView];
    
    //最上层
    [self.view bringSubviewToFront:_btnLight];
    [self.view bringSubviewToFront:btnBack];
    [self.view bringSubviewToFront:btnPhoto];
}

//高亮状态
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


//MARK: - 返回
- (void)backAction:(UIButton *)sender {
    //present 进入
    if([self presentingViewController] != nil)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.navigationController popViewControllerAnimated:YES];
    //关闭扫码
    [self.session stopRunning];
}

//MARK: - 相册
- (void)btnPhotoAction:(UIButton *)sender {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(status != PHAuthorizationStatusAuthorized){
           dispatch_async(dispatch_get_main_queue(), ^{
               UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"请开启相册访问权限"
                                                                                message:nil
                                                                         preferredStyle:UIAlertControllerStyleAlert];
               UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
               [alertVC addAction:ok];
               [self presentViewController:alertVC animated:YES completion:nil];
           });
        }
        else{
            UIImagePickerController *imgPickerController = [[UIImagePickerController alloc] init];
            imgPickerController.delegate = self;
            imgPickerController.allowsEditing = YES;
            [imgPickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            imgPickerController.navigationBar.translucent = NO;
            imgPickerController.modalPresentationStyle = 0;
            //.edgesForExtendedLayout = UIEdgeInsetsMake(66, 0, 0, 0);
            //[imgPickerController.view setY:60];
            [self presentViewController:imgPickerController animated:YES completion:nil];
        }
    }];
}


//MARK: - UIImagePickerControllerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    NSLog(@"已取消");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    @autoreleasepool {
        UIViewController *parent = [self presentingViewController];
        
        if (info) {
            UIImage *img = [info objectForKey:UIImagePickerControllerOriginalImage];
            
            NSData *imgData = UIImagePNGRepresentation(img);
            CIImage *ciImg = [CIImage imageWithData:imgData];
            
            //创建探测器
            CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyLow}];
            NSArray *arrResult = [detector featuresInImage:ciImg];
            
             //结果处理
            if(arrResult == nil || arrResult.count <= 0){
                if(self.delegate == nil){
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"无法识别图片信息，请重新选择"
                                                                                   message:nil
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alertVC addAction:ok];
                    [self presentViewController:alertVC animated:YES completion:nil];
                }
                else{
                    [self.delegate sweepViewDidFinishError];
                }
                
                //进入到扫码界面
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            else{
                
                //系统处于铃声模式下扫描到结果会调用"卡擦"声音;
                AudioServicesPlaySystemSound(1305);
                
                //系统处于震动模式扫描到结果会震动一下;
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);

                //便利数组可以获取多个扫码结果(如果有多个)
                CIQRCodeFeature *result = [arrResult firstObject];
                NSString *content = result.messageString;
                content = [content stringByReplacingOccurrencesOfString:@"*" withString:@""];
                content = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                
                //扫描成功，关闭
                [self.delegate sweepViewDidFinishSuccess:content];
                [parent dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else{
            [self.delegate sweepViewDidFinishError];
            
            //进入到扫码界面
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}


//MARK: - 开灯\关灯
- (void)btnLightChange:(UIButton *)sender{
    
    BOOL isOn = YES;
    
    //关灯
    if(sender.isSelected) isOn = NO;
    
    [self lightTenOnOff:isOn];

    sender.selected = !sender.isSelected;
}

//电灯开关处理
- (void)lightTenOnOff:(BOOL)isOn{
    
    if(device == nil)
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [device lockForConfiguration:nil];
    
    if (![device isTorchModeSupported:AVCaptureTorchModeOff] && ![device isTorchModeSupported:AVCaptureTorchModeOn]) {
        NSLog(@"不支持该模式");
        return;
    }
    
    //关灯
    if(!isOn) [device setTorchMode: AVCaptureTorchModeOff];
    //开灯
    else [device setTorchMode: AVCaptureTorchModeOn];
    
    [device unlockForConfiguration];
}


//MARK: - 扫码相关事件
//扫描时从上往下跑动的线以及提示语
- (void)scanningAnimationWith:(CGRect) rect {
    CGFloat x = rect.origin.x;
    CGFloat y = rect.origin.y;
    CGFloat with = rect.size.width;
    CGFloat height = rect.size.height;
    self.imageV = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, with, 3)];
    self.imageV.image = [UIImage imageNamed:@"scanLine"];
    self.shouldUp = NO;
    [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(repeatAction) userInfo:nil repeats:YES];
    [self.view addSubview:self.imageV];
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(x, y + height, with, 30)];
    lable.text = @"请将扫描区域对准二维码";
    lable.textAlignment = NSTextAlignmentCenter;
    lable.textColor = [UIColor whiteColor];
    [self.view addSubview:lable];
}

- (void)repeatAction {
    CGFloat num = 1;
    if (self.shouldUp == NO) {
        self.imageV.frame = CGRectMake(CGRectGetMinX(self.imageV.frame), CGRectGetMinY(self.imageV.frame) + num, CGRectGetWidth(self.imageV.frame), CGRectGetHeight(self.imageV.frame));
        if (CGRectGetMaxY(self.imageV.frame) >= self.maxY) {
            self.shouldUp = YES;
        }
    }else {
        self.imageV.frame = CGRectMake(CGRectGetMinX(self.imageV.frame), CGRectGetMinY(self.imageV.frame) - num, CGRectGetWidth(self.imageV.frame), CGRectGetHeight(self.imageV.frame));
        if (CGRectGetMinY(self.imageV.frame) <= self.minY) {
            self.shouldUp = NO;
        }
    }
}

//获取扫描区域的坐标
- (void)getCGRect:(CGRect)rect {
    CGFloat with = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat w = CGRectGetWidth(rect);
    CGFloat h = CGRectGetHeight(rect);
    [self creatFuzzyViewWith:CGRectMake(0, 0, with, y)];
    [self creatFuzzyViewWith:CGRectMake(0, y, x, h)];
    [self creatFuzzyViewWith:CGRectMake(x + w, y, with - x - w, h)];
    [self creatFuzzyViewWith:CGRectMake(0, y + h, with, height - h - y)];
}

//创建扫描区域之外的模糊效果
- (void)creatFuzzyViewWith :(CGRect)rect {
    UIView *view11 = [[UIView alloc] initWithFrame:rect];
    view11.backgroundColor = [UIColor blackColor];
    view11.alpha = 0.4;
    [self.view addSubview:view11];
}

- (void)sweepView {
    //获取摄像设备
    self->device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //创建输入流
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self->device error:nil];
    
    //创建输出流
    self.output = [[AVCaptureMetadataOutput alloc] init];
    
    //设置代理,在主线程里面刷新
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化连接对象
    self.session = [[AVCaptureSession alloc]init];
    
    //高质量采集率
    [self.session setSessionPreset:(ScreenHeight<500?AVCaptureSessionPreset640x480:AVCaptureSessionPresetHigh)];
    
    //链接对象添加输入流和输出流
    [self.session addInput:self.input];
    [self.session addOutput:self.output];
    
    //AVMetadataMachineReadableCodeObject对象从QR码生成返回这个常数作为他们的类型
    //设置扫码支持的编码格式(设置条码和二维码兼容扫描)
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    //自定义取景框
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    CGSize scanSize = CGSizeMake(windowSize.width*3/4, windowSize.width*3/4);
    CGRect scanRect = CGRectMake((windowSize.width-scanSize.width)/2, (windowSize.height-scanSize.height)/2, scanSize.width, scanSize.height);
    NSLog(@"%.f----%.f---%.f----%.f", scanRect.origin.x, scanRect.origin.y, scanRect.size.width, scanRect.size.height);
    
    /**
     *  横线开始上下滑动
     */
    [self scanningAnimationWith:scanRect];
   
    //创建周围模糊区域
    [self getCGRect:scanRect];
    
    self.minY = CGRectGetMinY(scanRect);
    self.maxY = CGRectGetMaxY(scanRect);

    
    //计算rectOfInterest 注意x,y交换位置
    scanRect = CGRectMake(scanRect.origin.y/windowSize.height, scanRect.origin.x/windowSize.width, scanRect.size.height/windowSize.height,scanRect.size.width/windowSize.width);
    self.output.rectOfInterest = scanRect;
    
    self.scanRectView = [UIView new];
    [self.view addSubview:self.scanRectView];
    self.scanRectView.frame = CGRectMake(0, 0, scanSize.width, scanSize.height);
    self.scanRectView.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));

    self.scanRectView.layer.borderWidth = 1;
    self.output.rectOfInterest = scanRect;
    self.preView = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preView.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preView.frame = [UIScreen mainScreen].bounds;
    [self.view.layer insertSublayer:self.preView atIndex:0];
    
}

//MARK: - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    //系统处于铃声模式下扫描到结果会调用"卡擦"声音;
    AudioServicesPlaySystemSound(1305);
    
    //系统处于震动模式扫描到结果会震动一下;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    //为零表示没有捕捉到信息,返回重新捕捉
    if (metadataObjects.count == 0) {
        return;
    }
    
    //不为零则为捕捉并成功存储了二维码
    if (metadataObjects.count > 0) {
        [self.session stopRunning];
        
        AVMetadataMachineReadableCodeObject *currentMetadataObject = metadataObjects.firstObject;
        
        //输出扫描字符串(去掉空格 和 *号)
        NSString *strQrCode = currentMetadataObject.stringValue;
        strQrCode = [strQrCode stringByReplacingOccurrencesOfString:@"*" withString:@""];
        strQrCode = [strQrCode stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self.delegate sweepViewDidFinishSuccess:strQrCode];
        strQrCode = nil;
    }
    else{
        [self.delegate sweepViewDidFinishError];
    }
    
    //关闭当前界面
    [self backAction:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
