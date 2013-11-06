//
//  SampleScrollViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "SampleScrollViewController.h"

@interface SampleScrollViewController ()

@end

@implementation SampleScrollViewController

- (void)awakeFromNib{
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UIWebView *webVIew = (UIWebView *)self.view;
    [webVIew loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/quemb/QMBParallaxScrollViewController"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - QMBParallaxScrollViewHolder

- (UIScrollView *)scrollViewForParallexController{
    UIWebView *webVIew = (UIWebView *)self.view;
    return webVIew.scrollView;
}

- (IBAction)closeButtonTouchUpInside:(id)sender{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
