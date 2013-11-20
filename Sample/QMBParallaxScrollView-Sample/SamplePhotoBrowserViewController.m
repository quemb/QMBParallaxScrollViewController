//
//  SamplePhotoBrowserViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 06.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "SamplePhotoBrowserViewController.h"

@interface SamplePhotoBrowserViewController ()

@property (nonatomic, strong) NSMutableArray *photos;

@end

@implementation SamplePhotoBrowserViewController



- (void)viewDidLoad
{
    self.photos = [NSMutableArray array];
    [self.photos addObject:[UIImage imageNamed:@"NGC6559.jpg"]];
    [self.photos addObject:[UIImage imageNamed:@"1.jpg"]];
    [self.photos addObject:[UIImage imageNamed:@"2.jpg"]];
    [self.photos addObject:[UIImage imageNamed:@"3.jpg"]];
    [self.photos addObject:[UIImage imageNamed:@"4.jpg"]];

    [super viewDidLoad];
}

- (NSArray *) arrayWithImages
{
    return self.photos;
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFill;
}

@end
