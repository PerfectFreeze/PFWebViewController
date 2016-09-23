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

@interface PFWebViewController () <PFWebViewToolBarDelegate> {
    BOOL isNavigationBarHidden;
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

    
    [self.view addSubview:self.navigationHeader];
    [self.view addSubview:self.toolbar];
    [self.view addSubview:self.webView];
    [self.view addSubview:self.progressView];
    
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

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.offset + 20.5f, SCREENWIDTH, SCREENHEIGHT - 50.5f - 20.5f - self.offset)];
        _webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
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
    [UIView animateWithDuration:.1f animations:^{
        if (self.progressView.alpha == 0) {
            self.progressView.alpha = 1.f;
        }
        self.progressView.progress = newValue.floatValue;
    }];
    
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

- (void)webViewToolbarOpenInSafari:(PFWebViewToolBar *)toolbar {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
    // Introduced in iOS 10
    [[UIApplication sharedApplication] openURL:self.webView.URL options:@{} completionHandler:nil];
#else
    [[UIApplication sharedApplication] openURL:self.webView.URL];
#endif
}

- (void)webViewToolbarClose:(PFWebViewToolBar *)toolbar {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
