//
//  WBWKWebView.m
//  WBWKWebView
//
//  Created by wenbo on 2021/1/25.
//  Copyright © 2021 wenbo. All rights reserved.
//

#import "WBWKWebView.h"
#import "UIProgressView+WBWebKit.h"

@interface WBWKWebView ()

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation WBWKWebView
{
    NSURL *_URL;
    NSURLRequest *_request;
    WKWebViewConfiguration *_configuration;
    NSString *_HTMLString;
    NSURL *_baseURL;
}

- (void)dealloc {
    if (self.webView) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.webView removeObserver:self forKeyPath:@"title"];
    }
}

- (instancetype)initWithUrlString:(NSString *)string {
    return [self initWithURL:[NSURL URLWithString:string]];
}

- (instancetype)initWithURL:(NSURL *)url {
    if (self = [self initWithFrame:CGRectZero]) {
        _URL = url;
        
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request {
    if (self = [self initWithFrame:CGRectZero]) {
        _request = request;
        
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)URL configuration:(WKWebViewConfiguration *)configuration {
    if (self = [self initWithURL:URL]) {
        _configuration = configuration;
    }
    return self;
}

- (instancetype)initWithRequest:(NSURLRequest *)request configuration:(WKWebViewConfiguration *)configuration {
    if (self = [self initWithRequest:request]) {
        _request = request;
        _configuration = configuration;
    }
    return self;
}

- (instancetype)initWithHTMLString:(NSString *)HTMLString baseURL:(NSURL * _Nullable)baseURL {
    if (self = [self initWithFrame:CGRectZero]) {
        _HTMLString = HTMLString;
        _baseURL = baseURL;
        
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializer];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initializer];
    [self setupSubViews];
}

- (void)initializer {
    _timeoutInternal = 30;
    _cachePolicy = NSURLRequestReloadRevalidatingCacheData;
}

- (void)setupSubViews {
    [self addSubview:self.webView];
    [self addSubview:self.progressView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.topAnchor constant:0],
        [self.webView.leftAnchor constraintEqualToAnchor:self.leftAnchor constant:0],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:0],
        [self.webView.rightAnchor constraintEqualToAnchor:self.rightAnchor constant:0],
        
        /// progressView
        [self.progressView.topAnchor constraintEqualToAnchor:self.webView.topAnchor constant:0],
        [self.progressView.leftAnchor constraintEqualToAnchor:self.webView.leftAnchor constant:0],
        [self.progressView.rightAnchor constraintEqualToAnchor:self.webView.rightAnchor constant:0],
        [self.progressView.heightAnchor constraintEqualToConstant:2],
    ]];
    
    if (_request) {
        [self loadURLRequest:_request];
    } else if (_URL) {
        [self loadURL:_URL];
    } else if (_HTMLString) {
        [self loadHTMLString:_HTMLString baseURL:_baseURL];
    } else {
        
    }
}

// MARK: - Public Method
- (void)loadURL:(NSURL *)URL {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.timeoutInterval = _timeoutInternal;
    request.cachePolicy = _cachePolicy;
    [self.webView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)HTMLString baseURL:(NSURL *)baseURL {
    _HTMLString = HTMLString;
    _baseURL = baseURL;
    
    [self.webView loadHTMLString:HTMLString baseURL:baseURL];
}

- (void)getMaxDocumentBodyScrollHeight:(void (^)(CGFloat height))completedHandler {
    [self.webView evaluateJavaScript:@"document.readyState" completionHandler:^(id _Nullable complete, NSError * _Nullable error) {
        if (complete) {
            /// 获取最大高度
            [self.webView evaluateJavaScript:@"Math.max(document.body.scrollHeight, document.body.offsetHeight, document.documentElement.clientHeight, document.documentElement.scrollHeight, document.documentElement.offsetHeight)" completionHandler:^(id _Nullable height, NSError * _Nullable error) {
                if (height) {
                    !completedHandler ?: completedHandler([height floatValue]);
                } else {
                    !completedHandler ?: completedHandler(0);
                }
            }];
        }
    }];
}

- (void)reloadData {
    [self.webView reload];
}

// MARK: - Private Method
- (void)loadURLRequest:(NSURLRequest *)request {
    [self.webView loadRequest:request];
}

// MARK: - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"title"]) {
        if (self.webTitleChangeBlock) {
            self.webTitleChangeBlock(self.webView.title);
        }
    } else if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float progress = [change[NSKeyValueChangeNewKey] floatValue];
        if (progress >= self.progressView.progress) {
            [self.progressView setProgress:progress animated:YES];
        } else {
            [self.progressView setProgress:progress animated:NO];
        }
        if (self.estimatedProgressBlock) {
            self.estimatedProgressBlock(progress);
        }
    }
}

// MARK: - getter && setter
- (WKWebView *)webView {
    if (!_webView) {
        WKWebViewConfiguration *config = _configuration;
        if (!config) {
            config = [[WKWebViewConfiguration alloc] init];
            config.preferences.minimumFontSize = 9.0;
            config.preferences.javaScriptEnabled = YES;
            
            WKUserContentController *userController = config.userContentController;
            if (!userController) {
                userController = [[WKUserContentController alloc] init];
            }
            NSMutableString *scriptString = [[NSMutableString alloc] initWithString:@"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"];
            WKUserScript *script = [[WKUserScript alloc] initWithSource:scriptString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
            [userController addUserScript:script];
            
            if ([config respondsToSelector:@selector(setAllowsInlineMediaPlayback:)]) {
                [config setAllowsInlineMediaPlayback:YES];
            }
            if (@available(iOS 9.0, *)) {
                if ([config respondsToSelector:@selector(setApplicationNameForUserAgent:)]) {

                [config setApplicationNameForUserAgent:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]];
                }
            } else {
                // Fallback on earlier versions
            }
            
            if (@available(iOS 10.0, *)) {
                if ([config respondsToSelector:@selector(setMediaTypesRequiringUserActionForPlayback:)]){
                    [config setMediaTypesRequiringUserActionForPlayback:WKAudiovisualMediaTypeNone];
                }
            } else if (@available(iOS 9.0, *)) {
               if ( [config respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)]) {
                    [config setRequiresUserActionForMediaPlayback:NO];
               }
            } else {
                if ( [config respondsToSelector:@selector(setMediaPlaybackRequiresUserAction:)]) {
                    [config setMediaPlaybackRequiresUserAction:NO];
                }
            }
        }
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.backgroundColor = [UIColor clearColor];
        _webView.scrollView.backgroundColor = [UIColor clearColor];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
        _progressView.wb_hiddenWhenProgressApproachFullSize = YES;
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = UIColor.orangeColor;
        _progressView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _progressView;
}

- (BOOL)canGoBack {
    return self.webView.canGoBack;
}

- (void)setShowProgress:(BOOL)showProgress {
    _showProgress = showProgress;
    
    if (showProgress) {
        _progressView.hidden = NO;
    } else {
        _progressView.wb_hiddenWhenProgressApproachFullSize = NO;
        _progressView.hidden = YES;
    }
}

@end
