//
//  CountryListViewController.h
//  PopulationClock
//
//  Created by Fernando Lemos on 17/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "AboutViewController.h"
#import "AdManager.h"
#import "NFCarouselViewController.h"

@interface CountryListViewController : UIViewController <AboutViewControllerDelegate,
														 AdManagerDelegate,
														 GADBannerViewDelegate,
														 NFCarouselDataSource,
														 UITableViewDataSource,
														 UITableViewDelegate,
														 UITextFieldDelegate>
@end
