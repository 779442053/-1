//
//  GameViewController.m
//  EasyIM
//
//  Created by apple on 2019/8/20.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "GameViewController.h"

@interface GameViewController ()<UIWebViewDelegate>

@property(nonatomic,strong) UIWebView *cwebView;
@property(nonatomic,strong) UIProgressView *progressView;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"游戏"];
    [self initView];
    
    [self loadWebViewForUrl:@"https://m.16scvip.com/?agentURL=aHR0cHM6Ly93d3cuMTZzY3ZpcC5jb20v"];
}
//MARK: - initView
-(void)initView{
    [self.view addSubview:self.cwebView];
    [self.view addSubview:self.progressView];
}


//MARK: - 加载网页内容
-(void)loadWebViewForUrl:(NSString *_Nonnull)strUrl{
    [self.progressView setProgress:0 animated:NO];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
    manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    
    WEAKSELF
    [manager GET:strUrl
      parameters:nil
        progress:^(NSProgress * _Nonnull downloadProgress) {
            
            float pv = floorf(downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.progressView setProgress:pv animated:YES];
            });
      } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
          dispatch_async(dispatch_get_main_queue(), ^{
              [weakSelf.cwebView loadData:responseObject
                                 MIMEType:@"text/html"
                         textEncodingName:@"UTF-8"
                                  baseURL:strUrl.mj_url];
          });
      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          NSLog(@"加载异常！详见：%@",error);
      }];
}
//MARK: - lazy load
- (UIWebView *)cwebView{
    if (!_cwebView) {
        CGFloat h = G_SCREEN_HEIGHT - ZWStatusAndNavHeight - ZWTabbarHeight;
        _cwebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, h)];
        _cwebView.delegate = self;
        _cwebView.opaque = NO;
        _cwebView.scalesPageToFit = YES;
        _cwebView.backgroundColor = [UIColor whiteColor];
        
        //隐藏水平滚动条
        _cwebView.scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _cwebView;
}
- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, ZWStatusAndNavHeight, G_SCREEN_WIDTH, 1)];
        _progressView.progressViewStyle = UIProgressViewStyleBar;
        _progressView.tintColor = [UIColor colorWithHexString:@"#007bf3"];
        _progressView.progress = 0.f;
    }
    return _progressView;
}

//MARK: - UIWebViewDelegate
-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"加载开始");
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"加载完毕");
    [self.progressView setProgress:0.f animated:NO];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"加载失败！详见：%@",error);
    [self.progressView setProgress:0.f animated:NO];
}
@end
