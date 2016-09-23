//
//  ViewController.m
//  PFWebViewController
//
//  Created by Cee on 9/19/16.
//  Copyright © 2016 Cee. All rights reserved.
//

#import "ViewController.h"
#import "PFWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPressed:(UIButton *)sender {
    PFWebViewController *webVC = [[PFWebViewController alloc] initWithURLString:@"https://github.com"];
    [webVC setProgressBarColor:[UIColor redColor]];
    
    [self presentViewController:webVC animated:YES completion:nil];
}


@end
