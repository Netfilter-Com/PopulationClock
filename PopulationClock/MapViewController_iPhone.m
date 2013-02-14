//
//  MapViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "MapViewController_iPhone.h"
#import "MapImageView.h"
#import "MapLegendView.h"
#import "SavedStateManager.h"
#import "UIColor+NFAppColors.h"

@implementation MapViewController_iPhone {
    MapImageView *_mapView;
    IBOutlet UIToolbar *_toolbar;
    IBOutlet MapLegendView *_legend;
    GADBannerView *_adView;
    BOOL _adjustedMapSize;
}

- (void)loadView
{
    [super loadView];
    
    // Add the contained view controllers, starting with
    // the map view controller
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapImageViewController"];
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:controller.view atIndex:0];
    _mapView = (MapImageView *)controller.view.subviews[0];
    [controller didMoveToParentViewController:self];
    
    NSMutableArray *toolbarItemContainers = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *toolbarItems = [NSMutableArray arrayWithCapacity:3];
    
    // TODO: Add the population clock
    
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    
    // Then the flag view controller
    controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapViewFlagViewController"];
    [toolbarItemContainers addObject:controller];
    [toolbarItems addObject:[[UIBarButtonItem alloc] initWithCustomView:controller.view]];
    [self addChildViewController:controller];
    
    // Set the toolbar items
    _toolbar.items = toolbarItems;
    for (UIViewController *controller in toolbarItemContainers) {
        [controller didMoveToParentViewController:self];
    }
}

- (void)viewDidLoad
{
    // Load the selected country from the saved state
    [SavedStateManager sharedInstance];
    
    // Set up a gesture recognizer on the legend
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(legendTapGestureRecognized:)];
    [_legend addGestureRecognizer:tapGestureRecognizer];
    
    // Start with the legend collapsed
    [_legend setCollapsed:YES animated:NO];
    
    // Add the ad banner
    AdManager *adManager = [AdManager sharedInstance];
    adManager.delegate = self;
    _adView = [adManager adBannerViewWithSize:kGADAdSizeBanner];
    if (_adView) {
        _adView.alpha = 0.0f;
        _adView.delegate = self;
        _adView.rootViewController = self;
        [self.view addSubview:_adView];
        [adManager doneConfiguringAdBannerView:_adView];
        
        CGRect frame = _adView.frame;
        frame.origin.x = self.view.bounds.size.width - frame.size.width;
        frame.origin.y = self.view.bounds.size.height - frame.size.height - _toolbar.frame.size.height;
        _adView.frame = frame;
        _adView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    // Scale the map to fill the screen on the iPhone 5
    if (!_adjustedMapSize) {
        _mapView.frame = _mapView.superview.bounds;
        _adjustedMapSize = YES;
    }
 
    // Unpause the map animations
    _mapView.paused = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    // Pause the map animations
    _mapView.paused = YES;
}

- (void)legendTapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [_legend setCollapsed:!_legend.isCollapsed animated:YES];
    }
}

- (NSArray *)extraToolbarItemsForCarouselViewController:(NFCarouselViewController *)controller
{
    UILabel *label = [UILabel new];
    label.text = NSLocalizedString(@"Population Clock", nil);
    label.font = [UIFont boldSystemFontOfSize:20];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor nf_orangeTextColor];
    label.shadowColor = [UIColor blackColor];
    label.shadowOffset = CGSizeMake(0, -1);
    [label sizeToFit];
    return @[[[UIBarButtonItem alloc] initWithCustomView:label]];
}

- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    [UIView animateWithDuration:0.3 animations:^{
        _adView.alpha = 1.0f;
    }];
}

- (void)adManagerShouldHideAdView:(AdManager *)manager
{
    [_adView removeFromSuperview];
}

@end
