//
//  PFWebViewToolBar.m
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "PFWebViewToolBar.h"

@implementation PFWebViewToolBar

#pragma mark - Life cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"PFWebViewController" ofType:@"bundle"]];
        NSString *className = NSStringFromClass([self class]);
        self = [[bundle loadNibNamed:className owner:self options:nil] firstObject];
        self.frame = frame;
    }
    return self;
}

- (void)setup {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *url = [bundle URLForResource:@"PFWebViewController" withExtension:@"bundle"];
    NSBundle *imageBundle = [NSBundle bundleWithURL:url];
    
    NSString *closeImagePath = [imageBundle pathForResource:@"icon_close" ofType:@"png"];
    NSString *backImagePath = [imageBundle pathForResource:@"icon_back" ofType:@"png"];
    NSString *backDisableImagePath = [imageBundle pathForResource:@"icon_back_disable" ofType:@"png"];
    NSString *forwardImagePath = [imageBundle pathForResource:@"icon_next" ofType:@"png"];
    NSString *forwardDisableImagePath = [imageBundle pathForResource:@"icon_next_disable" ofType:@"png"];
    NSString *safariImagePath = [imageBundle pathForResource:@"icon_safari" ofType:@"png"];
    NSString *readerModeImagePath = [imageBundle pathForResource:@"icon_read" ofType:@"png"];
    NSString *readerModeDisableImagePath = [imageBundle pathForResource:@"icon_read_disable" ofType:@"png"];
    NSString *readerModeSelectedImagePath = [imageBundle pathForResource:@"icon_read_back" ofType:@"png"];

    [self.closeBtn setImage:[UIImage imageWithContentsOfFile:closeImagePath]
                   forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageWithContentsOfFile:backImagePath]
                  forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageWithContentsOfFile:backDisableImagePath]
                  forState:UIControlStateDisabled];
    [self.forwardBtn setImage:[UIImage imageWithContentsOfFile:forwardImagePath]
                     forState:UIControlStateNormal];
    [self.forwardBtn setImage:[UIImage imageWithContentsOfFile:forwardDisableImagePath]
                     forState:UIControlStateDisabled];
    [self.openInSafariBtn setImage:[UIImage imageWithContentsOfFile:safariImagePath]
                          forState:UIControlStateNormal];
    [self.readerModeBtn setImage:[UIImage imageWithContentsOfFile:readerModeImagePath] forState:UIControlStateNormal];
    [self.readerModeBtn setImage:[UIImage imageWithContentsOfFile:readerModeDisableImagePath] forState:UIControlStateDisabled];
    [self.readerModeBtn setImage:[UIImage imageWithContentsOfFile:readerModeSelectedImagePath] forState:UIControlStateSelected];
    
    self.readerModeBtn.selected = NO;
    self.readerModeBtn.enabled = NO;
    
    self.backBtn.enabled = NO;
    self.forwardBtn.enabled = NO;
}

#pragma mark - Event response

- (IBAction)close:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate webViewToolbarClose:self];
    }
}

- (IBAction)goBack:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate webViewToolbarGoBack:self];
    }
}

- (IBAction)goForward:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate webViewToolbarGoForward:self];
    }
}

- (IBAction)openInSafari:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate webViewToolbarOpenInSafari:self];
    }
}

- (IBAction)switchReaderMode:(id)sender {
    if ([self.delegate respondsToSelector:@selector(webViewToolbarDidSwitchReaderMode:)]) {
        [self.delegate webViewToolbarDidSwitchReaderMode:self];
        self.readerModeBtn.selected = !self.readerModeBtn.selected;
    }
}

@end
