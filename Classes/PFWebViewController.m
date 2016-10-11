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

@interface PFWebViewController () <PFWebViewToolBarDelegate,WKNavigationDelegate> {
    BOOL isNavigationBarHidden;
    BOOL hasLoaded;
    BOOL isReaderMode;
    
    NSString *htmlString;
}

@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) WKWebView *webView;
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

    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.navigationHeader];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.progressView];
    
    // Load reader mode js script
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"PFWebViewController" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];

    NSString *filePath = [imageBundle pathForResource:@"safari-reader" ofType:@"js"];
    NSString *script = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:script injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:userScript];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.offset + 20.5f, SCREENWIDTH, SCREENHEIGHT - 50.5f - 20.5f - self.offset) configuration:configuration];
    _webView.allowsBackForwardNavigationGestures = YES;
    _webView.navigationDelegate = self;
    
    hasLoaded = NO;
    isReaderMode = NO;
    
    [self.view addSubview:_webView];
    
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
}

#pragma mark - Lazy Initialize

//- (WKWebView *)webView {
//    if (!_webView) {
//        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.offset + 20.5f, SCREENWIDTH, SCREENHEIGHT - 50.5f - 20.5f - self.offset)];
//        _webView.allowsBackForwardNavigationGestures = YES;
//    }
//    return _webView;
//}

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

#pragma mark - PFWebViewToolBarDelegate 

- (void)webViewToolbarGoBack:(PFWebViewToolBar *)toolbar {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)webViewToolbarGoForward:(PFWebViewToolBar *)toolbar {
    if ([self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)webViewToolbarDidSwitchReaderMode:(PFWebViewToolBar *)toolbar
{
    isReaderMode = !isReaderMode;
    if (isReaderMode) {
//        [UIView animateWithDuration:0.3f animations:^{
//            self.webView.alpha = 0.0f;
//        }];
        [_webView evaluateJavaScript:@"var ReaderArticleFinderJS = new ReaderArticleFinder(document);" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        }];
        [_webView evaluateJavaScript:@"var article = ReaderArticleFinderJS.findArticle();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        }];
        [_webView evaluateJavaScript:@"article.element.innerText" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
            if ([object isKindOfClass:[NSString class]]) {
                if (!hasLoaded && isReaderMode) {
                    NSMutableString *mut_str = [object mutableCopy];
                    [mut_str insertString:@"</div>" atIndex:mut_str.length-1];
                    [mut_str insertString:@"<div style=\"font-size:40px; font-family:'PingFangSC-Regular','Helvetica Neue';color:#303030;margin-left:40px;margin-right:40px;line-height:60px\">" atIndex:0];
                    [mut_str replaceOccurrencesOfString:@"\n" withString:@"</br>" options:NSLiteralSearch range:NSMakeRange(0, mut_str.length)];
                    
                    [_webView loadHTMLString:mut_str baseURL:nil];
                    
                    if (isReaderMode) {
                        // If is reader mode, show webview content after analyzing the content
                        [UIView animateWithDuration:0.3f animations:^{
                            self.webView.alpha = 1.0f;
                        }];
                    }
                    hasLoaded = YES;
                } else {
                    self.webView.alpha = 1.0f;
                }
            } else {
                self.webView.alpha = 1.0f;
            }
        }];
        [_webView evaluateJavaScript:@"ReaderArticleFinderJS.prepareToTransitionToReader();" completionHandler:^(id _Nullable object, NSError * _Nullable error) {
        }];
    } else {
        self.webView.alpha = 1.0f;
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:50.0f];
        [self.webView loadRequest:request];
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

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    if (![self.webView.URL.absoluteString isEqualToString:@"about:blank"]) {
        // Cache current url after every frame entering if not blank page
        self.url = self.webView.URL;
        isReaderMode = NO;
        
        self.toolbar.readerModeBtn.selected = NO;
        
        // Set reader mode button enabled NO when begin navigation
        self.toolbar.readerModeBtn.enabled = NO;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (hasLoaded) {
        hasLoaded = NO;
        return;
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
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

@end
