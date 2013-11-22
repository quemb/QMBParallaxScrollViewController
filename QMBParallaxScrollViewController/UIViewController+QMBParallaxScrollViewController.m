//
//  UIViewController+QMBParallaxScrollViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "UIViewController+QMBParallaxScrollViewController.h"

@implementation UIViewController (QMBParallaxScrollViewController)

- (QMBParallaxScrollViewController *)parallaxScrollViewController {
    UIViewController *viewController = self.parentViewController;
    while (viewController) {
        if ([viewController isKindOfClass:[QMBParallaxScrollViewController class]]) {
            return (QMBParallaxScrollViewController *)viewController;
        } else if (viewController.parentViewController != nil && (viewController.parentViewController != viewController)) {
            viewController = viewController.parentViewController;
        } else {
            viewController = nil;
        }
    }
    return nil;
}

@end
