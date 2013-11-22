//
//  KIImagePager.m
//  KIImagePager
//
//  Created by Marcus Kida on 07.04.13.
//  Copyright (c) 2013 Marcus Kida. All rights reserved.
//

#define kPageControlHeight  30
#define kOverlayWidth       50
#define kOverlayHeight      15

#import "KIImagePager.h"

@interface KIImagePager () <UIScrollViewDelegate>
{
    __weak id <KIImagePagerDataSource> _dataSource;
    __weak id <KIImagePagerDelegate> _delegate;
    
    UIScrollView *_scrollView;
    UIPageControl *_pageControl;
    UILabel *_countLabel;
    UIView *_indicatorBackground;
    NSTimer *_slideshowTimer;
    NSUInteger _slideshowTimeInterval;
    
    BOOL _indicatorDisabled;
}
@end

@implementation KIImagePager

@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize contentMode = _contentMode;
@synthesize pageControl = _pageControl;
@synthesize indicatorDisabled = _indicatorDisabled;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        // Initialization code

    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
}

- (void) layoutSubviews
{
    [self initialize];
}

#pragma mark - General
- (void) initialize
{
    if (!_scrollView){
        self.clipsToBounds = YES;
        [self initializeScrollView];
        [self initializePageControl];
        if(!_indicatorDisabled)
            [self initalizeImageCounter];
        [self loadData];
    }
    
    
}

- (UIColor *) randomColor
{
    return [UIColor colorWithHue:(arc4random() % 256 / 256.0)
                      saturation:(arc4random() % 128 / 256.0) + 0.5
                      brightness:(arc4random() % 128 / 256.0) + 0.5
                           alpha:1];
}

- (void) initalizeImageCounter
{
    _indicatorBackground = [[UIView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width-(kOverlayWidth-4),
                                                                    _scrollView.frame.size.height-kOverlayHeight,
                                                                    kOverlayWidth,
                                                                    kOverlayHeight)];
    _indicatorBackground.backgroundColor = [UIColor whiteColor];
    _indicatorBackground.alpha = 0.7f;
    _indicatorBackground.layer.cornerRadius = 5.0f;
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [icon setImage:[UIImage imageNamed:@"KICamera"]];
    icon.center = CGPointMake(_indicatorBackground.frame.size.width-18, _indicatorBackground.frame.size.height/2);
    
    [_indicatorBackground addSubview:icon];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    [_countLabel setTextAlignment:NSTextAlignmentCenter];
    [_countLabel setBackgroundColor:[UIColor clearColor]];
    [_countLabel setTextColor:[UIColor blackColor]];
    [_countLabel setFont:[UIFont systemFontOfSize:11.0f]];
    _countLabel.center = CGPointMake(15, _indicatorBackground.frame.size.height/2);
    [_indicatorBackground setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_indicatorBackground addSubview:_countLabel];
    
    [self addSubview:_indicatorBackground];
}

- (void) reloadData
{
    for (UIView *view in _scrollView.subviews)
        [view removeFromSuperview];
    
    [self loadData];
}

#pragma mark - ScrollView Initialization
- (void) initializeScrollView
{

    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:_scrollView];
}

- (void) loadData
{
    NSArray *aImageUrls = (NSArray *)[_dataSource arrayWithImages];
    if([aImageUrls count] > 0)
    {
        [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * [aImageUrls count],
                                               _scrollView.frame.size.height)];
        
        for (int i = 0; i < [aImageUrls count]; i++)
        {
            CGRect imageFrame = CGRectMake(_scrollView.frame.size.width * i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height);
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            [imageView setBackgroundColor:[UIColor clearColor]];
            [imageView setContentMode:[_dataSource contentModeForImage:i]];
            [imageView setTag:i];
            [imageView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
            [imageView setClipsToBounds:YES];
            if([[aImageUrls objectAtIndex:i] isKindOfClass:[UIImage class]])
            {
                // Set ImageView's Image directly
                [imageView setImage:(UIImage *)[aImageUrls objectAtIndex:i]];
            }
            else if([[aImageUrls objectAtIndex:i] isKindOfClass:[NSString class]] ||
                    [[aImageUrls objectAtIndex:i] isKindOfClass:[NSURL class]])
            {
                // Asynchronously retrieve image
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:
                                         [[aImageUrls objectAtIndex:i] isKindOfClass:[NSURL class]]?
                                         [aImageUrls objectAtIndex:i]:
                                         [NSURL URLWithString:(NSString *)[aImageUrls objectAtIndex:i]]];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [imageView setImage:[UIImage imageWithData:imageData]];
                    });
                });
            }
            
            // Add GestureRecognizer to ImageView
            UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                  initWithTarget:self
                                                                  action:@selector(imageTapped:)];
            [singleTapGestureRecognizer setNumberOfTapsRequired:1];
            [imageView addGestureRecognizer:singleTapGestureRecognizer];
            [imageView setUserInteractionEnabled:YES];
            
            [_scrollView addSubview:imageView];
        }
        
        [_countLabel setText:[NSString stringWithFormat:@"%d", [[_dataSource arrayWithImages] count]]];
        _pageControl.numberOfPages = [(NSArray *)[_dataSource arrayWithImages] count];
        _pageControl.hidden = ([(NSArray *)[_dataSource arrayWithImages] count] > 0?NO:YES);
        [_pageControl setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    }
    else
    {
        UIImageView *blankImage = [[UIImageView alloc] initWithFrame:_scrollView.frame];
        [blankImage setImage:[_dataSource placeHolderImageForImagePager]];
        [_scrollView addSubview:blankImage];
    }
}

- (void) imageTapped:(UITapGestureRecognizer *)sender
{
    if(_delegate)
        if([_delegate respondsToSelector:@selector(imagePager:didSelectImageAtIndex:)])
            [_delegate imagePager:self didSelectImageAtIndex:[(UIGestureRecognizer *)sender view].tag];
}

- (void) setIndicatorDisabled:(BOOL)indicatorDisabled
{
    if(indicatorDisabled)
    {
        [_pageControl removeFromSuperview];
        [_indicatorBackground removeFromSuperview];
    }
    else
    {
        [self addSubview:_pageControl];
        [self addSubview:_indicatorBackground];
    }
    
    _indicatorDisabled = indicatorDisabled;
}

#pragma mark - PageControl Initialization
- (void) initializePageControl
{
    CGRect pageControlFrame = CGRectMake(0, 0, _scrollView.frame.size.width, kPageControlHeight);
    _pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    _pageControl.center = CGPointMake(_scrollView.frame.size.width/2, _scrollView.frame.size.height - 12);
    _pageControl.userInteractionEnabled = NO;
    [self addSubview:_pageControl];
}

#pragma mark - ScrollView Delegate;
- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int currentPage = lround((float)scrollView.contentOffset.x / scrollView.frame.size.width);
    _pageControl.currentPage = currentPage;
    if(_delegate)
        if([_delegate respondsToSelector:@selector(imagePager:didScrollToIndex:)])
            [_delegate imagePager:self didScrollToIndex:currentPage];
}

#pragma mark - Slideshow
- (void) slideshowTick:(NSTimer *)timer
{    
    NSUInteger nextPage = 0;
    if([_pageControl currentPage] < ([[_dataSource arrayWithImages] count] - 1)) {
        nextPage = [_pageControl currentPage] + 1;
    }

    [_scrollView scrollRectToVisible:CGRectMake(self.frame.size.width * nextPage, 0, self.frame.size.width, self.frame.size.width) animated:YES];
    [_pageControl setCurrentPage:nextPage];
}

#pragma mark - Setter / Getter
- (void) setSlideshowTimeInterval:(NSUInteger)slideshowTimeInterval
{
    _slideshowTimeInterval = slideshowTimeInterval;
    
    if([_slideshowTimer isValid]) {
        [_slideshowTimer invalidate];
    }
    
    if (_slideshowTimeInterval > 0) {
        _slideshowTimer = [NSTimer scheduledTimerWithTimeInterval:_slideshowTimeInterval target:self selector:@selector(slideshowTick:) userInfo:nil repeats:YES];
    }
}

- (NSUInteger) slideshowTimeInterval
{
    return _slideshowTimeInterval;
}

@end
