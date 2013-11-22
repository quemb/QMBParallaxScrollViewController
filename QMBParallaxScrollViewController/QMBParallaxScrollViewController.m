//
//  QMBParallaxScrollViewController.m
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import "QMBParallaxScrollViewController.h"


@interface QMBParallaxScrollViewController (){
    BOOL _isAnimating;
    float _startTopHeight;
    float _lastOffsetY;
}

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *foregroundView;
@property (nonatomic, strong) UIScrollView *backgroundScrollView;
@property (nonatomic, strong) UIScrollView *foregroundScrollView;

@property (nonatomic, strong) UITapGestureRecognizer *topViewGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *bottomViewGestureRecognizer;
@property (nonatomic, strong) UIScrollView *parallaxScrollView;
@property (nonatomic, assign) CGFloat currentTopHeight;
@property (nonatomic, strong, readwrite) UIViewController * topViewController;
@property (nonatomic, strong, readwrite) UIViewController<QMBParallaxScrollViewHolder> * bottomViewController;

@property (nonatomic, assign, readwrite) CGFloat topHeight;
@property (nonatomic, readwrite) QMBParallaxState state;
@property (nonatomic, readwrite) QMBParallaxGesture lastGesture;

@end

@implementation QMBParallaxScrollViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)dealloc{
    if ([[_backgroundView gestureRecognizers] containsObject:self.topViewGestureRecognizer]){
        [_backgroundView removeGestureRecognizer:self.topViewGestureRecognizer];
    }
}

#pragma mark - QMBParallaxScrollViewController Methods

- (void)setupWithTopViewController:(UIViewController *)topViewController andTopHeight:(CGFloat)height andBottomViewController:(UIViewController<QMBParallaxScrollViewHolder> *)bottomViewController{
    
    self.topViewController = topViewController;
    self.bottomViewController = bottomViewController;
    _topHeight = height;
    _startTopHeight = _topHeight;
    _maxHeight = self.view.frame.size.height-50.0f;
    [self setMaxHeightBorder:1.5f*_topHeight];
    [self setMinHeightBorder:_maxHeight-20.0f];
    
    [self addChildViewController:self.topViewController];
    _backgroundView = topViewController.view;
    [_backgroundView setClipsToBounds:YES];
    
    [self addChildViewController:self.bottomViewController];
    _foregroundView = bottomViewController.view;
    
    _foregroundScrollView = [UIScrollView new];
    _foregroundScrollView.backgroundColor = [UIColor clearColor];
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        [self.foregroundScrollView setContentInset:UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)];
    }
    _foregroundScrollView.delegate = self;
    [_foregroundScrollView setAlwaysBounceVertical:YES];
    _foregroundScrollView.frame = self.view.frame;
    [_foregroundScrollView addSubview:_foregroundView];
    
    [self.view addSubview:_foregroundScrollView];
    [self.bottomViewController didMoveToParentViewController:self];
    
    [self.view addSubview:_backgroundView];
    [self.topViewController didMoveToParentViewController:self];
    
    
    [self addGestureReconizer];
    
    [self updateForegroundFrame];
    [self updateContentOffset];
    


}

#pragma mark - Gestures

-(void) addGestureReconizer{
    self.topViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.topViewGestureRecognizer setNumberOfTouchesRequired:1];
    [self.topViewGestureRecognizer setNumberOfTapsRequired:1];
    [self.topViewController.view setUserInteractionEnabled:YES];
    
    [self enableTapGestureTopView:YES];
}

- (void)enableTapGestureTopView:(BOOL)enable{
    if (enable) {
        [_backgroundView addGestureRecognizer:self.topViewGestureRecognizer];
    }else {
        [_backgroundView removeGestureRecognizer:self.topViewGestureRecognizer];
    }
}

- (void) handleTap:(id)sender {
    
    self.lastGesture = QMBParallaxGestureTopViewTap;
    
    [self showFullTopView: self.state != QMBParallaxStateFullSize];
    
}

#pragma mark - NSObject Overrides

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    if ([self.scrollViewDelegate respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:self.scrollViewDelegate];
    } else {
        [super forwardInvocation:anInvocation];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    return ([super respondsToSelector:aSelector] ||
            [self.scrollViewDelegate respondsToSelector:aSelector]);
}



#pragma mark - UIScrollViewDelegate Protocol Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self updateContentOffset];
    if ([self.scrollViewDelegate respondsToSelector:_cmd]) {
        [self.scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!_isAnimating && self.foregroundScrollView.contentOffset.y-_startTopHeight > -_maxHeightBorder && self.state == QMBParallaxStateFullSize){
        [self.foregroundScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}


#pragma mark - Public Interface

- (UIScrollView *)parallaxScrollView {
    return self.foregroundScrollView;
}

- (void)setBackgroundHeight:(CGFloat)backgroundHeight {
    _topHeight = backgroundHeight;

    [self updateForegroundFrame];
    [self updateContentOffset];
}


#pragma mark - Internal Methods



- (CGRect)frameForObject:(id)frameObject {
    return frameObject == [NSNull null] ? CGRectNull : [frameObject CGRectValue];
}

#pragma mark Parallax Effect


- (void)updateForegroundFrame {
    
    
    
    if ([_foregroundView isKindOfClass:[UIScrollView class]]){
        _foregroundView.frame = CGRectMake(0.0f, _topHeight, self.view.frame.size.width, MAX(((UIScrollView *)_foregroundView).contentSize.height,_foregroundView.frame.size.height));
        CGSize size = CGSizeMake(self.view.frame.size.width,MAX(((UIScrollView *)_foregroundView).contentSize.height,_foregroundView.frame.size.height) + _topHeight);
        self.foregroundScrollView.contentSize = size;
    }else {
        self.foregroundView.frame = CGRectMake(0.0f,
                                               _topHeight,
                                               self.foregroundView.frame.size.width,
                                               self.foregroundView.frame.size.height);
        self.foregroundScrollView.contentSize =
        CGSizeMake(self.view.frame.size.width,
                   self.foregroundView.frame.size.height + _topHeight);
    }
    
}

- (void)updateContentOffset {

    if (2*self.foregroundScrollView.contentOffset.y>_foregroundView.frame.origin.y){
        [self.foregroundScrollView setShowsVerticalScrollIndicator:YES];
    }else {
        [self.foregroundScrollView setShowsVerticalScrollIndicator:NO];
    }
    
    // Determine if user scrolls up or down
    if (self.foregroundScrollView.contentOffset.y > _lastOffsetY){
        self.lastGesture = QMBParallaxGestureScrollsUp;
    }else {
        self.lastGesture = QMBParallaxGestureScrollsDown;
    }
    _lastOffsetY = self.foregroundScrollView.contentOffset.y;
    
    self.backgroundView.frame =
    CGRectMake(0.0f,0.0f,self.view.frame.size.width,_topHeight+(-1)*self.foregroundScrollView.contentOffset.y);
    
    if (_isAnimating){
        return;
    }
    
    if (!_isAnimating && self.lastGesture == QMBParallaxGestureScrollsDown && self.foregroundScrollView.contentOffset.y-_startTopHeight < -_maxHeightBorder && self.state != QMBParallaxStateFullSize){
        [self showFullTopView:YES];
        return;
    }
    
    if (!_isAnimating && self.lastGesture == QMBParallaxGestureScrollsUp && -_foregroundView.frame.origin.y + self.foregroundScrollView.contentOffset.y > -_minHeightBorder && self.state == QMBParallaxStateFullSize){
        [self showFullTopView:NO];
        return;
    }
    

}

- (void) showFullTopView:(BOOL)show {
    
    _isAnimating = YES;
    [self.foregroundScrollView setScrollEnabled:NO];
    
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [self changeTopHeight:show ?  _maxHeight : _startTopHeight];
                     }
                     completion:^(BOOL finished){
                         
                         _isAnimating = NO;
                         [self.foregroundScrollView setScrollEnabled:YES];
                         
                         if (self.state == QMBParallaxStateFullSize){
                             self.state = QMBParallaxStateVisible;
                         }else {
                             self.state = QMBParallaxStateFullSize;
                         }
                     }];
    
    
}

- (void) changeTopHeight:(CGFloat) height{
    
    _topHeight = height;
    
    [self updateContentOffset];
    [self updateForegroundFrame];
    
    if ([self.delegate respondsToSelector:@selector(parallaxScrollViewController:didChangeTopHeight:)]){
        [self.delegate parallaxScrollViewController:self didChangeTopHeight:height];
    }
}

#pragma mark - Borders

- (void)setMaxHeightBorder:(CGFloat)maxHeightBorder{
    
    _maxHeightBorder = MAX(_topHeight,maxHeightBorder);
    
}

- (void)setMinHeightBorder:(CGFloat)minHeightBorder{
    
    _minHeightBorder = MIN(_maxHeight,minHeightBorder);
    
}

@end
