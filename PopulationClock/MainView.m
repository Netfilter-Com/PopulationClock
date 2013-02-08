//
//  MainView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "MainView.h"

#define MAP_NAVIGATION_BAR_OVERLAP_PIXELS 4

@implementation MainView {
    __weak UIScrollView *_scrollView;
    __weak UIImageView *_map;
    IBOutlet __weak UIView *_legend;
    IBOutlet __weak UIView *_navigationBar;
    IBOutlet __weak UIView *_panel1;
    __weak UIView *_panel2;
    __weak UIView *_panel3;
    IBOutlet __weak UIToolbar *_toolbar;
    IBOutlet __weak UIView *_dimmedView;
    int _numKeyboardsShowing;
    BOOL _notFirstLayout;
}

- (void)awakeFromNib {
    // Configure the scroll view properties
    self.scrollEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = 0;
    
    // Style the toolbar
    [_toolbar setBackgroundImage:[UIImage imageNamed:@"boxRodapeVert"] forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    // Add observers to the keyboard events
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc {
    // Remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addMapImageViewController:(MapImageViewController *)controller {
    // Add the view to the hierarchy
    [self insertSubview:controller.view belowSubview:_dimmedView];
    
    // Save those references
    _map = controller.mapImageView;
    _scrollView = controller.scrollView;
}

- (void)addCountryListViewController:(CountryListViewController *)controller {
    // Add the view to the hierarchy
    [self insertSubview:controller.view aboveSubview:_dimmedView];
    
    // Save a reference to the view
    _panel2 = controller.view;
}

- (void)addCountryInfoViewController:(CountryInfoViewController *)controller {
    // Add the view to the hierarchy
    [self insertSubview:controller.view belowSubview:_dimmedView];
    
    // Save a reference to the view
    _panel3 = controller.view;
}

static inline UIViewAnimationOptions animationOptionsWithCurve(UIViewAnimationCurve curve) {
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:
            return UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            return UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            return UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            return UIViewAnimationOptionCurveLinear;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // Increment the number of keyboards showing
    ++_numKeyboardsShowing;
    
    // Get the keyboard size
    CGSize kbSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // The keyboard size doesn't follow the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat tmp = kbSize.width;
        kbSize.width = kbSize.height;
        kbSize.height = tmp;
    }
    
    // Animate with the keyboard
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = animationOptionsWithCurve([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]);
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        // Actually dim the dimmed view
        _dimmedView.hidden = NO;
        _dimmedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        // Offset the content
        self.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
        self.contentOffset = CGPointMake(0, kbSize.height);
    } completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Decrement the number of keyboards showing
    _numKeyboardsShowing = 0;
    
    // Adjust the content and get rid of the dimmed view
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationOptions options = animationOptionsWithCurve([notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]);
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        // Make the dimmed view transparent
        if (!_numKeyboardsShowing)
            _dimmedView.backgroundColor = [UIColor clearColor];
        
        // Offset the content back into place
        self.contentInset = UIEdgeInsetsZero;
        self.contentOffset = CGPointZero;
    } completion:^(BOOL finished) {
        // Make the dimmed view hidden again
        if (!_numKeyboardsShowing)
            _dimmedView.hidden = YES;
    }];
}

- (BOOL)findAndResignFirstResponder:(UIView *)view {
    if (view.isFirstResponder) {
        [view resignFirstResponder];
        return YES;
    }
    for (UIView *subview in view.subviews) {
        if ([self findAndResignFirstResponder:subview])
            return YES;
    }
    return NO;
}

- (IBAction)dimmedViewButtonTouched:(id)sender {
    // Find and resign the first responder. This is ugly but,
    // alternatives would be either having to keep track of
    // the search UITextField or telling the view controller
    // to end editing
    [self findAndResignFirstResponder:self];
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // Save the content offset and the previous scale so we
    // can adjust the content offset accordingly after we change
    // the content size
    CGPoint contentOffset = _scrollView.contentOffset;
    CGFloat previousScale = _scrollView.frame.size.width / _map.image.size.width;
    
    // Save and reset the zoom level
    float zoomScale = _scrollView.zoomScale;
    _scrollView.zoomScale = 1;
    
    // Find an appropriate size for the map
    CGSize prevMapSize = _scrollView.frame.size;
    CGFloat scaleX = self.bounds.size.width / _map.image.size.width;
    CGFloat scaleY = self.bounds.size.height / _map.image.size.height;
    CGFloat scale = MIN(scaleX, scaleY);
    CGSize mapSize = CGSizeMake(_map.image.size.width * scale, _map.image.size.height * scale);
    
    // Resize the scroll view and the map
    CGRect frame = CGRectMake(0, 0, mapSize.width, mapSize.height);
    _scrollView.frame = frame;
    _scrollView.contentSize = mapSize;
    _map.frame = frame;
    
    // Restore the zoom level
    _scrollView.zoomScale = zoomScale;
    
    // Scale the content offset according to the difference from the
    // previous scale, to keep the image centered at the same point
    // before the change in scale
    CGFloat scaleScale = previousScale == 0 ? 1 : scale / previousScale;
    _scrollView.contentOffset = CGPointMake(contentOffset.x * scaleScale, contentOffset.y * scaleScale);
    
    // Position the navigation bar
    frame = _navigationBar.frame;
    frame.size.width = self.bounds.size.width;
    frame.origin.x = 0;
    frame.origin.y = mapSize.height - MAP_NAVIGATION_BAR_OVERLAP_PIXELS;
    _navigationBar.frame = frame;
    
    // Position the ad banner view
    frame = _adView.frame;
    frame.origin.x = self.bounds.size.width - _adView.frame.size.width;
    frame.origin.y = _navigationBar.frame.origin.y - _adView.frame.size.height;
    _adView.frame = frame;
    
    if (_notFirstLayout) {
        // Position the legend
        CGSize newMapSize = _scrollView.frame.size;
        CGFloat orientationScaleX = newMapSize.width / prevMapSize.width;
        CGFloat orientationScaleY = newMapSize.height / prevMapSize.height;
        CGPoint center = _legend.center;
        _legend.center = CGPointMake(center.x * orientationScaleX, center.y * orientationScaleY);
        
        // Make sure it's still within bounds
        frame = _legend.frame;
        [self adjustMapLegendFrameToBounds:&frame];
        _legend.frame = frame;
    }
    _notFirstLayout = YES;
    
    // We have a different layout depending on the orientation
    BOOL landscape = self.bounds.size.width > self.bounds.size.height;
    if (landscape) {
        // The toolbar is hidden
        _toolbar.alpha = 0;
        
        // The first panel is 320px wide
        frame = CGRectMake(0, _navigationBar.frame.origin.y + _navigationBar.frame.size.height, 320, 0);
        frame.size.height = self.bounds.size.height - frame.origin.y;
        _panel1.frame = frame;
        
        // The second panel is also 320px wide, with a 1px space in between
        frame.origin.x += 320 + 1;
        _panel2.frame = frame;
        
        // The third panel consumes the remaining space
        frame.origin.x += 320;
        frame.size.width = self.bounds.size.width - frame.origin.x;
        _panel3.frame = frame;
    }
    else {
        // The toolbar is visible
        _toolbar.alpha = 1;
        
        // The first panel consumes half the horizontal space
        frame = CGRectMake(0, _navigationBar.frame.origin.y + _navigationBar.frame.size.height, self.bounds.size.width / 2, 0);
        frame.size.height = 116;
        _panel1.frame = frame;
        
        // The second panel goes below the first one
        frame.origin.y += _panel1.frame.size.height;
        frame.size.height = self.bounds.size.height - frame.origin.y - _toolbar.frame.size.height;
        _panel2.frame = frame;
        
        // The third panel consumes the remaining space to the right
        frame = CGRectMake(_panel1.frame.size.width, _panel1.frame.origin.y, _panel1.frame.size.width, 0);
        frame.size.height = self.bounds.size.height - frame.origin.y - _toolbar.frame.size.height;
        _panel3.frame = frame;
    }
}

- (void)adjustMapLegendFrameToBounds:(CGRect *)frame {
    // The X coordinates are easy
    CGFloat maxX = self.bounds.size.width - _legend.frame.size.width;
    if (frame->origin.x < 0)
        frame->origin.x = 0;
    else if (frame->origin.x > maxX)
        frame->origin.x = maxX;
    
    // For the Y coordinates, we need to take the top bar into account
    CGFloat maxY = _navigationBar.frame.origin.y - _legend.frame.size.height;
    if (frame->origin.y < 0)
        frame->origin.y = 0;
    else if (frame->origin.y > maxY)
        frame->origin.y = maxY;
}

@end
