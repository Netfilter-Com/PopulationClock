//
//  CountryInfoPanelView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryInfoPanelView.h"

@implementation CountryInfoPanelView {
    IBOutlet __weak UIImageView *_backgroundImageView;
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
        _backgroundImageView.image = [UIImage imageNamed:@"bgInfoPaisHoriz"];
    else
        _backgroundImageView.image = [UIImage imageNamed:@"bgInfoPaisVert"];
}

@end
