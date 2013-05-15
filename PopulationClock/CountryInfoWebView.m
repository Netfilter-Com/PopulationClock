//
//  CountryInfoWebView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 20/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CountryInfoWebView.h"
#import "DataManager.h"
#import "StatsBuilder.h"

@implementation CountryInfoWebView {
    BOOL _didLayout;
    UIInterfaceOrientation _interfaceOrientationForLayout;
    NSString *_selectedCountry;
    CALayer *_shadowLayer;
}

+ (Class)layerClass
{
    return [CAGradientLayer class];
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(countrySelectionChanged:)
                                                 name:CountrySelectionNotification
                                               object:nil];
    
    // Set the rounded corners
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
    
    // Configure the gradient
    CAGradientLayer *gradient = (CAGradientLayer *)self.layer;
    UIColor *finalColor;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        gradient.startPoint = CGPointMake(0, 0.75);
        finalColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    } else {
        gradient.startPoint = CGPointMake(0, 0.5);
        finalColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    gradient.endPoint = CGPointMake(0, 1);
    gradient.colors = @[
        (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor,
        (id)finalColor.CGColor
    ];
    
    // Rasterize this layer
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    // Add the shadow layer
    _shadowLayer = [CALayer layer];
    _shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    _shadowLayer.shadowOpacity = 0.7f;
    _shadowLayer.shadowRadius = 2.0f;
    _shadowLayer.shadowOffset = CGSizeZero;
    _shadowLayer.shouldRasterize = YES;
    _shadowLayer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:_shadowLayer];
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
    // Set the shadow path
    CGFloat r = _shadowLayer.shadowRadius;
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    CGPoint lines[] = {
        CGPointMake(-r, -r),
        CGPointMake(self.bounds.size.width + r, -r),
        CGPointMake(self.bounds.size.width + r, r),
        CGPointMake(r, r),
        CGPointMake(r, self.bounds.size.height + r),
        CGPointMake(-r, self.bounds.size.height + r),
        CGPointMake(-r, -r)
    };
    CGPathAddLines(shadowPath, NULL, lines, sizeof(lines) / sizeof(CGPoint));
    _shadowLayer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
    
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
            @"NAME" : info[@"name"],
            @"DESCRIPTION" : description,
            @"READ_MORE_LINK" : NSLocalizedString(@"[Read more]", @""),
            @"STATS" : [[StatsBuilder new] statsStringForCountryCode:_selectedCountry]
        };
    }
    else {
        substitutions = @{ @"%%DESCRIPTION%%" : description };
    }

    char * const templateC = strdup([template UTF8String]);
    char *templatePtr = templateC;

    NSMutableString *result = [[NSMutableString alloc] initWithCapacity:template.length * 2];

    // Perform the template substitutions in C because string replacement
    // with NSStrings is way too slow (probably because of Unicode support)
    for (;;) {
        // Find the first delimiter
        char *begin = strstr(templatePtr, "%%");

        // If there's no first delimiter, just append the remainder
        if (!begin) {
            [result appendString:[NSString stringWithCString:templatePtr encoding:NSUTF8StringEncoding]];
            break;
        }

        // Find the second delimiter
        char *end = strstr(begin + 2, "%%");
        NSAssert(end, @"Malformed template (missing second delimiter)");

        // Zero-terminate the first char so from template to begin - 1
        // so we have a zero-terminated C string
        *begin = '\0';

        // Append this to the result string
        NSString *before = [NSString stringWithCString:templatePtr encoding:NSUTF8StringEncoding];
        [result appendString:before];

        // Zero-terminate the key and retrieve it
        *end = '\0';
        NSString *key = [NSString stringWithCString:begin + 2 encoding:NSUTF8StringEncoding];
        NSString *replacement = substitutions[key];
        NSAssert(replacement, @"Replacement not found for key: %@", key);
        [result appendString:replacement];

        // Advance the pointer to the template
        templatePtr += end - templatePtr + 2;
    }

    free(templateC);
    template = result;
    
    // Load the HTML
    NSURL *baseURL = [NSURL fileURLWithPath:[path stringByDeletingLastPathComponent] isDirectory:YES];
    [self loadHTMLString:template baseURL:baseURL];
    
    // Save the new orientation
    _interfaceOrientationForLayout = orientation;
    _didLayout = YES;
}

@end
