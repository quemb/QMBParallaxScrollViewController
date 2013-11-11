//
//  QMBParallaxScrollViewController.h
//  QMBParallaxScrollView-Sample
//
//  Created by Toni Möckel on 02.11.13.
//  Copyright (c) 2013 Toni Möckel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QMBParallaxScrollViewController;

typedef NS_ENUM(NSUInteger, QMBParallaxState) {
    QMBParallaxStateVisible = 0,
    QMBParallaxStateFullSize = 1,
    QMBParallaxStateHidden = 2,
};

typedef NS_ENUM(NSUInteger, QMBParallaxGesture) {
    QMBParallaxGestureTopViewTap = 0,
    QMBParallaxGestureScrollsDown = 1,
    QMBParallaxGestureScrollsUp = 2,
};

@protocol QMBParallaxScrollViewHolder <NSObject>

- (UIScrollView *) scrollViewForParallexController;

@end

@protocol QMBParallaxScrollViewControllerDelegate <NSObject>

@optional

/**
 * Callback when the user tapped the top-view 
 * sender is usually the UITapGestureRecognizer instance
 */
- (void) parallaxScrollViewController:(QMBParallaxScrollViewController *) controller didChangeGesture:(QMBParallaxGesture)newGesture oldGesture:(QMBParallaxGesture)oldGesture;

/**
 * Callback when the state changed to QMBParallaxStateFullSize, QMBParallaxStateVisible or QMBParallaxStateHidden
 */
- (void) parallaxScrollViewController:(QMBParallaxScrollViewController *) controller didChangeState:(QMBParallaxState) state;

/**
 * Callback when the top height changed
 */
- (void) parallaxScrollViewController:(QMBParallaxScrollViewController *) controller didChangeTopHeight:(CGFloat) height;

@end



@interface QMBParallaxScrollViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, strong) id<QMBParallaxScrollViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIViewController * topViewController;
@property (nonatomic, strong, readonly) UIViewController<QMBParallaxScrollViewHolder> * bottomViewController;

@property (nonatomic, assign, readonly) CGFloat topHeight;
@property (nonatomic, assign, setter = setFullHeight:) CGFloat fullHeight;
@property (nonatomic, assign, setter = setOverPanHeight:) CGFloat overPanHeight;

@property (nonatomic, readonly) QMBParallaxState state;

// inits
-(void) setupWithTopViewController:(UIViewController *)topViewController andTopHeight:(CGFloat)height andBottomViewController:(UIViewController<QMBParallaxScrollViewHolder> *)bottomViewController;


- (void)parallaxScrollViewDidScroll:(CGPoint)contentOffset;
// configs

/**
 * Config to enable or disable top-view tap control
 * Call will be responsed by QMBParallaxScrollViewControllerDelegate instance
 */
- (void) enableTapGestureTopView:(BOOL) enable;

@end
