//
//  NFConfigurableTapGestureRecognizer.h
//  PopulationClock
//
//  Created by Fernando Lemos on 15/05/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NFConfigurableTapGestureRecognizer : UIGestureRecognizer

@property (nonatomic, assign) NSUInteger numberOfTapsRequired;

@property (nonatomic, assign) NSTimeInterval timeout;

@end
