//
//  ClockViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "ClockViewController.h"
#import "DataManager.h"

@implementation ClockViewController {
    IBOutlet __weak PopulationClockView *_clock;
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UILabel *_countryNameLabel;
    NSString *_selectedCountry;
    NSString *_lastSelection;
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    // The clock view announces the country and the population by itself
    _countryNameLabel.isAccessibilityElement = NO;
    
    // Redo the label with the new size when the user changes the text size
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryChanged:)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(countrySelectionChanged:)
                                                 name:CountrySelectionNotification
                                               object:nil];
}

- (void)contentSizeCategoryChanged:(NSNotification *)notification {
    if (_lastSelection) {
        [self updateLabelForSelection:_lastSelection];
    }
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    [self updateLabelForSelection:notification.userInfo[SelectedCountryKey]];
}

- (void)updateLabelForSelection:(NSString *)selection {
    _lastSelection = selection;
    
    // Get the text we'll use in the label
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    NSString *populationText = NSLocalizedString(@"POPULATION: ", @"");
    NSString *countryNameText = [info[@"name"] uppercaseString];
    
    // Create the attributed string and update the label; the sizes follow
    // the user's text size up to a limit that keeps the clock layout intact
    UIFontMetrics *metrics = [UIFontMetrics metricsForTextStyle:UIFontTextStyleBody];
    if (NSFontAttributeName == nil) {
        _countryNameLabel.text = [populationText stringByAppendingString:countryNameText];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:populationText attributes:@{
            NSFontAttributeName : [metrics scaledFontForFont:[UIFont systemFontOfSize:16] maximumPointSize:24]
        }];
        NSAttributedString *nameAttr = [[NSAttributedString alloc] initWithString:countryNameText attributes:@{
            NSFontAttributeName : [metrics scaledFontForFont:[UIFont boldSystemFontOfSize:16] maximumPointSize:24]
        }];
        [str appendAttributedString:nameAttr];
         _countryNameLabel.attributedText = str;
    }
    
    // We'll need to layout the subviews again to align the labels
    [self.view setNeedsLayout];
}

- (void)viewWillLayoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.view.bounds.size.width == 0 || self.view.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    if (self.view.bounds.size.width > self.view.bounds.size.height)
        _backgroundImageView.image = [UIImage imageNamed:@"bgClockHoriz"];
    else
        _backgroundImageView.image = [UIImage imageNamed:@"bgClockVert"];
    
    // Determine the total height of the elements we'll center and
    // derive the Y origin of the label from that
    [_countryNameLabel sizeToFit];
    CGFloat height = _countryNameLabel.frame.size.height + 8 + _clock.frame.size.height;
    CGFloat originY = (self.view.bounds.size.height - height) / 2;
    
    // We can now position the label
    CGRect frame = _countryNameLabel.frame;
    CGFloat maxWidth = self.view.bounds.size.width - 40;
    if (frame.size.width > maxWidth)
        frame.size.width = maxWidth;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY;
    _countryNameLabel.frame = frame;
    
    // And then the clock
    frame = _clock.frame;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY + height - frame.size.height;
    _clock.frame = frame;
}

@end
