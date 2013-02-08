//
//  SavedStateManager.m
//  PopulationClock
//
//  Created by Fernando Lemos on 08/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "SavedStateManager.h"

@implementation SavedStateManager

+ (instancetype)sharedInstance
{
    static SavedStateManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SavedStateManager new];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Load the saved state
        [self loadSavedState];
        
        // Monitor changes to the country selection
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(countrySelectionChanged:)
                                                     name:CountrySelectionNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    // We're no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadSavedState
{
    // Get the selection from the defaults
    NSString *selection = [[NSUserDefaults standardUserDefaults] stringForKey:SelectedCountryKey];
    if (!selection)
        selection = @"world";
    
    // Let other listeners know
    [[NSNotificationCenter defaultCenter] postNotificationName:CountrySelectionNotification object:self userInfo:@{
        SelectedCountryKey : selection,
        StateRestorationKey : @YES
    }];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Nothing to do if we're the source of the notification
    if (notification.object == self)
        return;
    
    // Save the new selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    [[NSUserDefaults standardUserDefaults] setObject:selection forKey:SelectedCountryKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
