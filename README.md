# PFWebViewController

A light-weight webview controller using WKWebView. Only supports iOS 9 and above.

Easy use and less memory consuming than [RxWebViewController](https://github.com/Roxasora/RxWebViewController).

## Demo

+ [Present Demo](Demo/Present.mov)
+ [Push Demo](Demo/Push.mov)

You can open the sample project and take a look by changing storyboard's main entry point.

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
pod 'PFWebViewController'
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
