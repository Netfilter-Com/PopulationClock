//
//  UIViewController+NFSharing.h
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NFSharing)

- (void)nf_presentShareViewControllerAnimated:(BOOL)animated;

// On iPad the share sheet is a popover and needs something to point at: pass
// the bar button item or view that was touched
- (void)nf_presentShareViewControllerFromSender:(id)sender animated:(BOOL)animated;

@end
