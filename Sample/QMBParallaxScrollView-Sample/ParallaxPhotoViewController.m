//
//  ParallaxPhotoViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 07.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "ParallaxPhotoViewController.h"
#import "SamplePhotoBrowserViewController.h"
#import "SampleScrollViewController.h"


@interface ParallaxPhotoViewController ()

@property (nonatomic, strong) SamplePhotoBrowserViewController *sampleTopViewController;

@end

@implementation ParallaxPhotoViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.sampleTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SamplePhotoBrowserViewController"];
    
    SampleScrollViewController *sampleBottomViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleScrollViewController"];
    
    [self setupWithTopViewController:self.sampleTopViewController andTopHeight:200 andBottomViewController:sampleBottomViewController];
    
    self.delegate = self;
    self.fullHeight = self.view.frame.size.height-50.0f;
}

- (IBAction) dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - QMBParallaxScrollViewControllerDelegate

- (void)parallaxScrollViewController:(QMBParallaxScrollViewController *)controller didChangeState:(QMBParallaxState)state{
    if (self.state == QMBParallaxStateFullSize){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        ((KIImagePager *)self.sampleTopViewController.view).slideshowTimeInterval = 0;
    }else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        ((KIImagePager *)self.sampleTopViewController.view).slideshowTimeInterval = 3.0f;
    }
}


@end
