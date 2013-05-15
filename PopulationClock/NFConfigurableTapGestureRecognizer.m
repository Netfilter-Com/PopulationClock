//
//  NFConfigurableTapGestureRecognizer.m
//  PopulationClock
//
//  Created by Fernando Lemos on 15/05/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>

#import "NFConfigurableTapGestureRecognizer.h"

#define TOUCH_AREA 40

@implementation NFConfigurableTapGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    self = [super initWithTarget:target action:action];
    if (self) {
        self.numberOfTapsRequired = 1;
        self.timeout = 0.350;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([event touchesForGestureRecognizer:self].count > 1) {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSUInteger tapCount = [[touches anyObject] tapCount];
    if (tapCount == self.numberOfTapsRequired) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        self.state = UIGestureRecognizerStateRecognized;
    } else if (tapCount == 1) {
        [self performSelector:@selector(failDetection) withObject:nil afterDelay:self.timeout];
    }
}

- (void)failDetection
{
    self.state = UIGestureRecognizerStateFailed;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
   if ([preventedGestureRecognizer isKindOfClass:[NFConfigurableTapGestureRecognizer class]]) {
        return ((NFConfigurableTapGestureRecognizer *)preventedGestureRecognizer).numberOfTapsRequired <= self.numberOfTapsRequired;
    } else if ([preventedGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return ((UITapGestureRecognizer *)preventedGestureRecognizer).numberOfTapsRequired <= self.numberOfTapsRequired;
    } else {
        return YES;
    }
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

@end
