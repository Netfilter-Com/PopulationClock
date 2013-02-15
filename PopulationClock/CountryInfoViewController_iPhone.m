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
#import "UIColor+NFAppColors.h"

@interface CountryInfoViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UIView *leftPanel;
@property (nonatomic, weak) IBOutlet UIView *rightPanel;
@property (nonatomic, weak) IBOutlet UILabel *countryName;

@end

@implementation CountryInfoViewController_iPhone {
    UISegmentedControl *_segmentedControl;
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
    // Nothing to do if we're the source of the notification
    if (notification.object == self) {
        return;
    }
    
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    _selectedCountry = selection;
    
    // If a real country was selected, save that
    BOOL isWorld = [selection isEqualToString:@"world"];
    if (!isWorld) {
        [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryNoWorldKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Update the country name
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    self.countryName.text = [info[@"name"] uppercaseString];
    
    // Update the segment control
    _segmentedControl.selectedSegmentIndex = [selection isEqualToString:@"world"] ? 0 : 1;
}

- (void)viewWillLayoutSubviews
{
    CGFloat width = self.view.bounds.size.width / 2;
    CGFloat height = self.view.bounds.size.height;
    self.leftPanel.frame = CGRectMake(0, 0, width, height);
    self.rightPanel.frame = CGRectMake(width, 0, width, height);
}

- (NSArray *)extraToolbarItemsForCarouselViewController:(NFCarouselViewController *)controller
{
    _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[
        NSLocalizedString(@"World", nil),
        NSLocalizedString(@"Country", nil)
    ]];
    _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [_segmentedControl setWidth:125 forSegmentAtIndex:0];
    [_segmentedControl setWidth:125 forSegmentAtIndex:1];
    
    NSDictionary *attrs = @{UITextAttributeTextColor : [UIColor nf_orangeTextColor]};
    [_segmentedControl setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [_segmentedControl setTitleTextAttributes:attrs forState:UIControlStateHighlighted];
    
    // TODO: Images for the iPhone
    /*UIImage *separator = [UIImage imageNamed:@"separadorAtiveInactive"];
    [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"bgBtHeadInactive"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [_segmentedControl setBackgroundImage:[UIImage imageNamed:@"bgBtHeadActive"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setDividerImage:separator forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [_segmentedControl setDividerImage:separator forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];*/
    
    if (_selectedCountry) {
        _segmentedControl.selectedSegmentIndex = [_selectedCountry isEqualToString:@"world"] ? 0 : 1;
    }
    
    [_segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:_segmentedControl];
    return @[ segmentedControlItem ];
}

- (void)segmentedControlValueChanged:(id)sender
{
    // Find the selection
    NSString *selection;
    if (_segmentedControl.selectedSegmentIndex == 0) {
        selection = @"world";
    }
    else {
        // Look at the last country selection, default to Brazil
        selection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryNoWorldKey];
        if (!selection)
            selection = @"br";
    }
    _selectedCountry = selection;
    
    // Update the country name
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    self.countryName.text = [info[@"name"] uppercaseString];
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification
                                                        object:self
                                                      userInfo:@{SelectedCountryKey : selection}];
}

@end
