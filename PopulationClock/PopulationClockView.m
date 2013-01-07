//
//  PopulationClockView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "PopulationClockView.h"
#import "SBTickerView.h"

#define FONT_SIZE 24

@implementation PopulationClockView {
    long long _currentPopulation;
    UIImage *_baseImage;
    SBTickerView *_tickerViews[4];
}

- (void)awakeFromNib {
    // Load the base image
    _baseImage = [UIImage imageNamed:@"flap_full"];
    
    // Create and position the ticker views
    CGRect frame = CGRectMake(7, 7, 0, 0);
    frame.size = _baseImage.size;
    UIImage *zeroImage = [self imageForNumber:0];
    for (int i = 3; i >= 0; --i) {
        _tickerViews[i] = [[SBTickerView alloc] initWithFrame:frame];
        _tickerViews[i].frontView = [[UIImageView alloc] initWithImage:zeroImage];
        [self addSubview:_tickerViews[i]];
        frame.origin.x += frame.size.width - 2;
    }
}

- (UIImage *)imageForNumber:(int)number {
    // Create the image context
    UIGraphicsBeginImageContextWithOptions(_baseImage.size, NO, _baseImage.scale);
    
    // Draw the image
    CGRect rect = CGRectMake(0, 0, _baseImage.size.width, _baseImage.size.height);
    [_baseImage drawInRect:rect];
    
    // Get a vertically centered rect for the text drawing
    rect.origin.y = (rect.size.height - FONT_SIZE) / 2 - 2;
    rect = CGRectIntegral(rect);
    rect.size.height = FONT_SIZE;
    
    // Draw the text
    NSString *text = [NSString stringWithFormat:@"%03d", number];
    UIFont *font = [UIFont boldSystemFontOfSize:FONT_SIZE];
    [[UIColor whiteColor] set];
    [text drawInRect:rect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    
    // TODO: Draw the line in the middle
    
    // Get and return the new image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)setPopulation:(long long)population animated:(BOOL)animated {
    // Nothing to do if the population didn't change
    if (population == _currentPopulation)
        return;
    
    // Save the old population and replace it
    long long oldPopulation = _currentPopulation;
    _currentPopulation = population;
    
    // Check which of the ticker views should be updated
    for (int i = 0; i < 4; ++i) {
        // Get the new number for this slot
        int number = population % 1000;
        population /= 1000;
        
        // Get the old number
        int oldNumber = oldPopulation % 1000;
        oldPopulation /= 1000;
        
        // Nothing to do if it shouldn't be updated
        if (number == oldNumber)
            continue;
        
        // Get a new back image and tick
        _tickerViews[i].backView = [[UIImageView alloc] initWithImage:[self imageForNumber:number]];
        [_tickerViews[i] tick:SBTickerViewTickDirectionDown animated:animated completion:nil];
    }
}

@end
