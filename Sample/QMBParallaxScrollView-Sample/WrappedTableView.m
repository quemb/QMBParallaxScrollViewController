//
//  WrappedTableView.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 20.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "WrappedTableView.h"

@implementation WrappedTableView

- (CGSize)intrinsicContentSize {
    [self layoutIfNeeded]; // force my contentSize to be updated immediately
    return CGSizeMake(UIViewNoIntrinsicMetric, self.contentSize.height);
}

@end
