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



@interface QMBParallaxScrollViewController : UIViewController<UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) id<QMBParallaxScrollViewControllerDelegate> delegate;

@property (nonatomic, strong, readonly) UIViewController * topViewController;
@property (nonatomic, strong, readonly) UIViewController * bottomViewController;

@property (nonatomic, assign, readonly) CGFloat topHeight;
@property (nonatomic, assign, setter = setMaxHeight:) CGFloat maxHeight;

/**
 * Set the height of the border (margin from top) that has to be scrolled over to expand the background view.
 * Default: MAX(1.5f * _topHeight, 300.0f)
 */
@property (nonatomic, assign, setter = setMaxHeightBorder:) CGFloat maxHeightBorder;

/**
 * Set the height of the border (margin from top) that has to be scrolled under to minimize the background view
 * Default: fullHeight - 5.0f
 */
@property (nonatomic, assign, setter = setMinHeightBorder:) CGFloat minHeightBorder;

/**
 * To enable section support for UITableViews, default: true if UITableView is client scrollview
 * TODO: this option will disable decelerated scrolling (known bug)
 */
@property (nonatomic, assign) BOOL enableSectionSupport;

@property (nonatomic, readonly) QMBParallaxState state;

/**
 * The Parallax Scrollview that embeds the bottom (forground) view
 */
@property (nonatomic, readonly) UIScrollView *parallaxScrollView;

/**
 * Use the scrollview delegate for custom actions
 */
@property (nonatomic, weak) id<UIScrollViewDelegate> scrollViewDelegate;

// inits
-(void) setupWithTopViewController:(UIViewController *)topViewController andTopHeight:(CGFloat)height andBottomViewController:(UIViewController *)bottomViewController;


// configs

/**
 * Config to enable or disable top-view tap control
 * Call will be responsed by QMBParallaxScrollViewControllerDelegate instance
 */
- (void) enableTapGestureTopView:(BOOL) enable;

@end
