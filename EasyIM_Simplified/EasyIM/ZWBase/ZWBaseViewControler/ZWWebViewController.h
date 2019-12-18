//
//  ZWWebViewController.h
//  EasyIM
//
//  Created by step_zhang on 2019/11/21.
//  Copyright © 2019 Looker. All rights reserved.
//

#import "MMBaseViewController.h"
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface ZWWebViewController : MMBaseViewController
/**
 webView
 */
@property(nonatomic, strong) WKWebView *wkwebView;

/**
 JS 注册
 */
@property(nonatomic,strong) WKUserContentController * userContentController;
/**
 *  origin url
 */
@property (nonatomic)NSString* url;

/**
 *  embed webView
 */
//@property (nonatomic)UIWebView* webView;

/**
 *  tint color of progress view
 */
@property (nonatomic)UIColor* progressViewColor;

/**
 *  get instance with url
 *
 *  @param url url
 *
 *  @return instance
 */
-(instancetype)initWithUrl:(NSString *)url;


-(void)reloadWebView;
@end

NS_ASSUME_NONNULL_END
