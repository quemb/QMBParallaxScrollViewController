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

- (void)awakeFromNib{
    [super awakeFromNib];

    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SampleTableViewController *sampleTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleTableViewController"];
    
    SampleTopViewController *sampleTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SampleTopViewController"];
    
    [self setupWithTopViewController:sampleTopViewController andTopHeight:200 andBottomViewController:sampleTableViewController];
    
    
}


@end
