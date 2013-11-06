//
//  ViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "ViewController.h"
#import "SampleScrollViewController.h"
#import "SampleTopViewController.h"
#import "SampleTableViewController.h"

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
    
    [self setOverPanHeight:330];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - QMBParallaxScrollViewControllerDelegate

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeState:(QMBParallaxState)state{
    
    [self.navigationController setNavigationBarHidden:self.state == QMBParallaxStateFullSize animated:YES];
    
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didOverPanTopView:(UIView *)topView{
    NSLog(@"didOverPanTopView");
}

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didTapTopViewWithSender:(id)sender{
    NSLog(@"didTapTopView");
}
@end
