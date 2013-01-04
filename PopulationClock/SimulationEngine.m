//
//  SimulationEngine.m
//  PopulationClock
//
//  Created by Fernando Lemos on 04/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import "DataManager.h"
#import "SimulationEngine.h"

#define SECONDS_PER_YEAR (60 * 60 * 24 * 365)

NSString *SimulationEngineResetNotification = @"SimulationEngineResetNotification";
NSString *SimulationEngineStepTakenNotification = @"SimulationEngineStepTakenNotification";
NSString *SimulationEngineBirthsKey = @"SimulationEngineBirthsKey";
NSString *SimulationEngineDeathsKey = @"SimulationEngineDeathsKey";

@implementation SimulationEngine {
    NSMutableDictionary *_birthProbs, *_deathProbs, *_population;
    NSTimer *_timer;
    NSDate *_lastStep;
}

+ (instancetype)sharedInstance {
    static SimulationEngine *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SimulationEngine new];
    });
    return instance;
}

- (void)reset {
    // Reset the arrays
    NSArray *countryInfo = [DataManager sharedDataManager].orderedCountryData;
    _birthProbs = [NSMutableDictionary dictionaryWithCapacity:countryInfo.count];
    _deathProbs = [NSMutableDictionary dictionaryWithCapacity:countryInfo.count];
    _population = [NSMutableDictionary dictionaryWithCapacity:countryInfo.count];
    
    // Create a cache of timestamps for the first day in the years
    NSMutableDictionary *yearCache = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSDate *referenceDate = [NSDate date];
    for (NSDictionary *info in [DataManager sharedDataManager].orderedCountryData) {
        @autoreleasepool {
            // Get the birth and death probabilities
            NSString *countryCode = info[@"code"];
            float birthProb = [(NSNumber *)info[@"birthRate"] floatValue] / 1000 / SECONDS_PER_YEAR;
            float deathProb = [(NSNumber *)info[@"deathRate"] floatValue] / 1000 / SECONDS_PER_YEAR;
            
            // Get an estimated growth rate per second (note that this
            // doesn't take immigration into account)
            long long population = [(NSNumber *)info[@"population"] intValue];
            float growthRate = population * birthProb - population * deathProb;
            
            // Figure out when the population data was retrieved
            NSNumber *year = info[@"populationYear"];
            NSDate *yearDate = yearCache[year];
            if (!yearDate) {
                NSDateComponents *components = [NSDateComponents new];
                components.day = 31;
                components.month = 12;
                components.year = year.intValue;
                yearDate = [[NSCalendar currentCalendar] dateFromComponents:components];
                yearCache[year] = yearDate;
            }
            
            // Figure out how much time we have to advance the population
            float toAdvance = -[yearDate timeIntervalSinceDate:referenceDate];
            
            // Adjust the population accordingly
            population += toAdvance * growthRate;
            
            // Save this country's data
            _birthProbs[countryCode] = @(birthProb);
            _deathProbs[countryCode] = @(deathProb);
            _population[countryCode] = @(population);
        }
    }
    
    // Let the observers know that we're starting
    [[NSNotificationCenter defaultCenter] postNotificationName:SimulationEngineResetNotification object:self];
    
    // Create a new timer
    [_timer invalidate];
    _timer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(timerFired) userInfo:nil repeats:YES];
    
    // Schedule it in the common run loop modes so that it has the
    // same precedence as a user input operation. This way the timer
    // will fire even though the user might be dragging the scroll
    // view that displays these events
    _lastStep = referenceDate;
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

static inline BOOL check_probability(float prob) {
    return ((float)arc4random() / UINT32_MAX) < prob;
}

- (void)timerFired {
    // Check the interval between the last time we ran
    // so we can adjust the probabilities
    NSDate *now = [NSDate date];
    NSTimeInterval scale = [now timeIntervalSinceDate:_lastStep];
    _lastStep = now;
    
    // Check the birth probability for each country
    NSMutableSet *births = [[NSMutableSet alloc] initWithCapacity:10];
    NSArray *countryCodes = _birthProbs.allKeys;
    for (NSString *countryCode in countryCodes) {
        long long population = [(NSNumber *)_population[countryCode] longLongValue];
        float prob = [(NSNumber *)_birthProbs[countryCode] floatValue] * population * scale;
#ifdef DEBUG
        if (prob > 1)
            NSLog(@"Probability > 1, consider reducing the interval");
#endif
        if (prob >= 1 || check_probability(prob)) {
            [births addObject:countryCode];
            _population[countryCode] = @(population + 1);
        }
    }
    
    // Same thing for deaths
    NSMutableSet *deaths = [[NSMutableSet alloc] initWithCapacity:10];
    for (NSString *countryCode in countryCodes) {
        long long population = [(NSNumber *)_population[countryCode] longLongValue];
        float prob = [(NSNumber *)_deathProbs[countryCode] floatValue] * population * scale;
#ifdef DEBUG
        if (prob > 1)
            NSLog(@"Probability > 1, consider reducing the interval");
#endif
        if (prob >= 1 || check_probability(prob)) {
            [deaths addObject:countryCode];
            _population[countryCode] = @(population - 1);
        }
    }
    
    // Publish the notification
    [[NSNotificationCenter defaultCenter] postNotificationName:SimulationEngineStepTakenNotification object:self userInfo:@{
        SimulationEngineBirthsKey : births,
        SimulationEngineDeathsKey : deaths
     }];
}

@end
