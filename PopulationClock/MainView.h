//
//  MainView.h
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryInfoViewController.h"
#import "CountryListViewController.h"
#import "MapImageViewController.h"

@interface MainView : UIScrollView

@property (nonatomic, weak) UIView *adView;

- (void)addMapImageViewController:(MapImageViewController *)controller;
- (void)addCountryListViewController:(CountryListViewController *)controller;
- (void)addCountryInfoViewController:(CountryInfoViewController *)controller;

- (void)adjustMapLegendFrameToBounds:(CGRect *)frame;

@end
