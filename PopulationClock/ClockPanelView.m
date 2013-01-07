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
    IBOutlet __weak UILabel *_titleLabel;
    IBOutlet __weak UILabel *_countryNameLabel;
    IBOutlet __weak UIView *_clock;
}

- (void)awakeFromNib {
    // Set the text of the title label
    _titleLabel.text = NSLocalizedString(@"POPULATION:", @"");
    
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
    
    // Update the country name label
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    _countryNameLabel.text = [info[@"name"] uppercaseString];
    
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
    
    // The labels use different sizes depending on the orientation
    CGFloat fontSize = UIInterfaceOrientationIsLandscape(orientation) ? 11 : 13;
    _titleLabel.font = [UIFont systemFontOfSize:fontSize];
    _countryNameLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    [_titleLabel sizeToFit];
    [_countryNameLabel sizeToFit];
    
    // Determine the total height of the elements we'll center and
    // derive the Y origin of the labels from that
    CGFloat height = MAX(_titleLabel.frame.size.height, _countryNameLabel.frame.size.height) + 8 + _clock.frame.size.height;
    CGFloat originY = (self.bounds.size.height - height) / 2;
    
    // Determine the total width of the labels and derive
    // the X origin of the first label from that
    CGFloat labelsWidth = _titleLabel.frame.size.width + 4 + _countryNameLabel.frame.size.width;
    CGFloat originX = (self.bounds.size.width - labelsWidth) / 2;
    
    // We can now position the first label
    CGRect frame = _titleLabel.frame;
    frame.origin.x = originX;
    frame.origin.y = originY;
    _titleLabel.frame = frame;
    
    // And the second label
    frame = _countryNameLabel.frame;
    frame.origin.x = originX + _titleLabel.frame.size.width + 4;
    frame.origin.y = originY;
    _countryNameLabel.frame = frame;
    
    // And finally the clock
    frame = _clock.frame;
    frame.origin.x = (self.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY + height - frame.size.height;
    _clock.frame = frame;
}

@end
