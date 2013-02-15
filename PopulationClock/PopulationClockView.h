//
//  PopulationClockView.h
//  PopulationClock
//
//  Created by Fernando Lemos on 07/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

@interface PopulationClockView : UIImageView

+ (instancetype)clock;

- (void)setPopulation:(long long)population animated:(BOOL)animated;

@end
