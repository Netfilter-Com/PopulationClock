//
//  AboutViewController.m
//  PopulationClock
//
//  Created by Pedro Paulo Oliveira Jr on 27/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AboutViewController.h"

@implementation AboutViewController {
    IBOutlet __weak UINavigationBar *_navigationBar;
}

- (void)viewDidLoad {
    // Set text here so we don't have to translate the storyboard
    _navigationBar.topItem.title = NSLocalizedString(@"About Population Clock", @"");
    
    // Set the navigation bar theme
    NSDictionary *attrs = @{UITextAttributeTextColor : [UIColor colorWithRed:0xfa/255.0 green:0xc4/255.0 blue:0x2a/255.0 alpha:1]};
    [[UINavigationBar appearance] setTitleTextAttributes:attrs];
    
    // Set the background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light"]];
    
    // Add a gradient to the background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.5].CGColor,
        (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor
    ];
    [self.view.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)doneButtonTouched:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

@end
