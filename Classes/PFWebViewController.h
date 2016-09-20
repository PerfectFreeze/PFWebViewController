//
//  PFWebViewController.h
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFWebViewController : UIViewController

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIColor *progressBarColor;

// Init Method
- (id)initWithURL:(NSURL *)url;
- (id)initWithURLString:(NSString *)urlString;

@end
