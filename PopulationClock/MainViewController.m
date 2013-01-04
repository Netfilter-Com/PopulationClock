//
//  MainViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <Twitter/Twitter.h>

#import "CountryDetector.h"
#import "GADBannerView.h"
#import "InAppPurchaseManager.h"
#import "MainView.h"
#import "MainViewController.h"
#import "MapImageView.h"
#import "MBProgressHUD.h"
#import "SimulationEngine.h"

#define MAP_MASK_COLOR [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]
#define GAME_SHORT_URL @"http://bit.ly/populationclock"

@implementation MainViewController {
    CountryDetector *_countryDetector;
    IBOutlet __weak UIScrollView *_scrollView;
    IBOutlet __weak MapImageView *_map;
    IBOutlet __weak UIToolbar *_toolbar;
    IBOutlet __weak UIBarButtonItem *_removeAdsButton;
    UIColor *_birthBlinkColor, *_deathBlinkColor, *_bothBlinkColor;
    GADBannerView *_adView;
}

- (void)viewDidLoad {
    // Create the colors
    _birthBlinkColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
    _deathBlinkColor = [UIColor colorWithRed:0 green:0 blue:0.5 alpha:0.2];
    _bothBlinkColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.75 alpha:0.2];
    
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
    
    // Observe steps taken by the simulator
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(simulationEngineStepTaken:) name:SimulationEngineStepTakenNotification object:nil];
    
    // Load the selected country from the saved state
    NSString *savedSelection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryKey];
    if (!savedSelection)
        savedSelection = @"world";
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : savedSelection}];
    
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
        // Create the banner view
        _adView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        _adView.adUnitID = @"a150db06a46d404";
        _adView.rootViewController = self;
        [(MainView *)self.view setAdView:_adView];
        [self.view addSubview:_adView];
        
        // Create and load the request
        GADRequest *request = [GADRequest request];
#ifdef DEBUG
        request.testing = YES;
#endif
        [_adView loadRequest:request];
        
        // Be notified of purchase notifications so we can get rid of the ad
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(purchaseDone:) name:InAppPurchasePurchasedRemoveAds object:nil];
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
    
    // If the map isn't the source of the notification, perform the selection)
    if (notification.object != _map) {
        [_map deselectCurrentCountry];
        if (![selection isEqualToString:@"world"])
            [_map selectCountry:selection maskColor:MAP_MASK_COLOR];
    }
}

- (void)simulationEngineStepTaken:(NSNotification *)notification {
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
    if (births.count)
        [_map blinkCountries:births.allObjects color:_birthBlinkColor];
    if (deaths.count)
        [_map blinkCountries:deaths.allObjects color:_deathBlinkColor];
    if (both.count)
        [_map blinkCountries:both.allObjects color:_bothBlinkColor];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    // Find the touch center
    CGPoint center = [recognizer locationInView:_map];
    
    // Normalize the point
    center = CGPointMake(center.x / _scrollView.frame.size.width, center.y / _scrollView.frame.size.height);
    
    // Find the country
    NSString *country = [_countryDetector countryAtNormalizedPoint:center];
    if (country)
        [_map selectCountry:country maskColor:MAP_MASK_COLOR];
    else
        [_map deselectCurrentCountry];
    
    // Let others know about this selection
    NSString *selection = country ? country : @"world";
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

- (IBAction)ShareApp:(id)sender {
    // Compose the message
    NSString *message = NSLocalizedString(@"I loved %@, awesome app for iPad! %@", @"");
    NSString *gameName = [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    if (!gameName)
        gameName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleNameKey];
    message = [NSString stringWithFormat:message, gameName, GAME_SHORT_URL];
    
    // If we have the activity view controller, use it
    if (NSClassFromString(@"UIActivityViewController")) {
        NSArray *items = @[ message, [UIImage imageNamed:@"Icon-72"] ];
        NSArray *exclude = @[
        UIActivityTypeAssignToContact,
        UIActivityTypeSaveToCameraRoll,
        UIActivityTypePrint,
        UIActivityTypeCopyToPasteboard
        ];
        UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
        controller.excludedActivityTypes = exclude;
        [self presentModalViewController:controller animated:YES];
        return;
    }
    
    // If we have Twitter support, use that
    if (NSClassFromString(@"TWTweetComposeViewController")) {
        TWTweetComposeViewController *controller = [[TWTweetComposeViewController alloc] init];
        [controller setInitialText:message];
        [controller addImage:[UIImage imageNamed:@"Icon-72"]];
        [self presentModalViewController:controller animated:YES];
        return;
    }
    
    // No deal, this shouldn't normally happen
    assert(NO);
}

- (IBAction)purchaseButtonTouched:(id)sender {
    // Show the HUD
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Contacting the App Store", @"");
    hud.dimBackground = YES;
    
    // Purchase the option to remove ads
    [[InAppPurchaseManager sharedInstance] purchaseRemoveAdsWithCallback:^(BOOL purchased) {
        // Hide the HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        // Check if the purchase is complete
        if (purchased)
            [self purchaseDone:nil];
    }];
}

- (void)purchaseDone:(NSNotification *)notification {
    // Get rid of the ads once the user has purchased this option
    [_adView removeFromSuperview];
    
    // Get rid of the button too
    NSMutableArray *toolbarButtons = [_toolbar.items mutableCopy];
    [toolbarButtons removeObject:_removeAdsButton];
    _toolbar.items = toolbarButtons;
}

@end
