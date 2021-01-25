//
//  WBWKWebView.h
//  WBWKWebView
//
//  Created by wenbo on 2021/1/25.
//  Copyright © 2021 wenbo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WBWKWebView : UIView

@property (nonatomic, strong, readonly) WKWebView *webView;
@property (nonatomic, strong, readonly) UIProgressView *progressView;

/// Cache policy.
@property(assign, nonatomic) NSURLRequestCachePolicy cachePolicy;
/// Time out internal.
@property(assign, nonatomic) NSTimeInterval timeoutInternal;
@property (nonatomic, strong, readonly) NSURL *URL;

/// 显示加载进度
@property (nonatomic, assign) BOOL showProgress;

@property (nonatomic, assign, readonly) BOOL canGoBack;

@property (nonatomic, copy) void (^webTitleChangeBlock)(NSString *title);
@property (nonatomic, copy) void (^estimatedProgressBlock)(float progress);

- (instancetype)initWithUrlString:(NSString *)string;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithRequest:(NSURLRequest *)request;
- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration;
- (instancetype)initWithRequest:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration;
- (instancetype)initWithHTMLString:(NSString *)HTMLString baseURL:(NSURL * _Nullable)baseURL;

/// 加载URL地址
/// @param URL 网页地址
- (void)loadURL:(NSURL *)URL;

/// 加载网页文本
/// @param HTMLString 网页文本
/// @param baseURL baseURL description
- (void)loadHTMLString:(NSString *)HTMLString baseURL:(nullable NSURL *)baseURL;

/// 获取网页内容最大高度，注意在网页didFinish时调用
/// @param completedHandler completedHandler description
- (void)getMaxDocumentBodyScrollHeight:(void (^)(CGFloat height))completedHandler;

- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
