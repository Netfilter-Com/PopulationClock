//
//  CountryInfoPanelView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CountryInfoPanelView.h"

@implementation CountryInfoPanelView {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UIScrollView *_portraitScrollView;
    IBOutlet __weak UIImageView *_landscapeFlag;
    IBOutlet __weak UILabel *_landscapeCountryName;
    IBOutlet __weak UIWebView *_webView;
    UIImageView *_portraitFlags[3];
}

- (void)awakeFromNib {
    // Add a border to the landscape flag
    _landscapeFlag.layer.borderColor = [UIColor whiteColor].CGColor;
    _landscapeFlag.layer.borderWidth = 2;
    
    // TODO: This is currently hardcoded
    _portraitFlags[0] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"country_flag_ar"]];
    _portraitFlags[1] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"country_flag_br"]];
    _portraitFlags[2] = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"country_flag_co"]];
    
    // Apply a border and shadow to the portrait flags,
    // then add them to the scrollview
    // TODO: This will be moved to where we load the flags
    for (int i = 0; i < 3; ++i) {
        UIImageView *flag = _portraitFlags[i];
        flag.layer.borderColor = [UIColor whiteColor].CGColor;
        flag.layer.borderWidth = 4;
        flag.layer.shadowOffset = CGSizeMake(2, 2);
        flag.layer.shadowColor = [UIColor blackColor].CGColor;
        flag.layer.shadowOpacity = 0.6;
        [_portraitScrollView addSubview:flag];
    }
}

- (void)enableOrDisableViews:(BOOL)portrait {
    // Calculate the alpha for the portrait and landscape views
    CGFloat portraitAlpha, landscapeAlpha;
    if (portrait) {
        portraitAlpha = 1;
        landscapeAlpha = 0;
    }
    else {
        portraitAlpha = 0;
        landscapeAlpha = 1;
    }
    
    // Set them for the views
    _portraitScrollView.alpha = portraitAlpha;
    _landscapeFlag.alpha = landscapeAlpha;
    _landscapeCountryName.alpha = landscapeAlpha;
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"bgInfoPaisHoriz"];
        
        // Hide or show the views
        [self enableOrDisableViews:NO];
        
        // Resize and position the flag
        CGSize flagSize = _landscapeFlag.image.size;
        CGFloat scale = 31 / flagSize.height;
        _landscapeFlag.frame = CGRectMake(20, 20, flagSize.width * scale, flagSize.height * scale);
        
        // Position the country label
        [_landscapeCountryName sizeToFit];
        CGRect frame = _landscapeCountryName.frame;
        frame.origin.x = _landscapeFlag.frame.origin.x + _landscapeFlag.frame.size.width + 8;
        _landscapeCountryName.frame = frame;
        _landscapeCountryName.center = CGPointMake(_landscapeCountryName.center.x, _landscapeFlag.center.y);
        
        // Position the web view
        frame = CGRectMake(20, 0, self.bounds.size.width - 40, 0);
        frame.size.height = self.bounds.size.height - _landscapeFlag.frame.origin.y - _landscapeFlag.frame.size.height - 40;
        frame.origin.y = self.bounds.size.height - 20 - frame.size.height;
        _webView.frame = frame;
    }
    else {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"bgInfoPaisVert"];
        
        // Hide or show the views
        [self enableOrDisableViews:YES];
        
        // Position the scroll view
        _portraitScrollView.frame = CGRectMake(0, 20, self.bounds.size.width, 140);
        _portraitScrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, _portraitScrollView.frame.size.height);
        _portraitScrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        
        // Resize and position the flags in the scroll view
        for (int i = 0; i < 3; ++i) {
            UIImageView *flag = _portraitFlags[i];
            CGSize flagSize = flag.image.size;
            CGFloat scale = 126 / flagSize.height;
            flag.frame = CGRectMake(0, 0, flagSize.width * scale, flagSize.height * scale);
            flag.center = CGPointMake(self.bounds.size.width * (i + 0.5), _portraitScrollView.frame.size.height / 2);
        }
        
        // Position the web view
        CGRect frame = CGRectMake(20, 0, self.bounds.size.width - 40, 367);
        frame.origin.y = self.bounds.size.height - 20 - frame.size.height;
        _webView.frame = frame;
    }
}

@end
