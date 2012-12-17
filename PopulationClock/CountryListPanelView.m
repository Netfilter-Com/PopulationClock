//
//  CountryListPanelView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 17/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryListPanelView.h"

@implementation CountryListPanelView {
    IBOutlet __weak UIView *_searchBackground;
    IBOutlet __weak UITableView *_tableView;
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // Position the search background
    CGRect frame = _searchBackground.frame;
    frame.origin = CGPointMake(20, 20);
    frame.size.width = self.bounds.size.width - 40;
    _searchBackground.frame = frame;
    
    // Position the table view
    frame.size.height = self.bounds.size.height - frame.size.height - 40;
    frame.origin.y += _searchBackground.frame.size.height;
    _tableView.frame = frame;
}

@end
