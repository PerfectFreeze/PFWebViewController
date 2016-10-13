//
//  PFWebViewController.m
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "PFWebViewController.h"
#import "PFWebViewNavigationHeader.h"
#import "PFWebViewToolBar.h"
#import <WebKit/WebKit.h>

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface PFWebViewController () <PFWebViewToolBarDelegate,WKNavigationDelegate,WKScriptMessageHandler> {
    BOOL isNavigationBarHidden;
    BOOL isReaderMode;
    
    NSString *readerHTMLString;
    NSString *readerArticleTitle;
}

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *webMaskView;
@property (nonatomic, strong) CALayer *maskLayer;

@property (nonatomic, strong) WKWebView *readerWebView;
@property (nonatomic, strong) PFWebViewNavigationHeader *navigationHeader;
@property (nonatomic, strong) PFWebViewToolBar *toolbar;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation PFWebViewController

#pragma mark - Life Cycle

- (id)initWithURL:(NSURL *)url {
    
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    
    self = [super init];
    if (self) {
        self.url = url;
        self.progressBarColor = [UIColor blackColor];
    }
    return self;
}

- (id)initWithURLString:(NSString *)urlString {
    
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
        self.progressBarColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [WebConsole enable];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.navigationHeader];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.progressView];

    [self setupReaderMode];
    [self.toolbar setup];
    
    [self loadWebContent];
}

- (void)loadWebContent {
    if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
        return;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.navigationController) {
        isNavigationBarHidden = self.navigationController.navigationBar.hidden;
        [self.navigationController setNavigationBarHidden:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [self.webView removeObserver:self forKeyPath:@"URL"];
    
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:isNavigationBarHidden];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    
    self.webView.frame = CGRectMake(0, self.offset + 20.5f, SCREENWIDTH, SCREENHEIGHT - 50.5f - 20.5f - self.offset);
    self.navigationHeader.frame = CGRectMake(0, 0, SCREENWIDTH, self.offset + 20.5f);
    self.toolbar.frame = CGRectMake(0, SCREENHEIGHT - 50.5f, SCREENWIDTH, 50.5f);
    self.progressView.frame = CGRectMake(0, 19 + self.offset, SCREENWIDTH, 2);
    
    self.webMaskView.frame = self.webView.frame;
    self.readerWebView.frame = self.webView.frame;
    self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, self.maskLayer.bounds.size.height);
}

#pragma mark - Lazy Initialize

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.offset + 20.5f, SCREENWIDTH, SCREENHEIGHT - 50.5f - 20.5f - self.offset) configuration:[self configuration]];
        _webView.allowsBackForwardNavigationGestures = YES;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIView *)webMaskView {
    if (!_webMaskView) {
        _webMaskView = [[UIView alloc] initWithFrame:self.webView.frame];
        _webMaskView.backgroundColor = [UIColor clearColor];
        _webMaskView.userInteractionEnabled = NO;
    }
    return _webMaskView;
}

- (WKWebView *)readerWebView {
    if (!_readerWebView) {
        _readerWebView = [[WKWebView alloc] initWithFrame:self.webView.frame configuration:[self configuration]];
        _readerWebView.allowsBackForwardNavigationGestures = NO;
        _readerWebView.navigationDelegate = self;
        _readerWebView.userInteractionEnabled = NO;
        _readerWebView.layer.masksToBounds = YES;
    }
    return _readerWebView;
}

- (PFWebViewNavigationHeader *)navigationHeader {
    if (!_navigationHeader) {
        _navigationHeader = [[PFWebViewNavigationHeader alloc] initWithURL:self.url];
    }
    return _navigationHeader;
}

- (PFWebViewToolBar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[PFWebViewToolBar alloc] initWithFrame:CGRectMake(0, SCREENHEIGHT - 50.5f, SCREENWIDTH, 50.5f)];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.offset + 19.f, SCREENWIDTH, 2)];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = self.progressBarColor;
    }
    return _progressView;
}

#pragma mark - Reader Mode

- (void)setupReaderMode {
    isReaderMode = NO;
    [self.view addSubview:self.webView];
    [self.view addSubview:self.webMaskView];

    self.maskLayer = [CALayer layer];
    self.maskLayer.frame = CGRectMake(0.0f, 0.0f, self.readerWebView.frame.size.width, 0.0f);
    self.maskLayer.borderWidth = self.readerWebView.frame.size.height / 2.0f;
    self.maskLayer.anchorPoint = CGPointMake(0.5, 1.0f);
    
    [self.readerWebView.layer setMask:self.maskLayer];
    
    [self.view addSubview:self.readerWebView];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if ([change[NSKeyValueChangeNewKey] isKindOfClass:[NSNumber class]]) {
            [self progressChanged:change[NSKeyValueChangeNewKey]];
        }
    } else if ([keyPath isEqualToString:@"canGoBack"]){
        if ([self.webView canGoBack]) {
            self.toolbar.backBtn.enabled = YES;
        } else {
            self.toolbar.backBtn.enabled = NO;
        }
    } else if ([keyPath isEqualToString:@"canGoForward"]){
        if ([self.webView canGoForward]) {
            self.toolbar.forwardBtn.enabled = YES;
        } else {
            self.toolbar.forwardBtn.enabled = NO;
        }
    } else if ([keyPath isEqualToString:@"URL"]){
        [self.navigationHeader setURL:self.webView.URL];
    }
    
}

#pragma mark - Private

- (void)progressChanged:(NSNumber *)newValue {
    if (self.progressView.alpha == 0) {
        self.progressView.alpha = 1.f;
    }
    
    [self.progressView setProgress:newValue.floatValue animated:YES];
    
    if (self.progressView.progress == 1) {
        [UIView animateWithDuration:.5f animations:^{
            self.progressView.alpha = 0;
        } completion:^(BOOL finished) {
            self.progressView.progress = 0;
        }];
    } else if (self.progressView.alpha == 0){
        [UIView animateWithDuration:.1f animations:^{
            self.progressView.alpha = 1.f;
        }];
    }
}

- (WKWebViewConfiguration *)configuration {
    // Load reader mode js script
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"PFWebViewController" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    
    NSString *readerScriptFilePath = [imageBundle pathForResource:@"safari-reader" ofType:@"js"];
    NSString *readerCheckScriptFilePath = [imageBundle pathForResource:@"safari-reader-check" ofType:@"js"];
    
    NSString *indexPageFilePath = [imageBundle pathForResource:@"index" ofType:@"html"];
    
    // Load HTML for reader mode
    readerHTMLString = [[NSString alloc] initWithContentsOfFile:indexPageFilePath encoding:NSUTF8StringEncoding error:nil];
    
    NSString *script = [[NSString alloc] initWithContentsOfFile:readerScriptFilePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    NSString *check_script = [[NSString alloc] initWithContentsOfFile:readerCheckScriptFilePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *check_userScript = [[WKUserScript alloc] initWithSource:check_script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    [userContentController addUserScript:check_userScript];
    [userContentController addScriptMessageHandler:self name:@"JSController"];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;

    return configuration;
}

#pragma mark - PFWebViewToolBarDelegate

- (void)webViewToolbarGoBack:(PFWebViewToolBar *)toolbar {
    if ([self.webView canGoBack]) {
        [UIView animateWithDuration:0.3f animations:^{
            self.webMaskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
            self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, 0.0f);
        } completion:^(BOOL finished) {
            _readerWebView.userInteractionEnabled = NO;
        }];
        [_readerWebView loadHTMLString:@"" baseURL:nil];
        [self.webView goBack];
    }
}

- (void)webViewToolbarGoForward:(PFWebViewToolBar *)toolbar {
    if ([self.webView canGoForward]) {
        [UIView animateWithDuration:0.3f animations:^{
            self.webMaskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
            self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, 0.0f);
        } completion:^(BOOL finished) {
            _readerWebView.userInteractionEnabled = NO;
        }];
        [_readerWebView loadHTMLString:@"" baseURL:nil];
        [self.webView goForward];
    }
}

- (void)webViewToolbarDidSwitchReaderMode:(PFWebViewToolBar *)toolbar {
    isReaderMode = !isReaderMode;
    if (isReaderMode) {
        [_webView evaluateJavaScript:@"var ReaderArticleFinderJS = new ReaderArticleFinder(document);" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        }];
        [_webView evaluateJavaScript:@"var article = ReaderArticleFinderJS.findArticle();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        }];
        [_webView evaluateJavaScript:@"article.element.outerHTML" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[NSString class]] && isReaderMode) {
                [_webView evaluateJavaScript:@"ReaderArticleFinderJS.articleTitle()" completionHandler:^(id _Nullable object_in, NSError * _Nullable error) {
                    readerArticleTitle = object_in;
                    
                    NSMutableString *mut_str = [readerHTMLString mutableCopy];
                    
                    // Replace page title with article title
                    [mut_str replaceOccurrencesOfString:@"Reader" withString:readerArticleTitle options:NSLiteralSearch range:NSMakeRange(0, 300)];
                    NSRange t = [mut_str rangeOfString:@"<div id=\"article\" role=\"article\">"];
                    NSInteger location = t.location + t.length;
                    
                    [mut_str insertString:object atIndex:location];
                    
                    [_readerWebView loadHTMLString:mut_str baseURL:self.url];
                    _readerWebView.alpha = 0.0f;
                }];
            }
        }];
        [_webView evaluateJavaScript:@"ReaderArticleFinderJS.prepareToTransitionToReader();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        }];
    } else {
        [UIView animateWithDuration:0.2f animations:^{
            self.webMaskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
            self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, 0.0f);
        } completion:^(BOOL finished) {
            _readerWebView.userInteractionEnabled = NO;
        }];
    }
}

- (void)webViewToolbarOpenInSafari:(PFWebViewToolBar *)toolbar {
    UIApplication *application = [UIApplication sharedApplication];
#ifndef __IPHONE_10_0
#define __IPHONE_10_0  100000
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:self.webView.URL options:@{} completionHandler:nil];
    } else {
        [application openURL:self.webView.URL];
    }
#else
    [application openURL:self.webView.URL];
#endif
}

- (void)webViewToolbarClose:(PFWebViewToolBar *)toolbar {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - WKWebViewNavigationDelegate Methods

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    if ([webView isEqual:self.readerWebView]) {
        return;
    }
    
    if (![self.webView.URL.absoluteString isEqualToString:@"about:blank"]) {
        // Cache current url after every frame entering if not blank page
        self.url = self.webView.URL;
        isReaderMode = NO;
        
        self.toolbar.readerModeBtn.selected = NO;
        
        // Set reader mode button enabled NO when begin navigation
        self.toolbar.readerModeBtn.enabled = NO;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
}

// 拦截非 Http:// 和 Https:// 开头的请求，转成应用内跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([webView isEqual:self.readerWebView]) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    
    if (![navigationAction.request.URL.absoluteString containsString:@"http://"] && ![navigationAction.request.URL.absoluteString containsString:@"https://"]) {
        
        UIApplication *application = [UIApplication sharedApplication];
#ifndef __IPHONE_10_0
#define __IPHONE_10_0  100000
#endif
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
        if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
        } else {
            [application openURL:navigationAction.request.URL];
        }
#else
        [application openURL:navigationAction.request.URL];
#endif
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([webView isEqual:self.readerWebView]) {
        decisionHandler(WKNavigationResponsePolicyAllow);
        return;
    }
    
    // Set reader mode button status when navigation finished
    [_webView evaluateJavaScript:@"var ReaderArticleFinderJS = new ReaderArticleFinder(document);" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
    }];
    
    [_webView evaluateJavaScript:@"ReaderArticleFinderJS.isReaderModeAvailable();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        if ([object integerValue] == 1) {
            self.toolbar.readerModeBtn.enabled = YES;
        } else {
            self.toolbar.readerModeBtn.enabled = NO;
        }
    }];
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    _readerWebView.alpha = 1.0f;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1f delay:0.2f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.webMaskView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
            self.maskLayer.frame = CGRectMake(0.0f, 0.0f, _readerWebView.frame.size.width, _readerWebView.frame.size.height);
        } completion:^(BOOL finished) {
            _readerWebView.userInteractionEnabled = YES;
        }];
    });
    
}

@end
