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
    IBOutlet __weak UITextField *_searchTextField;
    IBOutlet __weak UITableView *_tableView;
    NSMutableArray *_countries;
    NSMutableArray *_searchResult;
}

- (void)awakeFromNib {
    // TODO: Actually load this from somewhere
    _countries = [@[
        @{ @"code" : @"br", @"name" : @"Brazil" },
        @{ @"code" : @"us", @"name" : @"United States" },
        @{ @"code" : @"jp", @"name" : @"Japan" },
        @{ @"code" : @"it", @"name" : @"Italy" },
        @{ @"code" : @"es", @"name" : @"Spain" },
        @{ @"code" : @"pt", @"name" : @"Portugal" },
        @{ @"code" : @"au", @"name" : @"Australia" },
        @{ @"code" : @"cn", @"name" : @"China" },
        @{ @"code" : @"ca", @"name" : @"Canada" },
        @{ @"code" : @"mx", @"name" : @"Mexico" }
    ] mutableCopy];
    
    // Sort the list of countries
    [_countries sortUsingComparator:^(id obj1, id obj2) {
        NSString *name1 = [obj1 objectForKey:@"name"];
        NSString *name2 = [obj2 objectForKey:@"name"];
        return [name1 compare:name2 options:NSCaseInsensitiveSearch];
    }];
    
    // Set up to receive text change notifications in
    // the search text field
    [_searchTextField addTarget:self action:@selector(searchTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _searchResult ? _searchResult.count : _countries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get a new table view cell
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"country"];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"country"];
    
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
    // Done with the filter result array
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

@end
