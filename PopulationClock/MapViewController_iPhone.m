//
//  MapViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "MapViewController_iPhone.h"

@implementation MapViewController_iPhone {
    UIView *_mapView;
}

- (void)loadView
{
    [super loadView];
    
    // Add the contained view controller
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"mapImageViewController"];
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:controller.view];
    _mapView = controller.view.subviews[0];
    [controller didMoveToParentViewController:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    // Scale the map to fill the screen on the iPhone 5
    _mapView.frame = _mapView.superview.bounds;
}

@end
