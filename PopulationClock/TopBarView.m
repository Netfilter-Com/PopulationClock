//
//  TopBarView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 17/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "TopBarView.h"

@implementation TopBarView {
    IBOutlet __weak UILabel *_titleLabel;
    IBOutlet __weak UISegmentedControl *_modeSegmentedControl;
    IBOutlet __weak UIImageView *_rotateImageView;
    IBOutlet __weak UILabel *_rotateLabel;
}

- (void)awakeFromNib {
    // Set the label colors in the segmented control
    NSDictionary *attrs = @{UITextAttributeTextColor : [UIColor colorWithRed:0xfa/255.0 green:0xc4/255.0 blue:0x2a/255.0 alpha:1]};
    [_modeSegmentedControl setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [_modeSegmentedControl setTitleTextAttributes:attrs forState:UIControlStateHighlighted];
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different layout depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        // Resize the mode segmented control
        [_modeSegmentedControl sizeToFit];
        
        // Position it
        _modeSegmentedControl.center = CGPointMake(160, self.bounds.size.height / 2);
        
        // Resize the title label
        _titleLabel.font = [UIFont boldSystemFontOfSize:26];
        [_titleLabel sizeToFit];
        
        // Position it
        _titleLabel.center = CGPointMake(320 + (self.bounds.size.width - 320) / 2, self.bounds.size.height / 2);
        
        // The rotate label and image view are visible
        _rotateLabel.alpha = 1;
        _rotateImageView.alpha = 1;
    }
    else {
        // Resize the mode segmented control
        CGRect frame = _modeSegmentedControl.frame;
        frame.size.width = 320;
        _modeSegmentedControl.frame = frame;
        
        // Position it
        _modeSegmentedControl.center = CGPointMake(self.bounds.size.width / 4, self.bounds.size.height / 2);
        
        // Resize the title label
        _titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [_titleLabel sizeToFit];
        
        // Position it
        _titleLabel.center = CGPointMake(self.bounds.size.width * 3 / 4, self.bounds.size.height / 2);
        
        // The rotate label and image view are hidden
        _rotateLabel.alpha = 0;
        _rotateImageView.alpha = 0;
    }
}

@end
