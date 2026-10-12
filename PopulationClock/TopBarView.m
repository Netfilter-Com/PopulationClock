//
//  TopBarView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 17/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "MainViewController.h"
#import "TopBarView.h"
#import "UIColor+NFAppColors.h"

@implementation TopBarView {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UILabel *_titleLabel;
    IBOutlet __weak UISegmentedControl *_modeSegmentedControl;
    IBOutlet __weak UIImageView *_rotateImageView;
    IBOutlet __weak UILabel *_rotateLabel;

    // The bottom toolbar is hidden in landscape, so these two take its place
    UIButton *_shareButton;
    UIButton *_aboutButton;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Set the label colors for the segmented control
    NSDictionary *attrs = @{NSForegroundColorAttributeName : [UIColor nf_orangeTextColor]};
    [_modeSegmentedControl setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [_modeSegmentedControl setTitleTextAttributes:attrs forState:UIControlStateHighlighted];
    
    // Style the segmented control
    [_modeSegmentedControl setTintColor:[UIColor nf_orangeTextColor]];
    
    // Translations of this hint can be longer than the English one
    _rotateLabel.adjustsFontSizeToFitWidth = YES;
    _rotateLabel.minimumScaleFactor = 0.7;

    
    // Share and About buttons, shown in landscape only
    _shareButton = [self barButtonWithTitle:NSLocalizedString(@"Share", nil) action:@selector(barShareButtonTouched:)];
    _aboutButton = [self barButtonWithTitle:NSLocalizedString(@"About", nil) action:@selector(barAboutButtonTouched:)];
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (UIButton *)barButtonWithTitle:(NSString *)title action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor nf_orangeTextColor] forState:UIControlStateNormal];
    // Fixed size, like the other toolbar buttons: the bar is artwork
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button sizeToFit];
    CGRect frame = button.frame;
    frame.size.height = 44;
    frame.size.width += 16;
    button.frame = frame;
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.hidden = YES;
    [self addSubview:button];
    return button;
}

// The actions live in MainViewController: send them up the responder chain.
// These handlers must not be named like the actions they send, or the
// nil-targeted action would find them first and call itself forever
- (void)barShareButtonTouched:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(ShareApp:) to:nil from:sender forEvent:nil];
}

- (void)barAboutButtonTouched:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(aboutButtonTouched:) to:nil from:sender forEvent:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Ignore this if we're the source of the notification
    if (notification.object == self)
        return;
    
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // If a real country was selected, save that
    BOOL isWorld = [selection isEqualToString:@"world"];
    if (!isWorld) {
        [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryNoWorldKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // Change the value of the segmented control
    _modeSegmentedControl.selectedSegmentIndex = isWorld ? 0 : 1;
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different layout depending on the orientation
    if (self.bounds.size.width > self.bounds.size.height) {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"barraHoriz"];
        
        // Resize the mode segmented control
        [_modeSegmentedControl sizeToFit];
        
        // Position it in the left third of the bar
        CGFloat panelWidth = roundf(self.bounds.size.width / 3.0);
        _modeSegmentedControl.center = CGPointMake(panelWidth / 2.0, self.bounds.size.height / 2);
        
        // The rotate label and image view are visible
        _rotateLabel.alpha = 1;
        _rotateImageView.alpha = 1;
        
        // Share and About go to the left of the rotate hint, right aligned
        CGFloat right = CGRectGetMinX(_rotateImageView.frame) - 8;
        CGFloat midY = self.bounds.size.height / 2;
        for (UIButton *button in @[ _aboutButton, _shareButton ]) {
            CGRect buttonFrame = button.frame;
            buttonFrame.origin.x = right - buttonFrame.size.width;
            buttonFrame.origin.y = midY - buttonFrame.size.height / 2;
            button.frame = buttonFrame;
            button.hidden = NO;
            right = buttonFrame.origin.x;
        }
        
        // Resize the title label
        _titleLabel.font = [UIFont boldSystemFontOfSize:24];
        [_titleLabel sizeToFit];
        
        // It goes centered in the right two-thirds of the bar, unless that
        // would run over the buttons (translated titles are longer): then it
        // takes the space between the segmented control's panel and the
        // buttons, and shrinks if even that is not enough
        CGFloat minX = panelWidth + 8;
        CGFloat maxX = right - 8;
        CGRect titleFrame = _titleLabel.frame;
        if (titleFrame.size.width > maxX - minX) {
            _titleLabel.adjustsFontSizeToFitWidth = YES;
            _titleLabel.minimumScaleFactor = 0.6;
            titleFrame.size.width = maxX - minX;
        }
        CGFloat centerX = panelWidth + (self.bounds.size.width - panelWidth) / 2.0;
        CGFloat halfWidth = titleFrame.size.width / 2.0;
        centerX = MIN(centerX, maxX - halfWidth);
        centerX = MAX(centerX, minX + halfWidth);
        titleFrame.origin.x = centerX - halfWidth;
        titleFrame.origin.y = (self.bounds.size.height - titleFrame.size.height) / 2.0;
        _titleLabel.frame = titleFrame;
    }
    else {
        // Set the background image
        _backgroundImageView.image = [UIImage imageNamed:@"barraVert"];
        
        // Resize the mode segmented control
        CGRect frame = _modeSegmentedControl.frame;
        frame.size.width = roundf(self.bounds.size.width / 2.0);
        _modeSegmentedControl.frame = frame;
        
        // Position it
        _modeSegmentedControl.center = CGPointMake(self.bounds.size.width / 4, self.bounds.size.height / 2);
        
        // Resize the title label
        _titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [_titleLabel sizeToFit];
        
        // Position it
        _titleLabel.center = CGPointMake(self.bounds.size.width * 3 / 4, self.bounds.size.height / 2);
        
        // The rotate label and image view are hidden, and so are the buttons
        // (the bottom toolbar has them in portrait)
        _rotateLabel.alpha = 0;
        _rotateImageView.alpha = 0;
        _shareButton.hidden = YES;
        _aboutButton.hidden = YES;
    }
}

- (IBAction)segmentedControlSelectionChanged:(id)sender {
    // Find the selection
    NSString *selection;
    if (_modeSegmentedControl.selectedSegmentIndex == 0) {
        selection = @"world";
    }
    else {
        // Look at the last country selection, default to Brazil
        selection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryNoWorldKey];
        if (!selection)
            selection = @"br";
    }
    
    // Let others know about this selection
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : selection}];
}

@end
