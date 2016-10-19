# PFWebViewController

[![Version](https://img.shields.io/cocoapods/v/PFWebViewController.svg?style=flat)](http://cocoapods.org/pods/PFWebViewController)
[![License](https://img.shields.io/cocoapods/l/PFWebViewController.svg?style=flat)](http://cocoapods.org/pods/PFWebViewController)
[![Platform](https://img.shields.io/cocoapods/p/PFWebViewController.svg?style=flat)](http://cocoapods.org/pods/PFWebViewController)
[![Downloads](https://img.shields.io/cocoapods/dt/PFWebViewController.svg?style=flat)](http://cocoapods.org/pods/PFWebViewController)

## Features

- A light-weight webview controller using WKWebView. Only supports iOS 9 and above.

- Easy use and less memory consuming than [RxWebViewController](https://github.com/Roxasora/RxWebViewController).

- Support Safari-like reader mode.

## Screenshots

### Loading

![Loading](Screenshots/Loading.png)

### Main Screen

![Main Screen](Screenshots/GitHub_1.png)

![Main Screen](Screenshots/GitHub_2.png)

### Reader Mode

![Reader Mode Off](Screenshots/Reader_Mode_1.png)

![Reader Mode On](Screenshots/Reader_Mode_2.png)

## Installation

### Using Carthage

Add `PFWebViewController` to your `Cartfile`:

```
github "PerfectFreeze/PFWebViewController"
```

Run `carthage` to build this framework.

Add `PFWebViewController.framework` to your Xcode project.

### Using CocoaPods

Add `PFWebViewController` to your `Podfile`:

```ruby
pod 'PFWebViewController', '~> 1.1'
```

Run `pod install` to install this framework.

### Manually

Drag `Classes` folder to your project.

## Usage 

```objective-c
// Init with a string
PFWebViewController *webVC = [[PFWebViewController alloc] initWithURLString:@"https://github.com"];

// Or with an URL
NSURL *url = ...;
PFWebViewController *webVC = [[PFWebViewController alloc] initWithURL:url];

// Optional: Set Progressbar's Color, default is black
[webVC setProgressBarColor:[UIColor redColor]];
    
// Present in a single view
[self presentViewController:webVC animated:YES completion:nil];

// Or push in a navigationController
[self.navigationController pushViewController:webVC animated:YES];
```

## License

This project is released under the terms and conditions of the [MIT license](https://opensource.org/licenses/MIT). See [LICENSE](LICENSE) for details.
