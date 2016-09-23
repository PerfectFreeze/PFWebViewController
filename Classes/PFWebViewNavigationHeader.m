//
//  PFWebViewNavigationHeader.m
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "PFWebViewNavigationHeader.h"
#import <QuartzCore/QuartzCore.h>

#define SCREENWIDTH [UIScreen mainScreen].bounds.size.width
#define SCREENHEIGHT [UIScreen mainScreen].bounds.size.height

@interface PFWebViewNavigationHeader ()
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, strong) UILabel *urlLabel;
@end

@implementation PFWebViewNavigationHeader

- (id)initWithURL:(NSURL *)url {
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    self = [super initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 20.5f + self.offset)];
    if (self) {
        self.urlLabel.text = [url host];
        [self setup];
    }
    return self;
}

- (void)setURL:(NSURL *)url {
    self.urlLabel.text = [url host];
}

- (void)setup {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.urlLabel];
    [self addSubview:self.bottomLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.offset = SCREENWIDTH < SCREENHEIGHT ? 20.f : 0.f;
    self.frame = CGRectMake(0, 0, SCREENWIDTH, 20.5f + self.offset);
    self.urlLabel.frame = CGRectMake(0, self.offset, SCREENWIDTH, 20);
    self.bottomLine.frame = CGRectMake(0, 20 + self.offset, SCREENWIDTH, .5f);
}

- (UILabel *)urlLabel {
    if (!_urlLabel) {
        _urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.offset, SCREENWIDTH, 20)];
        _urlLabel.textAlignment = NSTextAlignmentCenter;
        _urlLabel.font = [UIFont systemFontOfSize:11];
        _urlLabel.numberOfLines = 1;
    }
    return _urlLabel;
}

- (UIView *)bottomLine {
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, 20 + self.offset, SCREENWIDTH, .5f)];
        _bottomLine.backgroundColor = [UIColor colorWithRed:234.f/255.f green:237.f/255.f blue:242.f/255.f alpha:1.f];
    }
    return _bottomLine;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
