//
//  MainViewController.h
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "AboutViewController.h"
#import "ModalDialogViewController.h"

@interface MainViewController : ModalDialogViewController <AboutViewControllerDelegate>

// Also sent from the iPad top bar, through the responder chain
- (IBAction)ShareApp:(id)sender;
- (IBAction)aboutButtonTouched:(id)sender;

@end
