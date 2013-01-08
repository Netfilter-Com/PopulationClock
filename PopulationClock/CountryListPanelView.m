//
//  CountryListPanelView.m
//  PopulationClock
//
//  Created by Fernando Lemos on 17/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "CountryListPanelView.h"
#import "DataManager.h"

@implementation CountryListPanelView {
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UIView *_containerView;
    IBOutlet __weak UIView *_searchBackground;
    IBOutlet __weak UITextField *_searchTextField;
    IBOutlet __weak UITableView *_tableView;
    NSMutableArray *_countries;
    NSMutableArray *_searchResult;
}

- (void)awakeFromNib {
    // Load the list of countries by removing the entry
    // for the entire world
    _countries = [[DataManager sharedDataManager].orderedCountryData mutableCopy];
    NSUInteger worldIndex = NSNotFound;
    for (int i = 0; i < _countries.count; ++i) {
        NSDictionary *info = _countries[i];
        if ([info[@"code"] isEqualToString:@"world"]) {
            worldIndex = i;
            break;
        }
    }
    assert(worldIndex != NSNotFound);
    [_countries removeObjectAtIndex:worldIndex];
    
    // Set up the container view rounded corners
    _containerView.layer.cornerRadius = 2;
    _containerView.layer.masksToBounds = YES;
    
    // Set the table view background
    _tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light"]];
    
    // Style the search background
    _searchBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"debut_light"]];
    UIView *mask = [[UIView alloc] initWithFrame:_searchBackground.bounds];
    mask.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    mask.backgroundColor = [UIColor colorWithRed:0xa3/255.0 green:0xa3/255.0 blue:0xa3/255.0 alpha:1];
    mask.alpha = 0.5;
    [_searchBackground insertSubview:mask atIndex:0];
    
    // Set up to receive text change notifications about changes to the search text field
    [_searchTextField addTarget:self action:@selector(searchTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    // Observe changes to the country selection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Ignore this if we're the source of the notification
    if (notification.object == self)
        return;
    
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Deselect if the world is selected
    if ([selection isEqualToString:@"world"]) {
        NSIndexPath *indexPath = _tableView.indexPathForSelectedRow;
        if (indexPath)
            [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    // Otherwise select and scroll to the country
    else {
        NSUInteger index = NSNotFound;
        for (int i = 0; i < _countries.count; ++i) {
            NSDictionary *info = _countries[i];
            if ([info[@"code"] isEqualToString:selection]) {
                index = i;
                break;
            }
        }
        assert(index != NSNotFound);
        [_tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)layoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.bounds.size.width == 0 || self.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
        _backgroundImageView.image = [UIImage imageNamed:@"bgListaHoriz"];
    else
        _backgroundImageView.image = [UIImage imageNamed:@"bgListaVert"];
    
    // Position the container view and the table view inside it (the
    // autoresizing hints for the search background are good enough)
    _containerView.frame = CGRectInset(self.bounds, 20, 20);
    CGRect frame = _containerView.bounds;
    frame.origin.y = _searchBackground.frame.size.height;
    frame.size.height -= frame.origin.y;
    _tableView.frame = frame;
    
    // If we had a selection, center on it
    NSIndexPath *selection = [_tableView indexPathForSelectedRow];
    if (selection)
        [_tableView scrollToRowAtIndexPath:selection atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResult ? _searchResult.count : _countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get a new table view cell
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"country"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"country"];
        
        // Set the text color and font size
        cell.textLabel.textColor = [UIColor colorWithRed:0x58/255.0 green:0x59/255.0 blue:0x5b/255.0 alpha:1];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        
        // Style the selected view
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.colors = @[
            (id)[UIColor colorWithRed:0xfa/255.0 green:0xc4/255.0 blue:0x2a/255.0 alpha:1].CGColor,
            (id)[UIColor colorWithRed:195/255.0 green:141/255.0 blue:18/255.0 alpha:1].CGColor
        ];
        gradient.locations = @[@0.0f, @1.0f];
        gradient.frame = CGRectMake(0, 0, 400, 44);
        [cell.selectedBackgroundView.layer insertSublayer:gradient atIndex:0];
    }
    
    // Get the country info
    NSDictionary *info = _searchResult ? _searchResult[indexPath.row] : _countries[indexPath.row];
    
    // Populate the cell
    cell.textLabel.text = info[@"name"];
    
    // Return it
    return cell;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // Create the empty filter result array
    _searchResult = [NSMutableArray arrayWithCapacity:_countries.count];
    
    // Reload the table
    [_tableView reloadData];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    // Done with the filter results
    _searchTextField.text = @"";
    _searchResult = nil;
    
    // Reload the table
    [_tableView reloadData];
}

- (void)searchTextFieldChanged {
    // Get the text that was entered by the user so far
    NSString *text = _searchTextField.text;
    
    // Filter the country list
    assert(_searchResult);
    [_searchResult removeAllObjects];
    for (NSDictionary *info in _countries) {
        NSString *name = info[@"name"];
        if ([name rangeOfString:text options:NSCaseInsensitiveSearch].location != NSNotFound)
            [_searchResult addObject:info];
    }
    
    // Reload the table
    [_tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // If we were filtering the list, stop filtering and
    // select the item we had selected in the filtered list
    if (_searchResult) {
        // Get the selected item
        NSDictionary *item = _searchResult[indexPath.row];
        
        // Stop filtering
        [_searchTextField resignFirstResponder];
        
        // Find the selected item in the new list
        NSInteger pos = [_countries indexOfObject:item];
        assert(pos != NSNotFound);
        
        // Select it
        indexPath = [NSIndexPath indexPathForItem:pos inSection:0];
        [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    // Let others know about this selection
    NSDictionary *info = _countries[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{SelectedCountryKey : info[@"code"]}];
}

@end
