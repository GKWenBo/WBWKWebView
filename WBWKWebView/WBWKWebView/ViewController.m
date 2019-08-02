//
//  ViewController.m
//  WBWKWebView
//
//  Created by Mr_Lucky on 2018/8/28.
//  Copyright © 2018年 wenbo. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "WKWebView+WBAdditional.h"
#import "WKWebView+WBMetaParser.h"
#import "WKWebView+WBJavaScript.h"
#import "WKWebView+WBLoadInfo.h"

@interface ViewController () <WKNavigationDelegate>

{
    UIScrollView *_scollView;
    WKWebView *_wkWebView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _scollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    _scollView.scrollEnabled = YES;
    [self.view addSubview:_scollView];
    
    [self initWKWebView];
}

- (void)initWKWebView {
    _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
    _wkWebView.scrollView.scrollEnabled = NO;
    _wkWebView.scrollView.bounces = NO;
    /*  < 设置代理 > */
//    _wkWebView.UIDelegate = self;
    _wkWebView.navigationDelegate = self;
    /*  < 开启前进后退滑动手势 > */
    [_wkWebView wb_allowsBackForwardNavigationGestures];
    
    [_scollView addSubview:_wkWebView];
    
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForAuxiliaryExecutable:@"test.html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.8.247"]];
    [_wkWebView loadRequest:request];
    
    __weak typeof(self) weakSelf = self;
    _wkWebView.wb_wkWebViewLoadInfoBlock = ^(double estimatedProgress, CGSize contentSize, WKWebView *wkWebView) {
        __strong typeof(self) strongSelf = weakSelf;
        NSLog(@"contentSize = %@",NSStringFromCGSize(contentSize));
        NSLog(@"estimatedProgress = %f",estimatedProgress);
        if (estimatedProgress == 1.f) {
            CGRect frame = strongSelf -> _wkWebView.frame;
            frame.size.height = contentSize.height;
            strongSelf -> _wkWebView.frame = frame;
            strongSelf -> _scollView.contentSize = contentSize;
        }
    };
}

// MARK:WKNavigationDelegate
/** < 加载完成 > */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"didFinishNavigation = %@",NSStringFromCGSize(webView.scrollView.contentSize));
    [webView evaluateJavaScript:@"document.body.offsetHeight"
              completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                  NSLog(@"document.body.offsetHeight = %f",[result floatValue]);
              }];
    // !!!:获取网页所有元素
    [webView wb_getMetaData:^(id metaData) {
        NSLog(@"网页元素 = %@",metaData);
    }];

    // !!!:获取某个节点个数
    [webView wb_nodeCountOfTag:@"img"
              completedHandler:^(int tagCount) {
                  NSLog(@"节点个数 = %d",tagCount);
              }];

    // !!!:获取当前页地址
    [webView wb_getCurrentURL:^(NSString *url) {
        NSLog(@"当前地址 = %@",url);
    }];

    // !!!:当前标题
    [webView wb_getCurrentTitle:^(NSString *title) {
        NSLog(@"当前标题 = %@",title);
    }];

    // !!!:获取网页中的图片
    [webView wb_getImages:^(NSArray *images) {
        NSLog(@"所有图片 = %@",images);
    }];

    // !!!:设置网页背景色
    [webView wb_setWebBackgroudColor:[UIColor orangeColor]];

    // !!!:图片添加点击事件
    [webView wb_addClickEventOnImg];

}

/** < 判断链接是否允许跳转 > */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeOther) {
        if ([navigationAction.request.URL.absoluteString hasPrefix:@"img"]) {
            NSString *imageUrl = [navigationAction.request.URL.absoluteString substringFromIndex:@"img".length];
            NSLog(@"imageUrl = %@",imageUrl);
            
            /** < 查看网页大图 > */
            
            decisionHandler(WKNavigationActionPolicyAllow);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
