//
//  MapImageViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "CountryDetector.h"
#import "CountryListViewController.h"
#import "DataManager.h"
#import "MapImageViewController.h"
#import "SimulationEngine.h"
#import "UIColor+NFAppColors.h"

@implementation MapImageViewController {
    NSString *_selectedCountry;
    CountryDetector *_countryDetector;
}

- (void)viewDidLoad
{
    // Set the mask color for the map
    self.mapImageView.maskColor = [UIColor nf_mapMaskColor];

    // Set up the single tap gesture recognizer
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.mapImageView addGestureRecognizer:singleTap];
    
    // Set up the double tap gesture recognizer
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.mapImageView addGestureRecognizer:doubleTap];
    
    // Make the single tap recognizer require the double tap
    // recognizer to fail, so it doesn't get called too
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // Create the country detector
    _countryDetector = [CountryDetector new];
    
    // Observe changes to the country selection
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
    
    // Observe steps taken by the simulator
    [nc addObserver:self selector:@selector(simulationEngineStepTaken:) name:SimulationEngineStepTakenNotification object:nil];
}

- (void)dealloc
{
    // We're no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Nothing to do if we're the source of the notification
    if (notification.object == self)
        return;
    
    // Perform the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    _selectedCountry = [selection copy];
    [self.mapImageView deselectCurrentCountry];
    if (![selection isEqualToString:@"world"]) {
        [self.mapImageView selectCountry:selection];
    }
    
    // Check if we need to unfocus
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
        && [notification.object isKindOfClass:[CountryListViewController class]]) {
        _scrollView.zoomScale = _scrollView.minimumZoomScale;
    }
}

- (void)simulationEngineStepTaken:(NSNotification *)notification
{
    // Get the sets of births and deaths
    NSMutableSet *births = [notification.userInfo[SimulationEngineBirthsKey] mutableCopy];
    NSMutableSet *deaths = [notification.userInfo[SimulationEngineDeathsKey] mutableCopy];
    
    // Get their intersection
    NSMutableSet *both = [births mutableCopy];
    [both intersectSet:deaths];
    
    // Remove their intersection from the individual sets
    for (NSString *countryCode in both) {
        [births removeObject:countryCode];
        [deaths removeObject:countryCode];
    }
    
    // Highlight them individually
    if (births.count) {
        [self.mapImageView blinkCountries:births.allObjects color:[UIColor nf_birthBlinkColor]];
        for (NSString *countryCode in births) {
            [self.mapImageView flashIcon:[UIImage imageNamed:@"birth.png"] atCountry:countryCode];
        }
    }
    if (deaths.count) {
        [self.mapImageView blinkCountries:deaths.allObjects color:[UIColor nf_deathBlinkColor]];
        for (NSString *countryCode in deaths) {
            [self.mapImageView flashIcon:[UIImage imageNamed:@"death.png"] atCountry:countryCode];
        }
    }
    if (both.count) {
        [self.mapImageView blinkCountries:both.allObjects color:[UIColor nf_birthAndDeathBlinkColor]];
        for (NSString *countryCode in both) {
            [self.mapImageView flashIcon:[UIImage imageNamed:@"birth+death.png"] atCountry:countryCode];
        }
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    // Find the touch center
    CGPoint center = [recognizer locationInView:self.mapImageView];
    
    // Normalize the point
    center = CGPointMake(center.x / _scrollView.frame.size.width, center.y / _scrollView.frame.size.height);
    
    // If the view controller was autorotating, the scroll view we're using to normalize the
    // center of the touch may have a different size already. If that's the case, we'll get
    // a normalized point out of bounds, so we skip this touch
    if (center.x > 1 || center.y > 1) {
        return;
    }
    
    // Find the country
    NSString *country = [_countryDetector countryAtNormalizedPoint:center];
    
    // If it's the same as the selected country, handle this as if
    // the ocean had been touched
    if (country && [country isEqualToString:_selectedCountry]) {
        country = nil;
    }
    
    // If it's a country for which we don't have any info, also handle
    // it that same way
    if (country && ![DataManager sharedDataManager].countryData[country]) {
        country = nil;
    }
    
    // Either select the country or deselect the current
    // selection in the map
    if (country) {
        [self.mapImageView selectCountry:country];
    } else {
        [self.mapImageView deselectCurrentCountry];
    }
    
    // Save the selection
    NSString *selection = country ? country : @"world";
    _selectedCountry = selection;
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : selection}];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (_scrollView.zoomScale == _scrollView.minimumZoomScale) {
        // Zoom in close to where the touch happened
        CGPoint center = [recognizer locationInView:self.mapImageView];
        CGRect zoomRect;
        zoomRect.size.width = self.mapImageView.frame.size.width / _scrollView.maximumZoomScale;
        zoomRect.size.height = self.mapImageView.frame.size.height / _scrollView.maximumZoomScale;
        zoomRect.origin.x = center.x - zoomRect.size.width / 2;
        zoomRect.origin.y = center.y - zoomRect.size.height / 2;
        [_scrollView zoomToRect:zoomRect animated:YES];
    }
    else {
        // Back to the minimum zoom level
        [_scrollView setZoomScale:_scrollView.minimumZoomScale animated:YES];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.mapImageView;
}

@end
