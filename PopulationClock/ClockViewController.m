//
//  ClockViewController.m
//  PopulationClock
//
//  Created by Fernando Lemos on 18/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "ClockViewController.h"
#import "DataManager.h"
#import "SimulationEngine.h"

@implementation ClockViewController {
    IBOutlet __weak PopulationClockView *_clock;
    IBOutlet __weak UIImageView *_backgroundImageView;
    IBOutlet __weak UILabel *_countryNameLabel;
    NSString *_selectedCountry;
}

- (void)dealloc {
    // We are no longer observers
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    // Observe changes to the country selection
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(countrySelectionChanged:) name:CountrySelectionNotification object:nil];
    
    // Observe resets and steps taken by the simulator
    [nc addObserver:self selector:@selector(simulationEngineReset:) name:SimulationEngineResetNotification object:nil];
    [nc addObserver:self selector:@selector(simulationEngineStepTaken:) name:SimulationEngineStepTakenNotification object:nil];
}

- (void)updatePopulationClockAnimated:(BOOL)animated {
    NSNumber *number = [SimulationEngine sharedInstance].populationPerCountry[_selectedCountry];
    [_clock setPopulation:number.longLongValue animated:animated];
}

- (void)countrySelectionChanged:(NSNotification *)notification {
    // Get the selection
    NSString *selection = notification.userInfo[SelectedCountryKey];
    
    // Get the text we'll use in the label
    NSDictionary *info = [DataManager sharedDataManager].countryData[selection];
    NSString *populationText = NSLocalizedString(@"POPULATION: ", @"");
    NSString *countryNameText = [info[@"name"] uppercaseString];
    
    // Create the attributed string and update the label
    if (&NSFontAttributeName == NULL) {
        _countryNameLabel.text = [populationText stringByAppendingString:countryNameText];
    }
    else {
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:populationText attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:16]
        }];
        NSAttributedString *nameAttr = [[NSAttributedString alloc] initWithString:countryNameText attributes:@{
            NSFontAttributeName : [UIFont boldSystemFontOfSize:16]
        }];
        [str appendAttributedString:nameAttr];
         _countryNameLabel.attributedText = str;
    }
    
    // We'll need to layout the subviews again to align the labels
    [self.view setNeedsLayout];
    
    // Update the population clock
    _selectedCountry = selection;
    BOOL stateRestoration = [notification.userInfo[StateRestorationKey] boolValue];
    [self updatePopulationClockAnimated:!stateRestoration];
}

- (void)simulationEngineReset:(NSNotification *)notification {
    // Update the population clock with no animation
    [self updatePopulationClockAnimated:NO];
}

- (void)simulationEngineStepTaken:(NSNotification *)notification {
    // Update the population clock
    [self updatePopulationClockAnimated:YES];
}

- (void)viewWillLayoutSubviews {
    // The first time the view is laid out, we don't have metrics
    if (self.view.bounds.size.width == 0 || self.view.bounds.size.height == 0)
        return;
    
    // We have a different background image depending on the orientation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation))
        _backgroundImageView.image = [UIImage imageNamed:@"bgClockHoriz"];
    else
        _backgroundImageView.image = [UIImage imageNamed:@"bgClockVert"];
    
    // Determine the total height of the elements we'll center and
    // derive the Y origin of the label from that
    [_countryNameLabel sizeToFit];
    CGFloat height = _countryNameLabel.frame.size.height + 8 + _clock.frame.size.height;
    CGFloat originY = (self.view.bounds.size.height - height) / 2;
    
    // We can now position the label
    CGRect frame = _countryNameLabel.frame;
    CGFloat maxWidth = self.view.bounds.size.width - 40;
    if (frame.size.width > maxWidth)
        frame.size.width = maxWidth;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY;
    _countryNameLabel.frame = frame;
    
    // And then the clock
    frame = _clock.frame;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width) / 2;
    frame.origin.y = originY + height - frame.size.height;
    _clock.frame = frame;
}

@end
