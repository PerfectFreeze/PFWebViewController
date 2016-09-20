//
//  PFWebViewToolBar.h
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFWebViewToolBar;

@protocol PFWebViewToolBarDelegate <NSObject>

- (void)webViewToolbarGoBack:(PFWebViewToolBar *)toolbar;
- (void)webViewToolbarGoForward:(PFWebViewToolBar *)toolbar;
- (void)webViewToolbarOpenInSafari:(PFWebViewToolBar *)toolbar;
- (void)webViewToolbarClose:(PFWebViewToolBar *)toolbar;

@end

@interface PFWebViewToolBar : UIView

@property (weak, nonatomic) id<PFWebViewToolBarDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;
@property (weak, nonatomic) IBOutlet UIButton *openInSafariBtn;

- (void)setup;

@end
