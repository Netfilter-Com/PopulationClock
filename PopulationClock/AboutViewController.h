//
//  AboutViewController.h
//  PopulationClock
//
//  Created by Pedro Paulo Oliveira Jr on 27/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

@protocol AboutViewControllerDelegate;

@interface AboutViewController : UIViewController

@property (nonatomic, weak) id <AboutViewControllerDelegate> delegate;

@end

@protocol AboutViewControllerDelegate

- (void)aboutViewControllerDone:(AboutViewController *)controller;

@end
