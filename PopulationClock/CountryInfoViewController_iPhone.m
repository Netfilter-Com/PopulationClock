//
//  CountryInfoViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "CountryInfoViewController_iPhone.h"
#import "DataManager.h"
#import "PopulationClockView.h"

@interface CountryInfoViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UIView *leftPanel;
@property (nonatomic, weak) IBOutlet UIView *rightPanel;
@property (nonatomic, weak) IBOutlet UILabel *countryName;

@end

@implementation CountryInfoViewController_iPhone {
    NSString *_selectedCountry;
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(countrySelectionChanged:)
                                                 name:CountrySelectionNotification
                                               object:nil];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Update the country name
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    self.countryName.text = [info[@"name"] uppercaseString];
}

- (void)viewWillLayoutSubviews
{
    CGFloat width = self.view.bounds.size.width / 2;
    CGFloat height = self.view.bounds.size.height;
    self.leftPanel.frame = CGRectMake(0, 0, width, height);
    self.rightPanel.frame = CGRectMake(width, 0, width, height);
}

@end
