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
#import "MBProgressHUD.h"
#import "SavedStateManager.h"
#import "UIViewController+NFSharing.h"

@implementation MainViewController {
    IBOutlet __weak UIView *_legend;
    IBOutlet __weak UIToolbar *_toolbar;
    IBOutlet __weak UIBarButtonItem *_removeAdsButton;
    IBOutlet __weak UIView *_dimmedView;

    CGPoint _legendOrigin;
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
    controller = [self.storyboard instantiateViewControllerWithIdentifier:@"clockViewController"];
    [self addChildViewController:controller];
    [(MainView *)self.view addClockViewController:(ClockViewController *)controller];
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
    [SavedStateManager sharedInstance];

    // There are no more ads to remove, so the purchase is restore-only
    // now (see InAppPurchaseManager) - never show the "Remove ads" button
    NSMutableArray *toolbarButtons = [_toolbar.items mutableCopy];
    [toolbarButtons removeObject:_removeAdsButton];
    _toolbar.items = toolbarButtons;
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
    hud.label.text = NSLocalizedString(@"Contacting the App Store", @"");
    hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.backgroundView.color = [UIColor colorWithWhite:0 alpha:0.2];
    
    // Purchase the option to remove ads
    [[InAppPurchaseManager sharedInstance] purchaseRemoveAdsWithCallback:^(BOOL purchased) {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

@end
