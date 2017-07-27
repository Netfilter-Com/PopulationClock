//
//  TopBarView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 17/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "TopBarView.h"
#import "UIColor+NFAppColors.h"

@implementation TopBarView {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UILabel *_titleLabel;
    IBOutlet __weak UISegmentedControl *_modeSegmentedControl;
    IBOutlet __weak UIImageView *_rotateImageView;
    IBOutlet __weak UILabel *_rotateLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Set the label colors for the segmented control
    NSDictionary *attrs = @{NSForegroundColorAttributeName : [UIColor nf_orangeTextColor]};
    [_modeSegmentedControl setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [_modeSegmentedControl setTitleTextAttributes:attrs forState:UIControlStateHighlighted];
    
    // Style the segmented control
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIImage *separator = [UIImage imageNamed:@"separadorAtiveInactive"];
        [_modeSegmentedControl setBackgroundImage:[UIImage imageNamed:@"bgBtHeadInactive"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [_modeSegmentedControl setBackgroundImage:[UIImage imageNamed:@"bgBtHeadActive"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_modeSegmentedControl setDividerImage:separator forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        [_modeSegmentedControl setDividerImage:separator forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    } else {
        [_modeSegmentedControl setTintColor:[UIColor nf_orangeTextColor]];
    }

    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Ignore this if we're the source of the notification
    if (notification.object == self)
        return;
    
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // If a real country was selected, save that
    BOOL isWorld = [selection isEqualToString:@"world"];
    if (!isWorld) {
        [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryNoWorldKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Change the value of the segmented control
    _modeSegmentedControl.selectedSegmentIndex = isWorld ? 0 : 1;
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different layout depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"barraHoriz"];
        
        // Resize the mode segmented control
        [_modeSegmentedControl sizeToFit];
        
        // Position it
        _modeSegmentedControl.center = CGPointMake(160, self.bounds.size.height / 2);
        
        // Resize the title label
        _titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_titleLabel sizeToFit];
        
        // Position it
        _titleLabel.center = CGPointMake(320 + 1 + 320, self.bounds.size.height / 2);
        
        // The rotate label and image view are visible
        _rotateLabel.alpha = 1;
        _rotateImageView.alpha = 1;
    }
    else {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"barraVert"];
        
        // Resize the mode segmented control
        CGRect frame = _modeSegmentedControl.frame;
        frame.size.width = 320;
        _modeSegmentedControl.frame = frame;
        
        // Position it
        _modeSegmentedControl.center = CGPointMake(self.bounds.size.width / 4, self.bounds.size.height / 2);
        
        // Resize the title label
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_titleLabel sizeToFit];
        
        // Position it
        _titleLabel.center = CGPointMake(self.bounds.size.width * 3 / 4, self.bounds.size.height / 2);
        
        // The rotate label and image view are hidden
        _rotateLabel.alpha = 0;
        _rotateImageView.alpha = 0;
    }
}

- (IBAction)segmentedControlSelectionChanged:(id)sender {
    // Find the selection
    NSString *selection;
    if (_modeSegmentedControl.selectedSegmentIndex == 0) {
        selection = @"world";
    }
    else {
        // Look at the last country selection, default to Brazil
        selection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryNoWorldKey];
        if (!selection)
            selection = @"br";
    }
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : selection}];
}

@end
