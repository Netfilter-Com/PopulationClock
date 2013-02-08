//
//  MainViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "DataManager.h"
#import "InAppPurchaseManager.h"
#import "MainView.h"
#import "MainViewController.h"
#import "MapImageView.h"
#import "MBProgressHUD.h"
#import "PopulationClockView.h"
#import "SimulationEngine.h"
#import "UIViewController+NFSharing.h"

@implementation MainViewController {
    IBOutlet __weak UIView *_legend;
    IBOutlet __weak PopulationClockView *_populationClock;
    IBOutlet __weak UIToolbar *_toolbar;
    IBOutlet __weak UIBarButtonItem *_removeAdsButton;
    IBOutlet __weak UIView *_dimmedView;
    
    CGPoint _legendOrigin;
    
    NSString *_selectedCountry;
    
    GADBannerView *_adView;
}

- (void)dealloc {
    // We're no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadView {
    [super loadView];
    
    // Add the contained view controllers (no embed segues in iOS 5),
    // starting with the map view controller
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapImageViewController"];
    [self addChildViewController:controller];
    [(MainView *)self.view addMapImageViewController:(MapImageViewController *)controller];
    [controller didMoveToParentViewController:self];
    
    // Then the clock view controller
    // TODO: Stop referencing the population clock, make
    // the clock view controller update it on demand
    controller = [self.storyboard instantiateViewControllerWithIdentifier:@"clockViewController"];
    [self addChildViewController:controller];
    [(MainView *)self.view addClockViewController:(ClockViewController *)controller];
    _populationClock = ((ClockViewController *)controller).clock;
    [controller didMoveToParentViewController:self];
    
    // Then the country list view controller
    controller = [self.storyboard instantiateViewControllerWithIdentifier:@"countryListViewController"];
    [self addChildViewController:controller];
    [(MainView *)self.view addCountryListViewController:(CountryListViewController *)controller];
    [controller didMoveToParentViewController:self];
    
    // And finally the country info view controller
    controller = [self.storyboard instantiateViewControllerWithIdentifier:@"countryInfoViewController"];
    [self addChildViewController:controller];
    [(MainView *)self.view addCountryInfoViewController:(CountryInfoViewController *)controller];
    [controller didMoveToParentViewController:self];
}

- (void)viewDidLoad {
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
    [nc postNotificationName:CountrySelectionNotification object:self userInfo:@{
        SelectedCountryKey : _selectedCountry,
        StateRestorationKey : @YES
    }];
    
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

- (void)countrySelectionChanged:(NSNotification *)notification {
    // If we aren't the source of the notification, save the new selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    if (notification.object != self) {
        [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Update the population clock
    _selectedCountry = selection;
    BOOL stateRestoration = [notification.userInfo[StateRestorationKey] boolValue];
    [self updatePopulationClockAnimated:!stateRestoration];
}

- (void)simulationEngineReset:(NSNotification *)notification {
    // Update the population clock with no animation
    [self updatePopulationClockAnimated:NO];
}

- (void)simulationEngineStepTaken:(NSNotification *)notification {
    // Update the population clock
    [self updatePopulationClockAnimated:YES];
}

- (void)updatePopulationClockAnimated:(BOOL)animated {
    NSNumber *number = [SimulationEngine sharedInstance].populationPerCountry[_selectedCountry];
    [_populationClock setPopulation:number.longLongValue animated:animated];
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
