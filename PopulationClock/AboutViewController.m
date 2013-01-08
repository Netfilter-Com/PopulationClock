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
    _textView.text = NSLocalizedString(@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla eget magna tortor, a dictum urna. Quisque et odio quis massa porttitor porta a vitae eros. Maecenas egestas iaculis neque, in elementum justo ornare sed. Aenean rhoncus mauris nec sapien rhoncus vestibulum. Curabitur eget turpis mauris, ut volutpat lacus. Duis vehicula mauris a nisi pellentesque id mattis nibh molestie.\n\nNunc quis tortor orci. Vestibulum porta est eget eros rutrum fringilla. Fusce commodo magna faucibus lectus ultrices scelerisque. Quisque sem dui, scelerisque id rutrum ut, rhoncus vel augue. Duis iaculis consequat erat, vitae bibendum sem tempor vitae. Aliquam fringilla orci sed mauris pretium consectetur. Curabitur pulvinar diam non dui lacinia sit amet sagittis justo fermentum.", @"");
    
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
