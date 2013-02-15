//
//  CountryInfoViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "CountryInfoViewController_iPhone.h"

@interface CountryInfoViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UIView *leftPanel;
@property (nonatomic, weak) IBOutlet UIView *rightPanel;

@end

@implementation CountryInfoViewController_iPhone

- (void)viewWillLayoutSubviews
{
    CGFloat width = self.view.bounds.size.width / 2;
    CGFloat height = self.view.bounds.size.height;
    self.leftPanel.frame = CGRectMake(0, 0, width, height);
    self.rightPanel.frame = CGRectMake(width, 0, width, height);
}

@end
