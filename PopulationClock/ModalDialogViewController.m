//
//  ModalDialogViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 08/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "ModalDialogViewController.h"

@implementation ModalDialogViewController {
    UIViewController *_currentModalDialogViewController;
    UIView *_dimmedView;
}

- (void)presentModalDialogViewController:(UIViewController *)controller {
    // Make sure we don't already have a current view controller
    assert(!_currentModalDialogViewController);
    
    // Save the controller
    _currentModalDialogViewController = controller;
    
    // Add it to the view controller hierarchy
    [self addChildViewController:controller];
    
    // Add its view to the view hierarchy, then notify the controller
    __weak id weakSelf = self;
    [self addViewToHierarchyAndRun:^{
        [controller didMoveToParentViewController:weakSelf];
    }];
}

- (void)addViewToHierarchyAndRun:(void (^)())block {
    // Make sure the controller's view is at the origin
    // (this also loads the view)
    UIView *cview = _currentModalDialogViewController.view;
    CGRect frame = cview.frame;
    frame.origin = CGPointZero;
    cview.frame = frame;
    
    // Create the view that draws the shadow and add the
    // controller's view to it
    UIView *shadowView = [[UIView alloc] initWithFrame:frame];
    shadowView.layer.shadowRadius = 10;
    shadowView.layer.shadowOpacity = 1;
    [shadowView addSubview:cview];
    
    // Set its autoresizing masks so it goes to landscape properly
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    // Add the shadow view to a dimmed background view
    _dimmedView = [[UIView alloc] initWithFrame:self.view.bounds];
    _dimmedView.backgroundColor = [UIColor clearColor];
    _dimmedView.opaque = NO;
    [_dimmedView addSubview:shadowView];
    [self.view addSubview:_dimmedView];
    
    // Set its autoresizing masks so it goes to landscape properly
    _dimmedView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Apply rounded corners to the controller's view
    cview.layer.cornerRadius = 5;
    cview.layer.masksToBounds = YES;
    
    // Animate everything
    shadowView.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.bounds.size.height);
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _dimmedView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        shadowView.center = CGPointMake(self.view.center.x, self.view.center.y);
    } completion:^(BOOL finished) {
        block();
    }];
}

- (void)dismissCurrentModalDialogViewController {
    // Notify the controller that we're starting to get rid of it
    [_currentModalDialogViewController willMoveToParentViewController:nil];
    
    // Remove its view from the view hierarchy, then notify the controller
    [self removeViewFromHierarchyAndRun:^{
        [_currentModalDialogViewController didMoveToParentViewController:nil];
        _currentModalDialogViewController = nil;
    }];
}

- (void)removeViewFromHierarchyAndRun:(void (^)())block {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        // Make the dimmed view transparent again
        _dimmedView.backgroundColor = [UIColor clearColor];
        
        // Move the shadow view away
        UIView *shadowView = _dimmedView.subviews[0];
        shadowView.center = CGPointMake(self.view.center.x, self.view.center.y + self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        // Get rid of the dimmed view
        [_dimmedView removeFromSuperview];
        
        // Invoke the block
        block();
    }];
}

@end
