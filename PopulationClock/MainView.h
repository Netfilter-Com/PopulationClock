//
//  MainView.h
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

@interface MainView : UIScrollView

@property (nonatomic, weak) UIView *adView;

- (void)adjustMapLegendFrameToBounds:(CGRect *)frame;

@end
