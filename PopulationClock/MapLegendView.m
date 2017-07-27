//
//  MapLegendView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "MapLegendView.h"
#import "UIColor+NFAppColors.h"

@implementation MapLegendView {
    IBOutlet __weak UILabel *_titleLabel;
    IBOutlet __weak UILabel *_birthsLabel;
    IBOutlet __weak UILabel *_deathsLabel;
    IBOutlet __weak UIImageView *_deathsIcon;
    UIView *_normalView, *_collapsedView;
    CGSize _normalSize, _collapsedSize;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Add rounded corners
    self.layer.cornerRadius = 8;
    self.layer.borderColor = [UIColor colorWithRed:0x65/255.0 green:0x65/255.0 blue:0x62/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 1;
    self.layer.masksToBounds = YES;
    
    // Save the size as the normal frame
    _normalSize = self.frame.size;
    
    // Create the normal view
    _normalView = [[UIView alloc] initWithFrame:self.bounds];
    
    // Create the gradient band
    CGRect frame = CGRectMake(10, 35, self.bounds.size.width - 20, 12);
    UIView *gradientView = [[UIView alloc] initWithFrame:frame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = @[
        (id)[UIColor nf_minGrowthColor].CGColor,
        (id)[UIColor nf_maxGrowthColor].CGColor
    ];
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    gradient.cornerRadius = 3;
    gradient.masksToBounds = YES;
    [gradientView.layer insertSublayer:gradient atIndex:0];
    [_normalView addSubview:gradientView];
    
    // Reparent all the other views (this is ugly)
    NSArray *subviews = [self.subviews copy];
    for (UIView *subview in subviews) {
        [subview removeFromSuperview];
        [_normalView addSubview:subview];
    }
    [self addSubview:_normalView];
    
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
    
    // Create the collapsed view
    _collapsedView = [UIView new];
    _collapsedView.alpha = 0;
    [self addSubview:_collapsedView];
    
    // Add the title label
    UILabel *collapsedLabel = [UILabel new];
    collapsedLabel.text = NSLocalizedString(@"Legend", @"");
    collapsedLabel.font = _titleLabel.font;
    collapsedLabel.backgroundColor = [UIColor clearColor];
    collapsedLabel.textColor = _titleLabel.textColor;
    collapsedLabel.shadowColor = _titleLabel.shadowColor;
    collapsedLabel.shadowOffset = _titleLabel.shadowOffset;
    [collapsedLabel sizeToFit];
    [_collapsedView addSubview:collapsedLabel];
    
    // Set the collapsed size and center the title
    _collapsedSize = CGSizeMake(collapsedLabel.frame.size.width + 24, collapsedLabel.frame.size.height + 24);
    collapsedLabel.center = CGPointMake(_collapsedSize.width / 2, _collapsedSize.height / 2);
}

- (void)setCollapsed:(BOOL)collapsed
{
    if (collapsed == _collapsed) {
        return;
    }
    _collapsed = collapsed;
 
    CGRect oldFrame = self.frame;
    CGRect frame = oldFrame;
    if (collapsed) {
        frame.size = _collapsedSize;
        _normalView.alpha = 0;
        _collapsedView.alpha = 1;
    } else {
        frame.size = _normalSize;
        _normalView.alpha = 1;
        _collapsedView.alpha = 0;
    }
    frame.origin.y += oldFrame.size.height - frame.size.height;
    self.frame = frame;
}

- (void)setCollapsed:(BOOL)collapsed animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.collapsed = collapsed;
        }];
    } else {
        self.collapsed = collapsed;
    }
}

@end
