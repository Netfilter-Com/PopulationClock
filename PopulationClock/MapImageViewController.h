//
//  MapImageViewController.h
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MapImageView.h"

@interface MapImageViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet MapImageView *mapImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@end
