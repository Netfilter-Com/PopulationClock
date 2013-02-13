//
//  MapViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "MapViewController_iPhone.h"
#import "MapLegendView.h"
#import "SavedStateManager.h"

@implementation MapViewController_iPhone {
    UIView *_mapView;
    IBOutlet UIToolbar *_toolbar;
    IBOutlet MapLegendView *_legend;
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
    _mapView = controller.view.subviews[0];
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
}

- (void)viewDidAppear:(BOOL)animated
{
    // Scale the map to fill the screen on the iPhone 5
    _mapView.frame = _mapView.superview.bounds;
}


- (void)legendTapGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        [_legend setCollapsed:!_legend.isCollapsed animated:YES];
    }
}

@end
