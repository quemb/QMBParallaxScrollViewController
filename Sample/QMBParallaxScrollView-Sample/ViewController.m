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
#import "FXBlurView.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SampleTableViewController *sampleTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleTableViewController"];
    
    SampleTopViewController *sampleTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleTopViewController"];
    self.delegate = self;
    
    [self setupWithTopViewController:sampleTopViewController andTopHeight:200 andBottomViewController:sampleTableViewController];
    
    [self setOverPanHeight:250];
    
    [sampleTopViewController.imageView.image blurredImageWithRadius:10.0 iterations:1.0 tintColor:[UIColor blackColor]];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - QMBParallaxScrollViewControllerDelegate

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeState:(QMBParallaxState)state{
    
    NSLog(@"didChangeState %d",state);
    [self.navigationController setNavigationBarHidden:self.state == QMBParallaxStateFullSize animated:YES];
    
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeTopHeight:(CGFloat)height{
    [self.topViewController.view setAlpha:MAX(.7,height/self.fullHeight)];
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeGesture:(QMBParallaxGesture)newGesture oldGesture:(QMBParallaxGesture)oldGesture{
    
}
@end
