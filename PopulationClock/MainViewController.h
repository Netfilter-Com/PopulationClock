//
//  MainViewController.h
//  PopulationClock
//
//  Created by Fernando Lemos on 11/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "AboutViewController.h"
#import "AdManager.h"
#import "ModalDialogViewController.h"

@interface MainViewController : ModalDialogViewController <AboutViewControllerDelegate, AdManagerDelegate, UIScrollViewDelegate>

@end
