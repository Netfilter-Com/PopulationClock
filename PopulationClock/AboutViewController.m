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

// The text no longer fits the storyboard's 360x440 dialog on iPad (translations
// are longer), so the dialog is made bigger and the content is stretched
static const CGFloat kPadExtraWidth = 100;
static const CGFloat kPadExtraHeight = 215;

@implementation AboutViewController {
    IBOutlet __weak UINavigationBar *_navigationBar;
    IBOutlet __weak UIImageView *_textBackground;
    IBOutlet __weak UITextView *_textView;
}

- (void)loadView {
    [super loadView];
    
    // For whatever reason, [UIViewController loadView] resets the
    // view size, overriding the free form in the storyboard
    if (self.isViewLoaded) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.view.bounds = CGRectMake(0, 0, 360 + kPadExtraWidth, 440 + kPadExtraHeight);
        } else {
            // The iPhone app is landscape-only. UIScreen bounds follow the
            // interface orientation, so take the long side as the width
            // instead of assuming a portrait-sized screen
            CGSize winSize = [UIScreen mainScreen].bounds.size;
            CGFloat longSide = MAX(winSize.width, winSize.height);
            CGFloat shortSide = MIN(winSize.width, winSize.height);
            self.view.bounds = CGRectMake(0, 0, longSide - 60, shortSide - 32);
        }
    }
}

- (void)viewDidLoad {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Lay the content out for the bigger dialog. Absolute frames on
        // purpose: the autoresizing masks may already have resized the
        // subviews when the bounds were changed in loadView
        CGFloat dw = kPadExtraWidth;
        CGFloat dh = kPadExtraHeight;
        _navigationBar.frame = CGRectMake(0, 0, 360 + dw, 44);
        _textBackground.frame = CGRectMake(35, 79, 290 + dw, 260 + dh);
        _textView.frame = CGRectMake(45, 86, 270 + dw, 246 + dh);
        
        // The two logo buttons, left (NetFilter) then right (Maquinário)
        NSMutableArray *buttons = [NSMutableArray array];
        for (UIView *subview in self.view.subviews) {
            if ([subview isKindOfClass:[UIButton class]]) {
                [buttons addObject:subview];
            }
        }
        if (buttons.count == 2) {
            ((UIView *)buttons[0]).frame = CGRectMake(35, 366 + dh, 114, 39);
            ((UIView *)buttons[1]).frame = CGRectMake(196 + dw, 357 + dh, 129, 48);
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // There is free space between the text box and the logos in
        // landscape, and the last paragraph was hidden below the fold
        CGRect frame = _textBackground.frame;
        frame.size.height += 85;
        _textBackground.frame = frame;
        frame = _textView.frame;
        frame.size.height += 85;
        _textView.frame = frame;
    }
    
    // Size to fit the navigation bar to correct
    // it for the landscape orientation
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // The -1 is another hack to avoid fixing the artwork...
        [_navigationBar sizeToFit];
        CGRect frame = _navigationBar.frame;
        frame.origin = CGPointMake(0, -1);
        _navigationBar.frame = frame;
    }
    
    // Set text here so we don't have to translate the storyboard
    _navigationBar.topItem.title = NSLocalizedString(@"About Population Clock", @"");
    _textView.text = NSLocalizedString(@"Real-time events portrayed in this app represent the outcome of a computer simulation based on projected population count and growth, birth and death rates. The statistics used in the simulation are from 2025 and were retrieved from The World Bank. Statistics for American Samoa, Antarctica (an estimate of the people wintering at research stations), Antigua and Barbuda, Dominica, Faroe Islands, Isle of Man, Holy See, Kiribati, Marshall Islands, Monaco, Northern Mariana Islands, Palau, Saint Kitts and Nevis, South Sudan, Taiwan, Turks and Caicos Islands and Tuvalu were partially or entirely obtained from Wikipedia. The figures for Anguilla, British Virgin Islands, Cook Islands, Falkland Islands, Gibraltar, Guernsey, Jersey, Montserrat, Nauru, Niue, Pitcairn, Saint Barthélemy, Saint Helena, Saint Pierre and Miquelon, Taiwan, the Holy See and Wallis and Futuna are rounded estimates. Descriptions for each of the countries presented in this app were retrieved from CIA's The World Factbook, which the CIA discontinued in 2026 (the text is from its last edition). The Antarctica flag is the unofficial one in common use, not an official flag.\n\nThis app is NOT endorsed by any of the aforementioned institutions.", @"");
    
    // Follow the user's text size; the box scrolls, so it can grow a lot
    _textView.font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody]
                      scaledFontForFont:[UIFont systemFontOfSize:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 13 : 14)]
                      maximumPointSize:40];
    _textView.adjustsFontForContentSizeCategory = YES;
    
    // The logo buttons have no title
    NSMutableArray *logoButtons = [NSMutableArray array];
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [logoButtons addObject:subview];
        }
    }
    if (logoButtons.count == 2) {
        ((UIView *)logoButtons[0]).accessibilityLabel = NSLocalizedString(@"NetFilter website", @"");
        ((UIView *)logoButtons[1]).accessibilityLabel = NSLocalizedString(@"Maquinário website", @"");
        for (UIView *button in logoButtons) {
            button.accessibilityTraits = UIAccessibilityTraitLink;
        }
    }
    
    // The app is forced to dark mode but the box behind the text is light,
    // so the default (white) text color would be unreadable
    _textView.textColor = [UIColor colorWithRed:0x40/255.0 green:0x40/255.0 blue:0x40/255.0 alpha:1];
    
    // Set the navigation bar theme
    NSString *navBarBackgroundName;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navBarBackgroundName = @"barraAbout";
    } else {
        navBarBackgroundName = @"barraTopo";
    }
    [_navigationBar setBackgroundImage:[UIImage imageNamed:navBarBackgroundName] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *attrs = @{
        NSForegroundColorAttributeName : [UIColor nf_orangeTextColor],
        NSFontAttributeName : [UIFont boldSystemFontOfSize:17]
    };
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
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (IBAction)maquinarioLogoTouched:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://estudiomaquinario.com.br/"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

@end
