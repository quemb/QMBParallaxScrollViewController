//
//  ViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "ViewController.h"
#import "SampleScrollViewController.h"
#import "SampleTableViewController.h"
#import "SamplePhotoBrowserViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    SampleTableViewController *sampleTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleTableViewController"];
    
    SampleTopViewController *sampleTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleTopViewController"];
    self.delegate = self;
    
    [self setupWithTopViewController:sampleTopViewController andTopHeight:200 andBottomViewController:sampleTableViewController];
    

}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - QMBParallaxScrollViewControllerDelegate

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeState:(QMBParallaxState)state{
    
    NSLog(@"didChangeState %d",state);
    //[self.navigationController setNavigationBarHidden:self.state == QMBParallaxStateFullSize animated:YES];
    
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeTopHeight:(CGFloat)height{
    
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeGesture:(QMBParallaxGesture)newGesture oldGesture:(QMBParallaxGesture)oldGesture{
    
}
@end
