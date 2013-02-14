//
//  CountryInfoWebView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 20/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryInfoWebView.h"
#import "DataManager.h"
#import "StatsBuilder.h"

@implementation CountryInfoWebView {
    BOOL _didLayout;
    UIInterfaceOrientation _interfaceOrientationForLayout;
    NSString *_selectedCountry;
}

- (void)awakeFromNib {
    // Disable bouncing
    self.scrollView.bounces = NO;
    
    // Remove some random shadows (where does this come from?)
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
    }
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Get the selection
    _selectedCountry = notification.userInfo[SelectedCountryKey];
    
    // Force a layout
    _didLayout = NO;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    // Nothing to do until we have a selection
    if (!_selectedCountry)
        return;
    
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // Nothing to do if the interface orientation didn't change
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    BOOL isPortrait = UIInterfaceOrientationIsPortrait(orientation);
    if (_didLayout && isPortrait == UIInterfaceOrientationIsPortrait(_interfaceOrientationForLayout))
        return;
    
    // Change the scroll bar behavior depending whether we're
    // in portrait or landscape
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.scrollView.indicatorStyle = isPortrait ? UIScrollViewIndicatorStyleBlack : UIScrollViewIndicatorStyleWhite;
    }
    
    // Load the right template depending on the orientation
    NSString *templateName = isPortrait ? @"info_template_portrait" : @"info_template_landscape";
    NSString *path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    // Get the short paragraph about the country
    NSString *description = [[NSBundle mainBundle] localizedStringForKey:_selectedCountry value:_selectedCountry table:@"Description"];
    
    // Create the substitution dictionary
    NSDictionary *substitutions;
    if (isPortrait || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSDictionary *info = [DataManager sharedDataManager].countryData[_selectedCountry];
        substitutions = @{
            @"%%NAME%%" : info[@"name"],
            @"%%DESCRIPTION%%" : description,
            @"%%READ_MORE_LINK%%" : NSLocalizedString(@"[Read more]", @""),
            @"%%STATS%%" : [[StatsBuilder new] statsStringForCountryCode:_selectedCountry]
        };
    }
    else {
        substitutions = @{ @"%%DESCRIPTION%%" : description };
    }
    
    // Perform the template substitutions
    for (NSString *key in substitutions.allKeys)
        template = [template stringByReplacingOccurrencesOfString:key withString:substitutions[key]];
    
    // Load the HTML
    NSURL *baseURL = [NSURL fileURLWithPath:[path stringByDeletingLastPathComponent] isDirectory:YES];
    [self loadHTMLString:template baseURL:baseURL];
    
    // Save the new orientation
    _interfaceOrientationForLayout = orientation;
    _didLayout = YES;
}

@end
