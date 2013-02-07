//
//  MainViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryDetector.h"
#import "DataManager.h"
#import "GADBannerView.h"
#import "InAppPurchaseManager.h"
#import "MainView.h"
#import "MainViewController.h"
#import "MapImageView.h"
#import "MBProgressHUD.h"
#import "PopulationClockView.h"
#import "SimulationEngine.h"
#import "UIColor+NFAppColors.h"
#import "UIViewController+NFSharing.h"

@implementation MainViewController {
    IBOutlet __weak UIScrollView *_scrollView;
    IBOutlet __weak UIView *_legend;
    IBOutlet __weak MapImageView *_map;
    IBOutlet __weak PopulationClockView *_populationClock;
    IBOutlet __weak UIToolbar *_toolbar;
    IBOutlet __weak UIBarButtonItem *_removeAdsButton;
    IBOutlet __weak UIView *_dimmedView;
    
    CGPoint _legendOrigin;
    
    UIColor *_birthBlinkColor, *_deathBlinkColor, *_bothBlinkColor;
    
    NSString *_selectedCountry;
    CountryDetector *_countryDetector;
    
    GADBannerView *_adView;
}

- (void)viewDidLoad {
    // Create the colors
    _birthBlinkColor = [UIColor nf_birthBlinkColor];
    _deathBlinkColor = [UIColor nf_deathBlinkColor];
    _bothBlinkColor = [UIColor nf_birthAndDeathBlinkColor];
    
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
    
    // Set up pan gesture recognizers for the legend
    [_legend addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(legendPanningGestureRecognized:)]];
    
    // Load the selected country from the saved state
    _selectedCountry = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryKey];
    if (!_selectedCountry)
        _selectedCountry = @"world";
    
    // Observe changes to the country selection
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
    
    // Observe resets and steps taken by the simulator
    [nc addObserver:self selector:@selector(simulationEngineReset:) name:SimulationEngineResetNotification object:nil];
    [nc addObserver:self selector:@selector(simulationEngineStepTaken:) name:SimulationEngineStepTakenNotification object:nil];
    
    // Let others know about the current selection
    [nc postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : _selectedCountry}];
    
    // Update the population clock
    [self updatePopulationClockAnimated:NO];
    
    // If the user has purchased the option to remove ads or if he is
    // not able to purchase this option, get rid of the button
    InAppPurchaseManager *iapmgr = [InAppPurchaseManager sharedInstance];
    if (iapmgr.adsRemoved || !iapmgr.canMakePayments) {
        // Get rid of the button
        NSMutableArray *toolbarButtons = [_toolbar.items mutableCopy];
        [toolbarButtons removeObject:_removeAdsButton];
        _toolbar.items = toolbarButtons;
    }
    
    // If the user has not purchased the option, show the ads
    if (!iapmgr.adsRemoved) {
        AdManager *adManager = [AdManager sharedInstance];
        adManager.delegate = self;
        _adView = [adManager adBannerViewWithSize:kGADAdSizeBanner];
        _adView.rootViewController = self;
        [(MainView *)self.view setAdView:_adView];
        [self.view insertSubview:_adView belowSubview:_dimmedView];
        [adManager doneConfiguringAdBannerView:_adView];
    }
}

- (void)viewDidUnload {
    // We're no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Get rid of the country detector
    _countryDetector = nil;
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // If we aren't the source of the notification, save the new selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    if (notification.object != self) {
        [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // If the map isn't the source of the notification, perform the selection
    if (notification.object != _map) {
        _selectedCountry = [selection copy];
        [_map deselectCurrentCountry];
        if (![selection isEqualToString:@"world"])
            [_map selectCountry:selection maskColor:[UIColor nf_mapMaskColor]];
    }
}

- (void)simulationEngineReset:(NSNotification *)notification {
    // Update the population clock with no animation
    [self updatePopulationClockAnimated:NO];
}

- (void)simulationEngineStepTaken:(NSNotification *)notification {
    // Update the population clock
    [self updatePopulationClockAnimated:YES];
    
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
        [_map blinkCountries:births.allObjects color:_birthBlinkColor];
        for (NSString *countryCode in births)
            [_map flashIcon:[UIImage imageNamed:@"birth.png"] atCountry:countryCode];
    }
    if (deaths.count) {
        [_map blinkCountries:deaths.allObjects color:_deathBlinkColor];
        for (NSString *countryCode in deaths)
            [_map flashIcon:[UIImage imageNamed:@"death.png"] atCountry:countryCode];
    }
    if (both.count) {
        for (NSString *countryCode in both)
            [_map flashIcon:[UIImage imageNamed:@"birth+death.png"] atCountry:countryCode];
    }
}

- (void)updatePopulationClockAnimated:(BOOL)animated {
    NSNumber *number = [SimulationEngine sharedInstance].populationPerCountry[_selectedCountry];
    [_populationClock setPopulation:number.longLongValue animated:animated];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    // Find the touch center
    CGPoint center = [recognizer locationInView:_map];
    
    // Normalize the point
    center = CGPointMake(center.x / _scrollView.frame.size.width, center.y / _scrollView.frame.size.height);
    
    // If the view controller was autorotating, the scroll view we're using to normalize the
    // center of the touch may have a different size already. If that's the case, we'll get
    // a normalized point out of bounds, so we skip this touch
    if (center.x > 1 || center.y > 1)
        return;
    
    // Find the country
    NSString *country = [_countryDetector countryAtNormalizedPoint:center];
    
    // If it's the same as the selected country, handle this as if
    // the ocean had been touched
    if (country && [country isEqualToString:_selectedCountry])
        country = nil;
    
    // If it's a country for which we don't have any info, also handle
    // it that same way
    if (country && ![DataManager sharedDataManager].countryData[country])
        country = nil;
    
    // Either select the country or deselect the current
    // selection in the map
    if (country)
        [_map selectCountry:country maskColor:[UIColor nf_mapMaskColor]];
    else
        [_map deselectCurrentCountry];
    
    // Save the selection and update the population clock
    NSString *selection = country ? country : @"world";
    _selectedCountry = selection;
    [self updatePopulationClockAnimated:YES];
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:_map userInfo:@{SelectedCountryKey : selection}];
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

- (void)legendPanningGestureRecognized:(UIPanGestureRecognizer *)recognizer {
    // If this is the first time the pan gesture is being recognized,
    // record the origin of the legend
    if (recognizer.state == UIGestureRecognizerStateBegan)
        _legendOrigin = _legend.frame.origin;
    
    // Adjust the frame with the translation
    CGPoint translation = [recognizer translationInView:self.view];
    CGRect frame = CGRectMake(_legendOrigin.x, _legendOrigin.y, _legend.frame.size.width, _legend.frame.size.height);
    frame.origin.x += translation.x;
    frame.origin.y += translation.y;
    
    // Make sure it won't go out of bounds
    [(MainView *)self.view adjustMapLegendFrameToBounds:&frame];
    
    // Set the frame
    _legend.frame = frame;
}

- (IBAction)ShareApp:(id)sender {
    [self nf_presentShareViewControllerAnimated:YES];
}

- (IBAction)aboutButtonTouched:(id)sender {
    // Instantiate the about view controller manually
    AboutViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutViewController"];
    controller.delegate = self;
    
    // Present it as a modal dialog
    [self presentModalDialogViewController:controller];
}

- (void)aboutViewControllerDone:(AboutViewController *)controller {
    // Dismiss the current modal dialog
    [self dismissCurrentModalDialogViewController];
}

- (IBAction)purchaseButtonTouched:(id)sender {
    // Show the HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Contacting the App Store", @"");
    hud.dimBackground = YES;
    
    // Purchase the option to remove ads
    [[InAppPurchaseManager sharedInstance] purchaseRemoveAdsWithCallback:^(BOOL purchased) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (void)adManagerShouldHideAdView:(AdManager *)manager {
    // Get rid of the ads once the user has purchased this option
    [_adView removeFromSuperview];
    
    // Get rid of the button too
    NSMutableArray *toolbarButtons = [_toolbar.items mutableCopy];
    [toolbarButtons removeObject:_removeAdsButton];
    _toolbar.items = toolbarButtons;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
