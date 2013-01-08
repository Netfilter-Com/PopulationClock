//
//  ClockPanelView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "ClockPanelView.h"
#import "DataManager.h"

@implementation ClockPanelView {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UILabel *_countryNameLabel;
    IBOutlet __weak UIView *_clock;
}

- (void)awakeFromNib {
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Get the text we'll use in the label
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    NSString *populationText = NSLocalizedString(@"POPULATION: ", @"");
    NSString *countryNameText = [info[@"name"] uppercaseString];
    
    // Create the attributed string and update the label
    if (&NSFontAttributeName == NULL) {
        _countryNameLabel.text = [populationText stringByAppendingString:countryNameText];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:populationText attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:16]
        }];
        NSAttributedString *nameAttr = [[NSAttributedString alloc] initWithString:countryNameText attributes:@{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16]
        }];
        [str appendAttributedString:nameAttr];
         _countryNameLabel.attributedText = str;
    }
    
    // We'll need to layout the subviews again to align the labels
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
        _backgroundImageView.image = [UIImage imageNamed:@"bgClockHoriz"];
    else
        _backgroundImageView.image = [UIImage imageNamed:@"bgClockVert"];
    
    // Determine the total height of the elements we'll center and
    // derive the Y origin of the label from that
    [_countryNameLabel sizeToFit];
    CGFloat height = _countryNameLabel.frame.size.height + 8 + _clock.frame.size.height;
    CGFloat originY = (self.bounds.size.height - height) / 2;
    
    // We can now position the label
    CGRect frame = _countryNameLabel.frame;
    CGFloat maxWidth = self.bounds.size.width - 40;
    if (frame.size.width > maxWidth)
        frame.size.width = maxWidth;
    frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY;
    _countryNameLabel.frame = frame;
    
    // And then the clock
    frame = _clock.frame;
    frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY + height - frame.size.height;
    _clock.frame = frame;
}

@end
