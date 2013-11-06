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
    SamplePhotoBrowserViewController *sampleTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SamplePhotoBrowserViewController"];
    
    SampleScrollViewController *sampleBottomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleScrollViewController"];
    
    [self setupWithTopViewController:sampleTopViewController andTopHeight:200 andBottomViewController:sampleBottomViewController];
    
    self.fullHeight = 400.0f;
}



@end
