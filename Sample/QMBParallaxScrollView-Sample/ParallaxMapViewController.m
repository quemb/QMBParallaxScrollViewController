//
//  ParallaxMapViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 06.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "ParallaxMapViewController.h"
#import "SamplePhotoBrowserViewController.h"
#import "SampleScrollViewController.h"

@interface ParallaxMapViewController ()

@end

@implementation ParallaxMapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *sampleMapViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    
    SampleScrollViewController *sampleBottomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleScrollViewController"];
    
    [self setupWithTopViewController:sampleMapViewController andTopHeight:200 andBottomViewController:sampleBottomViewController];
    
    self.fullHeight = self.view.frame.size.height-50.0f;
}

- (IBAction) dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
