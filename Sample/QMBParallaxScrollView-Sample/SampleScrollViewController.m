//
//  SampleScrollViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "SampleScrollViewController.h"

@interface SampleScrollViewController (){

}

@end

@implementation SampleScrollViewController

- (void)awakeFromNib{
    
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

#pragma mark - Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    CGSize oldSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
    CGSize newSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
    
    if (oldSize.height != newSize.height){
        [self.webView setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        [self.webView.superview setFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    

}

#pragma mark - QMBParallaxScrollViewHolder

- (UIScrollView *)scrollViewForParallexController{

    return self.scrollView;
}

- (IBAction)closeButtonTouchUpInside:(id)sender{
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
