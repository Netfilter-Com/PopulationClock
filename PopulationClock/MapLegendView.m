//
//  MapLegendView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MapLegendView.h"

@implementation MapLegendView {
    IBOutlet __weak UILabel *_titleLabel;
    IBOutlet __weak UILabel *_birthsLabel;
    IBOutlet __weak UILabel *_deathsLabel;
    IBOutlet __weak UIImageView *_deathsIcon;
}

- (void)awakeFromNib {
    // Add rounded corners
    self.layer.cornerRadius = 12;
    self.layer.borderColor = [UIColor colorWithRed:193/255.0 green:193/255.0 blue:193/255.0 alpha:0.5].CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    
    // Create the gradient band
    CGRect frame = CGRectMake(10, 35, self.bounds.size.width - 20, 12);
    UIView *gradientView = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = @[
        (id)[UIColor colorWithRed:0xff/255.0 green:0x32/255.0 blue:0 alpha:1].CGColor,
        (id)[UIColor colorWithRed:0xff/255.0 green:0xe1/255.0 blue:0 alpha:1].CGColor
    ];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    gradient.cornerRadius = 3;
    gradient.masksToBounds = YES;
    [gradientView.layer insertSublayer:gradient atIndex:0];
    [self addSubview:gradientView];
    
    // Set up the labels' text
    _titleLabel.text = NSLocalizedString(@"Population growth", @"");
    _birthsLabel.text = NSLocalizedString(@"Births", @"");
    _deathsLabel.text = NSLocalizedString(@"Deaths", @"");
    
    // Realign the deaths label
    [_deathsLabel sizeToFit];
    frame = _deathsLabel.frame;
    frame.origin.x = self.bounds.size.width - frame.size.width - 12;
    _deathsLabel.frame = frame;
    
    // Realign the deaths icon
    frame = _deathsIcon.frame;
    frame.origin.x = _deathsLabel.frame.origin.x - frame.size.width - 2;
    _deathsIcon.frame = frame;
}

@end
