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

- (void)layoutSubviews
{
    // Get rid of any existing layer
    for (CALayer *layer in [self.layer sublayers]) {
        [layer removeFromSuperlayer];
    }
    
    // Add the shadow layer
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOpacity = 0.7f;
    shadowLayer.shadowRadius = 2.0f;
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shouldRasterize = YES;
    shadowLayer.rasterizationScale = [UIScreen mainScreen].scale;
    [self.layer addSublayer:shadowLayer];
    
    // Set the shadow path
    CGFloat r = shadowLayer.shadowRadius;
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    CGPoint lines[] = {
        CGPointMake(-r, -r),
        CGPointMake(self.bounds.size.width + r, -r),
        CGPointMake(self.bounds.size.width + r, r),
        CGPointMake(r, r),
        CGPointMake(r, self.bounds.size.height + r),
        CGPointMake(-r, self.bounds.size.height + r),
        CGPointMake(-r, -r)
    };
    CGPathAddLines(shadowPath, NULL, lines, sizeof(lines) / sizeof(CGPoint));
    shadowLayer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
}

@end
