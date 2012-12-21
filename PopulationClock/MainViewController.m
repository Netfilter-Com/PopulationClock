//
//  MainViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryDetector.h"
#import "MainView.h"
#import "MainViewController.h"
#import "MapImageView.h"

@implementation MainViewController {
    CountryDetector *_countryDetector;
    IBOutlet __weak UIScrollView *_scrollView;
    IBOutlet __weak MapImageView *_map;
}

- (void)viewDidLoad {
    // Load the country detector
    _countryDetector = [[CountryDetector alloc] init];
    
    // Set up the single tap gesture recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [_map addGestureRecognizer:singleTap];
    
    // Set up the double tap gesture recognizer
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [_map addGestureRecognizer:doubleTap];
    
    // Make the single tap recognizer require the double tap
    // recognizer to fail, so it doesn't get called too
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
    
    // Load the selected country from the saved state
    NSString *savedSelection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryKey];
    if (!savedSelection)
        savedSelection = @"world";
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : savedSelection}];
}

- (void)viewDidUnload {
    // We're no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Get rid of the country detector
    _countryDetector = nil;
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Ignore this if we're the source of the notification
    if (notification.object == self)
        return;
    
    // Save the new selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    // Find the touch center
    CGPoint center = [recognizer locationInView:_map];
    
    // Normalize the point
    center = CGPointMake(center.x / _scrollView.frame.size.width, center.y / _scrollView.frame.size.height);
    
    // Find the country
    NSString *country = [_countryDetector countryAtNormalizedPoint:center];
    if (country)
        [_map selectCountry:country maskColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]];
    else
        [_map deselectCurrentCountry];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    if (_scrollView.zoomScale == _scrollView.minimumZoomScale) {
        // Zoom in close to where the touch happened
        CGPoint center = [recognizer locationInView:_map];
        CGRect zoomRect;
        zoomRect.size.width = _map.frame.size.width / _scrollView.maximumZoomScale;
        zoomRect.size.height = _map.frame.size.height / _scrollView.maximumZoomScale;
        zoomRect.origin.x = center.x - zoomRect.size.width / 2;
        zoomRect.origin.y = center.y - zoomRect.size.height / 2;
        [_scrollView zoomToRect:zoomRect animated:YES];
    }
    else {
        // Back to the minimum zoom level
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _map;
}

@end
