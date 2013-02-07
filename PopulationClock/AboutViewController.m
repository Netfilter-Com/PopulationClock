//
//  AboutViewController.m
//  PopulationClock
//
//  Created by Pedro Paulo Oliveira Jr on 27/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AboutViewController.h"
#import "UIColor+NFAppColors.h"

@implementation AboutViewController {
    IBOutlet __weak UINavigationBar *_navigationBar;
    IBOutlet __weak UIImageView *_textBackground;
    IBOutlet __weak UITextView *_textView;
}

- (void)loadView {
    [super loadView];
    
    // For whatever reason, [UIViewController loadView] resets the
    // view size, overriding the free form in the storyboard
    if (self.isViewLoaded)
        self.view.bounds = CGRectMake(0, 0, 360, 440);
}

- (void)viewDidLoad {
    // Set text here so we don't have to translate the storyboard
    _navigationBar.topItem.title = NSLocalizedString(@"About Population Clock", @"");
    _textView.text = NSLocalizedString(@"Real-time events portrayed in this app represent the outcome of a computer simulation based on projected population count and growth, birth and death rates. The statistics used in the simulation cover the years 2007 to 2011 and were retrieved from The World Bank. Statistics for American Samoa, Antigua and Barbuda, Dominica, Faroe Islands, Isle of Man, Holy See, Kiribati, Marshall Islands, Monaco, Northern Mariana Islands, Palau, Saint Kitts and Nevis, South Sudan, Taiwan, Turks and Caicos Islands and Tuvalu were partially or entirely obtained from Wikipedia. Descriptions for each of the countries presented in this app were retrieved from CIA's The World Factbook.\n\nThis app is NOT endorsed by any of the aforementioned institutions.", @"");
    
    // Set the navigation bar theme
    [_navigationBar setBackgroundImage:[UIImage imageNamed:@"barraAbout"] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *attrs = @{UITextAttributeTextColor : [UIColor nf_orangeTextColor]};
    [_navigationBar setTitleTextAttributes:attrs];
    
    // Set the background color
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light"]];
    
    // Add a gradient to the background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.2].CGColor,
        (id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2].CGColor
    ];
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    // Load the image for the text background
    UIImage *textBackgroundImage = [[UIImage imageNamed:@"aboutBox"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    _textBackground.image = textBackgroundImage;
}

- (IBAction)doneButtonTouched:(id)sender {
    [_delegate aboutViewControllerDone:self];
}

- (IBAction)netfilterLogoTouched:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://www.netfilter.com/"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)maquinarioLogoTouched:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://estudiomaquinario.com.br/"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
