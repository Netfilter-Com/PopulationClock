//
//  CountryInfoWebView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 20/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryInfoWebView.h"

@implementation CountryInfoWebView {
    BOOL _didLayout;
    UIInterfaceOrientation _interfaceOrientationForLayout;
}

- (void)awakeFromNib {
    // Disable bouncing
    self.scrollView.bounces = NO;
    
    // Remove some random shadows (where does this come from?)
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]])
            subview.hidden = YES;
    }
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // Nothing to do if the interface orientation didn't change
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (_didLayout && UIInterfaceOrientationIsPortrait(orientation) == UIInterfaceOrientationIsPortrait(_interfaceOrientationForLayout))
        return;
    
    // Load the right template depending on the orientation
    NSString *templateName = UIInterfaceOrientationIsPortrait(orientation) ? @"info_template_portrait" : @"info_template_landscape";
    NSString *path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"html"];
    NSString *template = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    // TODO: Perform the template substitutions
    
    // Load the HTML
    NSURL *baseURL = [NSURL fileURLWithPath:[path stringByDeletingLastPathComponent] isDirectory:YES];
    [self loadHTMLString:template baseURL:baseURL];
    
    // Save the new orientation
    _interfaceOrientationForLayout = orientation;
    _didLayout = YES;
}

@end
