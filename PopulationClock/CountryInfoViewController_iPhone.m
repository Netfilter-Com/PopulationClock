//
//  CountryInfoViewController_iPhone.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "CountryInfoViewController_iPhone.h"
#import "DataManager.h"
#import "PopulationClockView.h"
#import "SimulationEngine.h"

@interface CountryInfoViewController_iPhone ()

@property (nonatomic, weak) IBOutlet UIView *leftPanel;
@property (nonatomic, weak) IBOutlet UIView *rightPanel;
@property (nonatomic, weak) IBOutlet UILabel *countryName;
@property (nonatomic, weak) IBOutlet PopulationClockView *populationClock;

@end

@implementation CountryInfoViewController_iPhone {
    NSString *_selectedCountry;
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    // Observe changes to the country selection
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
    
    // Observe resets and steps taken by the simulator
    [nc addObserver:self selector:@selector(simulationEngineReset:) name:SimulationEngineResetNotification object:nil];
    [nc addObserver:self selector:@selector(simulationEngineStepTaken:) name:SimulationEngineStepTakenNotification object:nil];
}

- (void)updatePopulationClockAnimated:(BOOL)animated
{
    NSNumber *number = [SimulationEngine sharedInstance].populationPerCountry[_selectedCountry];
    [self.populationClock setPopulation:number.longLongValue animated:animated];
}

- (void)countrySelectionChanged:(NSNotification *)notification
{
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Update the country name
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    self.countryName.text = [info[@"name"] uppercaseString];
    
    // Update the population clock
    _selectedCountry = selection;
    BOOL stateRestoration = [notification.userInfo[StateRestorationKey] boolValue];
    [self updatePopulationClockAnimated:!stateRestoration];
}

- (void)simulationEngineReset:(NSNotification *)notification
{
    // Update the population clock with no animation
    [self updatePopulationClockAnimated:NO];
}

- (void)simulationEngineStepTaken:(NSNotification *)notification {
    // Update the population clock
    [self updatePopulationClockAnimated:YES];
}

- (void)viewWillLayoutSubviews
{
    CGFloat width = self.view.bounds.size.width / 2;
    CGFloat height = self.view.bounds.size.height;
    self.leftPanel.frame = CGRectMake(0, 0, width, height);
    self.rightPanel.frame = CGRectMake(width, 0, width, height);
}

@end
