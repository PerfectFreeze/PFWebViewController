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

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface PFWebViewController () <PFWebViewToolBarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) PFWebViewNavigationHeader *navigationHeader;
@property (nonatomic, strong) PFWebViewToolBar *toolbar;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation PFWebViewController

#pragma mark - Life Cycle

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (id)initWithURLString:(NSString *)urlString {
    self = [super init];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [self.webView removeObserver:self forKeyPath:@"URL"];
}

#pragma mark - Lazy Initialize

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 40.5f, self.view.frame.size.width, self.view.frame.size.height - 91.f)];
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
        _toolbar = [[PFWebViewToolBar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50.5f, self.view.frame.size.width, 50.5f)];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

- (UIProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 39, self.view.frame.size.width, 2)];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = [UIColor blackColor];
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
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        // Introduced in iOS 10
        [[UIApplication sharedApplication] openURL:self.webView.URL options:@{} completionHandler:nil];
    } else {
        [[UIApplication sharedApplication] openURL:self.webView.URL];
    }
}

- (void)webViewToolbarClose:(PFWebViewToolBar *)toolbar {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
