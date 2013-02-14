//
//  CountryInfoBackgroundView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CountryInfoBackgroundView.h"

@implementation CountryInfoBackgroundView

- (void)awakeFromNib
{
    // Set the background color
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light"]];
    
    // Set the rounded corners
    self.layer.cornerRadius = 2.0f;
    self.layer.masksToBounds = YES;
}

@end
