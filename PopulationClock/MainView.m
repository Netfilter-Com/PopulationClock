//
//  MainView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "MainView.h"

@implementation MainView {
    IBOutlet __weak UIScrollView *_scrollView;
    IBOutlet __weak UIImageView *_map;
    IBOutlet __weak UIView *_navigationBar;
    IBOutlet __weak UIView *_panel1;
    IBOutlet __weak UIView *_panel2;
    IBOutlet __weak UIView *_panel3;
    IBOutlet __weak UIToolbar *_toolbar;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Configure the scroll view properties
        self.scrollEnabled = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = 0;
        
        // Add observers to the keyboard
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    // Remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    // Get the keyboard size
    CGSize kbSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    // The keyboard size doesn't follow the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat tmp = kbSize.width;
        kbSize.width = kbSize.height;
        kbSize.height = tmp;
    }
    
    // Adjust the content
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.contentInset = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
    self.contentOffset = CGPointMake(0, kbSize.height);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Adjust the content
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.contentInset = UIEdgeInsetsZero;
    self.contentOffset = CGPointZero;
    [UIView commitAnimations];
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
    frame.origin.y = mapSize.height;
    _navigationBar.frame = frame;
    
    // We have a different layout depending on the orientation
    BOOL landscape = self.bounds.size.width > self.bounds.size.height;
    if (landscape) {
        // The toolbar is hidden
        _toolbar.hidden = YES;
        
        // The first panel is 320px wide
        frame = CGRectMake(0, _navigationBar.frame.origin.y + _navigationBar.frame.size.height, 320, 0);
        frame.size.height = self.bounds.size.height - frame.origin.y;
        _panel1.frame = frame;
        
        // The second panel is also 320px wide
        frame.origin.x += 320;
        _panel2.frame = frame;
        
        // The third panel consumes the remaining space
        frame.origin.x += 320;
        frame.size.width = self.bounds.size.width - frame.origin.x;
        _panel3.frame = frame;
    }
    else {
        // The toolbar is visible
        _toolbar.hidden = NO;
        
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

@end
