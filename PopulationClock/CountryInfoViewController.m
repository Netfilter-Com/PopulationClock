//
//  CountryInfoViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryInfoViewController.h"
#import "DataManager.h"

@implementation CountryInfoViewController {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UIScrollView *_portraitScrollView;
    IBOutlet __weak UIButton *_portraitArrowLeft;
    IBOutlet __weak UIButton *_portraitArrowRight;
    IBOutlet __weak UIView *_portraitWebViewBackground;
    IBOutlet __weak UIView *_landscapeFlag;
    IBOutlet __weak UILabel *_landscapeCountryName;
    IBOutlet __weak UIWebView *_webView;
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Change the landscape flag and apply a border unless we're showing the globe
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    NSString *countryCode = info[@"code"];
    if ([countryCode isEqualToString:@"world"]) {
        // Set the globe image
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"globeHoriz"]];
        [_landscapeFlag.superview insertSubview:imageView aboveSubview:_landscapeFlag];
        [_landscapeFlag removeFromSuperview];
        _landscapeFlag = imageView;
    }
    else {
        // Get the right flag
        NSString *flagName = [NSString stringWithFormat:@"country_flag_%@", countryCode];
        UIImage *image = [UIImage imageNamed:flagName];
        
        // Calculate its new size, including borders
        CGFloat scale = 31 / image.size.height;
        CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));
        
        // Calculate the size of the image centered in the
        // image view by insetting the border width
        CGSize innerSize = newSize;
        innerSize.width -= 4;
        innerSize.height -= 4;

        // Create the background view
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, newSize.width, newSize.height)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        [_landscapeFlag.superview insertSubview:backgroundView aboveSubview:_landscapeFlag];
        [_landscapeFlag removeFromSuperview];
        _landscapeFlag = backgroundView;

        // Add the flag image to the background view
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(2, 2, innerSize.width, innerSize.height);
        [backgroundView addSubview:imageView];
    }
    
    // Change the landscape country name
    _landscapeCountryName.text = info[@"name"];
    
    // Force a layout
    [self.view setNeedsLayout];
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
    _portraitArrowLeft.alpha = portraitAlpha;
    _portraitArrowRight.alpha = portraitAlpha;
    _portraitWebViewBackground.alpha = portraitAlpha;
    _landscapeFlag.alpha = landscapeAlpha;
    _landscapeCountryName.alpha = landscapeAlpha;
}

- (void)viewWillLayoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.view.bounds.size.width == 0 || self.view.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"bgInfoPaisHoriz"];
        
        // Hide or show the views
        [self enableOrDisableViews:NO];
        
        // Position the flag
        _landscapeFlag.frame = CGRectMake(20, 20, _landscapeFlag.frame.size.width, _landscapeFlag.frame.size.height);
        
        // Position the country label
        [_landscapeCountryName sizeToFit];
        CGRect frame = _landscapeCountryName.frame;
        frame.origin.x = _landscapeFlag.frame.origin.x + _landscapeFlag.frame.size.width + 8;
        _landscapeCountryName.frame = frame;
        _landscapeCountryName.center = CGPointMake(_landscapeCountryName.center.x, _landscapeFlag.center.y);
        
        // Position the web view
        frame = CGRectMake(20, 0, self.view.bounds.size.width - 40, 0);
        frame.size.height = self.view.bounds.size.height - _landscapeFlag.frame.origin.y - _landscapeFlag.frame.size.height - 40;
        frame.origin.y = self.view.bounds.size.height - 20 - frame.size.height;
        _webView.frame = frame;
    }
    else {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"bgInfoPaisVert"];
        
        // Hide or show the views
        [self enableOrDisableViews:YES];
        
        // Position the scroll view
        _portraitScrollView.frame = CGRectMake(0, 20, self.view.bounds.size.width, 140);
        
        // Position the arrows
        _portraitArrowLeft.center = CGPointMake(20 + _portraitArrowLeft.frame.size.width / 2, _portraitScrollView.center.y);
        _portraitArrowRight.center = CGPointMake(self.view.bounds.size.width -  20 - _portraitArrowRight.frame.size.width / 2, _portraitScrollView.center.y);
        
        // Position the web view and its background
        CGRect frame = CGRectMake(20, 0, self.view.bounds.size.width - 40, 367);
        frame.origin.y = self.view.bounds.size.height - 20 - frame.size.height;
        _webView.frame = frame;
        _portraitWebViewBackground.frame = frame;
    }
}

@end
