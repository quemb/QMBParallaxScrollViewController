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
    float _lastOffsetY;
}

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

    _parallaxScrollView.frame = self.view.frame;
    _parallaxScrollView.alwaysBounceVertical = YES;
    
    //Configs
    
    [self changeTopHeight:height];
    [self setOverPanHeight:height * 1.5];
    [self setFullHeight:self.view.frame.size.height];

    self.topViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.topViewGestureRecognizer setNumberOfTouchesRequired:1];
    [self.topViewGestureRecognizer setNumberOfTapsRequired:1];
    [self.topViewController.view setUserInteractionEnabled:YES];
    [self enableTapGestureTopView:YES];
    
    self.bottomViewGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBottomTouch:)];
    [self.bottomViewGestureRecognizer setNumberOfTouchesRequired:1];
    [self.bottomViewController.view setUserInteractionEnabled:YES];
    
    //Register Observer
    [_parallaxScrollView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    [self addObserver:self forKeyPath:@"state" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:nil];
    
}

#pragma mark - Observer

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"]){
        [self parallaxScrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    
    if([keyPath isEqualToString:@"state"]){
        if ([[change valueForKey:NSKeyValueChangeOldKey] intValue] == [[change valueForKey:NSKeyValueChangeNewKey] intValue]){
            return;
        }
        if ([self.delegate respondsToSelector:@selector(parallaxScrollViewController:didChangeState:)]){
            [(id<QMBParallaxScrollViewControllerDelegate>) self.delegate parallaxScrollViewController:self didChangeState:[[change valueForKey:NSKeyValueChangeNewKey] intValue]];
        }

    }

}


- (void)dealloc{
    [_parallaxScrollView removeObserver:self forKeyPath:@"contentOffset"];
    [self removeObserver:self forKeyPath:@"state"];
}
#pragma mark - Configs

- (void)setFullHeight:(CGFloat)fullHeight{

    _fullHeight = MAX(fullHeight, _topHeight);
    
}

- (void)setOverPanHeight:(CGFloat)overPanHeight{
    
    _overPanHeight = MAX(_topHeight,overPanHeight);
    
}

- (void) changeTopHeight:(CGFloat) height{
    
    self.topViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, height);
    
    _parallaxScrollView.contentInset = UIEdgeInsetsMake(height, 0, 0, 0);
    _currentTopHeight = height;

    if ([self.delegate respondsToSelector:@selector(parallaxScrollViewController:didChangeTopHeight:)]){
        [self.delegate parallaxScrollViewController:self didChangeTopHeight:height];
    }
}

#pragma mark - ScrollView Methods

- (void)parallaxScrollViewDidScroll:(CGPoint)contentOffset {
    
    NSLog(@"%f",_parallaxScrollView.contentOffset.y);
    NSLog(@"%f",_lastOffsetY);
    if (_parallaxScrollView.contentOffset.y > _lastOffsetY){
        NSLog(@"UP");
        self.lastGesture = QMBParallaxGestureScrollsUp;
    }else {
        NSLog(@"DOWN");
        self.lastGesture = QMBParallaxGestureScrollsDown;
    }
    _lastOffsetY = _parallaxScrollView.contentOffset.y;
    
    if (_isAnimating){
        return;
    }
    float y = _parallaxScrollView.contentOffset.y + _currentTopHeight;
    
    /*
     * if top-view height is full screen
     * dont resize top view -> Fullscreen Mode
     */
    if (self.lastGesture == QMBParallaxGestureScrollsDown && _parallaxScrollView.contentOffset.y < -_overPanHeight){
        if (self.state != QMBParallaxStateFullSize){
            [self showFullTopView:YES];
        }
        
        return;
    }
    
    if (self.state == QMBParallaxStateFullSize && self.lastGesture == QMBParallaxGestureScrollsUp){
        [self showFullTopView:NO];
        return;
    }
    
    CGRect currentParallaxFrame = self.topViewController.view.frame;
    
    if (y > 0) {
        
        CGFloat newHeight = _currentTopHeight - y;
        
        [self.topViewController.view setHidden:(newHeight <= 0)];
        
        if (!self.topViewController.view.hidden) {
            
            self.topViewController.view.frame = CGRectMake(currentParallaxFrame.origin.x, currentParallaxFrame.origin.y, currentParallaxFrame.size.width, newHeight);

            if ([self.delegate respondsToSelector:@selector(parallaxScrollViewController:didChangeTopHeight:)]){
                [self.delegate parallaxScrollViewController:self didChangeTopHeight:self.topViewController.view.frame.size.height];
            }
            
        }
        
        if (y >= _topHeight) {
            _parallaxScrollView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            _parallaxScrollView.contentInset = UIEdgeInsetsMake(_currentTopHeight - y , 0, 0, 0);
        }
        
 
    } else {
        
        [self.topViewController.view setHidden:NO];
        
        CGFloat newHeight = _currentTopHeight - y;
        CGRect newFrame =  CGRectMake(currentParallaxFrame.origin.x, currentParallaxFrame.origin.y, currentParallaxFrame.size.width, newHeight);
        self.topViewController.view.frame = newFrame;
        if ([self.delegate respondsToSelector:@selector(parallaxScrollViewController:didChangeTopHeight:)]){
            [self.delegate parallaxScrollViewController:self didChangeTopHeight:self.topViewController.view.frame.size.height];
        }
        
        _parallaxScrollView.contentInset = UIEdgeInsetsMake(_currentTopHeight, 0, 0, 0);
    }
    
    [_parallaxScrollView setShowsVerticalScrollIndicator:self.topViewController.view.hidden];
    
   
}



#pragma mark - Helper Methods

- (void) performOptionalDelegateSelector:(SEL)selector withObject:(id)arg1 andObject:(id) arg2 {
    if ([self.delegate respondsToSelector:selector]){
        // Fix unknown selector warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.delegate performSelector:selector withObject:arg1 withObject:arg2];
#pragma clang diagnostic pop
    }
}

#pragma mark - User Interactions

- (void)enableTapGestureTopView:(BOOL)enable{
    if (enable) {
        [self.topViewController.view addGestureRecognizer:self.topViewGestureRecognizer];
    }else {
        [self.topViewController.view removeGestureRecognizer:self.topViewGestureRecognizer];
    }
}

- (void) handleTap:(id)sender {
    
    self.lastGesture = QMBParallaxGestureTopViewTap;
    
    [self showFullTopView: self.state != QMBParallaxStateFullSize];
    
}

- (void) handleBottomTouch:(id)sender {
    
    if (self.state == QMBParallaxStateFullSize){
        [self showFullTopView:NO];
    }
    
    
}

- (void) showFullTopView:(BOOL)show {

    _isAnimating = YES;
    
    [_parallaxScrollView setScrollEnabled:NO];
    [_parallaxScrollView scrollRectToVisible:CGRectMake(0, 0, 0, 0) animated:YES];
    
    
    [UIView animateWithDuration:.3
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [self changeTopHeight:show ?  _fullHeight : _topHeight];
                         
                     }
                     completion:^(BOOL finished){
                         [_parallaxScrollView setContentOffset:_parallaxScrollView.contentOffset animated:NO];
                         [_parallaxScrollView setScrollEnabled:YES];
                         _isAnimating = NO;
                         
                         if (self.state == QMBParallaxStateFullSize){
                             self.state = QMBParallaxStateVisible;
                         }else {
                             self.state = QMBParallaxStateFullSize;
                         }
                     }];
    
   
}



@end
