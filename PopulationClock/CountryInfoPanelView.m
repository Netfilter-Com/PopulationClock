//
//  CountryInfoPanelView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CountryInfoPanelView.h"
#import "DataManager.h"
#import "UIImage+NFResizable.h"

@implementation CountryInfoPanelView {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UIScrollView *_portraitScrollView;
    IBOutlet __weak UIImageView *_portraitArrowLeft;
    IBOutlet __weak UIImageView *_portraitArrowRight;
    IBOutlet __weak UIImageView *_portraitWebViewBackground;
    IBOutlet __weak UIImageView *_landscapeFlag;
    IBOutlet __weak UILabel *_landscapeCountryName;
    IBOutlet __weak UIWebView *_webView;
    UIImageView *_portraitFlags[3];
    NSString *_portraitCountryCodes[3];
}

- (void)awakeFromNib {
    // Set up the gesture recognizer for the arrows
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTouched:)];
    recognizer.numberOfTapsRequired = 1;
    [_portraitScrollView addGestureRecognizer:recognizer];
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Note that we don't ignore notifications coming from ourselves
    // because even in that case we still have to change the flags
    // and other info.
    
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Find the index of the selection
    NSArray *countries = [DataManager sharedDataManager].orderedCountryData;
    NSUInteger index = NSNotFound;
    for (int i = 0; i < countries.count; ++i) {
        NSDictionary *info = countries[i];
        if ([info[@"code"] isEqualToString:selection]) {
            index = i;
            break;
        }
    }
    assert(index != NSNotFound);
    
    // Remove all of the scrollview's subviews
    for (UIView *subview in _portraitScrollView.subviews)
        [subview removeFromSuperview];
    
    /*
     * Note that the way we implemented borders really sucks. The reason we're doing
     * this is that CALayer borders overlap the content. I couldn't get alternatives
     * like drawing a new image with the borders to work as they all got ridiculously
     * blurry. This should be possible, though, so if you can figure out, please
     * replace this crap with something that doesn't suck as much.
     */
    
    // Change the portrait flags
    int indices[3] = { index == 0 ? countries.count - 1 : index - 1, index, (index + 1) % countries.count };
    for (int i = 0; i < 3; ++i) {
        // Get the country info and country code
        NSDictionary *info = countries[indices[i]];
        NSString *countryCode = info[@"code"];
        
        // Get the flag into an image view and apply a border and shadow
        // unless we're showing the globe
        UIImageView *flag;
        if ([countryCode isEqualToString:@"world"]) {
            flag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"globeVertical"]];
        }
        else {
            // Get the right flag
            NSString *flagName = [NSString stringWithFormat:@"country_flag_%@", countryCode];
            UIImage *image = [UIImage imageNamed:flagName];
            
            // Calculate its new size, including borders
            CGFloat scale = 126 / image.size.height;
            CGSize newSize = CGSizeMake(floorf(image.size.width * scale), floorf(image.size.height * scale));
            
            // Calculate the size of the image centered in the
            // image view by insetting the border width
            CGSize innerSize = newSize;
            innerSize.width -= 8;
            innerSize.height -= 8;
            
            // Create the image view and configure it
            flag = [[UIImageView alloc] initWithImage:[image nf_resizedImageWithSize:innerSize]];
            flag.frame = CGRectMake(0, 0, newSize.width, newSize.height);
            flag.contentMode = UIViewContentModeCenter;
            flag.backgroundColor = [UIColor whiteColor];
            
            // Add the shadow effect
            flag.layer.shadowOffset = CGSizeMake(2, 2);
            flag.layer.shadowColor = [UIColor blackColor].CGColor;
            flag.layer.shadowOpacity = 0.6;
        }
        
        // Save the flag and country ocde
        _portraitFlags[i] = flag;
        _portraitCountryCodes[i] = countryCode;
        
        // Add it to the scrollview
        [_portraitScrollView addSubview:flag];
    }
    
    // Change the landscape flag and apply a border unless we're showing the globe
    NSDictionary *info = countries[index];
    NSString *countryCode = info[@"code"];
    if ([countryCode isEqualToString:@"world"]) {
        // Set the globe image
        _landscapeFlag.image = [UIImage imageNamed:@"globeHoriz"];
        [_landscapeFlag sizeToFit];
        
        // Unset the background color
        _landscapeFlag.backgroundColor = [UIColor clearColor];
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
        
        // Assign the image to the image view and configure it
        _landscapeFlag.image = [image nf_resizedImageWithSize:innerSize];
        _landscapeFlag.frame = CGRectMake(0, 0, newSize.width, newSize.height);
        _landscapeFlag.contentMode = UIViewContentModeCenter;
        _landscapeFlag.backgroundColor = [UIColor whiteColor];
    }
    
    // Change the landscape country name
    _landscapeCountryName.text = info[@"name"];
    
    // Force a layout
    [self setNeedsLayout];
}

- (void)scrollViewTouched:(UIGestureRecognizer *)recognizer {
    // Nothing to do if the scroll view is still animating
    if (_portraitScrollView.layer.animationKeys.count)
        return;
    
    // Nothing to do if the middle flag isn't the one that is
    // currently shown, in case we haven't swapped the flags yet
    if (_portraitScrollView.contentOffset.x != _portraitScrollView.frame.size.width)
        return;
    
    // Check if the left arrow was touched
    if (CGRectContainsPoint(_portraitArrowLeft.bounds, [recognizer locationInView:_portraitArrowLeft]))
        [_portraitScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    // Check if the right arrow was touched
    else if (CGRectContainsPoint(_portraitArrowRight.bounds, [recognizer locationInView:_portraitArrowRight]))
        [_portraitScrollView setContentOffset:CGPointMake(_portraitScrollView .frame.size.width * 2, 0) animated:YES];
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
        
        // Position the flag
        _landscapeFlag.frame = CGRectMake(20, 20, _landscapeFlag.frame.size.width, _landscapeFlag.frame.size.height);
        
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
        
        // Position the arrows
        _portraitArrowLeft.center = CGPointMake(20 + _portraitArrowLeft.frame.size.width / 2, _portraitScrollView.center.y);
        _portraitArrowRight.center = CGPointMake(self.bounds.size.width -  20 - _portraitArrowRight.frame.size.width / 2, _portraitScrollView.center.y);
        
        // Position the flags in the scroll view
        for (int i = 0; i < 3; ++i) {
            UIImageView *flag = _portraitFlags[i];
            flag.center = CGPointMake(self.bounds.size.width * (i + 0.5), _portraitScrollView.frame.size.height / 2);
        }
        
        // Position the web view and its background
        CGRect frame = CGRectMake(20, 0, self.bounds.size.width - 40, 367);
        frame.origin.y = self.bounds.size.height - 20 - frame.size.height;
        _webView.frame = frame;
        _portraitWebViewBackground.frame = frame;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // This is called after the animation triggered
    // by setting the content offset programatically
    [self checkSelectedCountry];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // This is called after the decelerating animation
    // when the user releases the dragged scrollview
    [self checkSelectedCountry];
}

- (void)checkSelectedCountry {
    // Find the selected page, accounting for any rounding errors
    int page = (_portraitScrollView.contentOffset.x + 0.1) / _portraitScrollView.frame.size.width;
    assert(page == 0 || page == 1 || page == 2);
    
    // If it's the middle page, the selection hasn't changed
    if (page == 1)
        return;
    
    // Let others know about this selection
    NSString *selection = _portraitCountryCodes[page];
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : selection}];
}

@end
