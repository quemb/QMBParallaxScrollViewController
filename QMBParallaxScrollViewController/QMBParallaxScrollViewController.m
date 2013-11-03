//
//  QMBParallaxScrollViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "QMBParallaxScrollViewController.h"
#import "REKit.h"

@interface QMBParallaxScrollViewController ()

@property (nonatomic, strong) UIScrollView *parallaxScrollView;
@property (nonatomic, assign) CGFloat currentTopHeight;
@property (nonatomic, strong, readwrite) UIViewController * topViewController;
@property (nonatomic, strong, readwrite) UIViewController<QMBParallaxScrollViewHolder> * bottomViewController;

@property (nonatomic, assign, readwrite) CGFloat topHeight;

@end

@implementation QMBParallaxScrollViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

#pragma mark - QMBParallaxScrollViewController Methods

- (void)setupWithTopViewController:(UIViewController *)topViewController andTopHeight:(CGFloat)height andBottomViewController:(UIViewController<QMBParallaxScrollViewHolder> *)bottomViewController{
    
    self.topViewController = topViewController;
    self.bottomViewController = bottomViewController;
    self.topHeight = height;
    
    [self.topViewController.view setClipsToBounds:YES];
    [self.bottomViewController.view setClipsToBounds:YES];
    
    [self addChildViewController:self.bottomViewController];
    [self.view addSubview:self.bottomViewController.view];
    [self.bottomViewController didMoveToParentViewController:self];

    [self addChildViewController:self.topViewController];
    [self.view addSubview:self.topViewController.view];
    [self.topViewController didMoveToParentViewController:self];

    [self.topViewController.view setAutoresizingMask:UIViewAutoresizingNone];
    self.bottomViewController.view.frame = self.view.frame;
    
    if ([self.bottomViewController respondsToSelector:@selector(scrollViewForParallexController)]){
        _parallaxScrollView = [self.bottomViewController scrollViewForParallexController];
    }
    
    NSAssert(_parallaxScrollView, @"No Scroll View given");
    
    [_parallaxScrollView setDelegate:self];
    _parallaxScrollView.frame = self.view.frame;
    
    
    [self changeTopHeight:height];


    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [recognizer setNumberOfTouchesRequired:1];
    [recognizer setNumberOfTapsRequired:1];
    [self.topViewController.view setUserInteractionEnabled:YES];
    [self.topViewController.view addGestureRecognizer:recognizer];

}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.view.frame.size.height != _currentTopHeight){
        [self parallaxScrollViewDidScroll:scrollView];
        
        if (scrollView.contentOffset.y < -1.3 * self.topHeight){
            [self showFullTopView:YES];
        }
    }
    
}

- (void)parallaxScrollViewDidScroll:(UIScrollView *)scrollView {
    

    float y = _parallaxScrollView.contentOffset.y + _currentTopHeight;
    
    CGRect currentParallaxFrame = self.topViewController.view.frame;
    
    if (y > 0) {
        
        CGFloat newHeight = _currentTopHeight - y;
        
        [self.topViewController.view setHidden:(newHeight <= 0)];
        
        if (!self.topViewController.view.hidden) {
            
            self.topViewController.view.frame = CGRectMake(currentParallaxFrame.origin.x, currentParallaxFrame.origin.y, currentParallaxFrame.size.width, newHeight);
            
        }

        if (y >= self.topHeight) {
            _parallaxScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            _parallaxScrollView.contentInset = UIEdgeInsetsMake(_currentTopHeight - y , 0, 0, 0);
        }

 
    } else {
        
        [self.topViewController.view setHidden:NO];
        
        CGFloat newHeight = _currentTopHeight - y;
        CGRect newFrame =  CGRectMake(currentParallaxFrame.origin.x, currentParallaxFrame.origin.y, currentParallaxFrame.size.width, newHeight);
        self.topViewController.view.frame = newFrame;
        
        _parallaxScrollView.contentInset = UIEdgeInsetsMake(_currentTopHeight, 0, 0, 0);
    }
    
    [_parallaxScrollView setShowsVerticalScrollIndicator:self.topViewController.view.hidden];

}

- (void) changeTopHeight:(CGFloat) height{
    
    _currentTopHeight = height;
    
    self.topViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, _currentTopHeight);
    
    _parallaxScrollView.contentInset = UIEdgeInsetsMake(self.topViewController.view.frame.size.height, 0, 0, 0);
    
}

- (void) handleTap:(id)sender {
    [self showFullTopView:self.view.frame.size.height != _currentTopHeight];
}

- (void) showFullTopView:(BOOL)show {
    [UIView animateWithDuration:.3f animations:^{
        [self changeTopHeight:show ?  self.view.frame.size.height : self.topHeight];
    }];
}

@end
