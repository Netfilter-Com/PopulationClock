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
#define SIMULATION_STEP 1.5
#define SIMULATION_INTERVAL 0.2

NSString *SimulationEngineResetNotification = @"SimulationEngineResetNotification";
NSString *SimulationEngineStepTakenNotification = @"SimulationEngineStepTakenNotification";
NSString *SimulationEngineBirthsKey = @"SimulationEngineBirthsKey";
NSString *SimulationEngineDeathsKey = @"SimulationEngineDeathsKey";

@implementation SimulationEngine {
    NSMutableDictionary *_birthProbs, *_deathProbs, *_population;
    NSTimer *_timer;
    NSDate *_lastStep;
    dispatch_queue_t _backgroundQueue;
    BOOL _launchedTimer;
}

+ (instancetype)sharedInstance {
    static SimulationEngine *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [SimulationEngine new];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // Create the background queue
        _backgroundQueue = dispatch_queue_create("br.com.netfilter.SimulationEngineBackgroundQueue", NULL);
    }
    return self;
}

- (void)dealloc {
    // Release the background queue
    if (_backgroundQueue)
        dispatch_release(_backgroundQueue);
}

- (void)reset {
    // Perform the reset in a background thread so
    // we don't have to synchronize anything
    dispatch_async(_backgroundQueue, ^{
        [self resetBackground];
    });
}

- (void)resetBackground {
    // Reset the arrays
    NSArray *countryInfo = [DataManager sharedDataManager].orderedCountryData;
    _birthProbs = [NSMutableDictionary dictionaryWithCapacity:countryInfo.count];
    _deathProbs = [NSMutableDictionary dictionaryWithCapacity:countryInfo.count];
    _population = [NSMutableDictionary dictionaryWithCapacity:countryInfo.count];
    
    // Create a cache of timestamps for the first day in the years
    NSMutableDictionary *yearCache = [NSMutableDictionary dictionaryWithCapacity:5];
    
    NSDate *referenceDate = [NSDate date];
    for (NSDictionary *info in countryInfo) {
        @autoreleasepool {
            // Get the birth and death probabilities
            NSString *countryCode = info[@"code"];
            float birthProb = [(NSNumber *)info[@"birthRate"] floatValue] / 1000 / SECONDS_PER_YEAR;
            float deathProb = [(NSNumber *)info[@"deathRate"] floatValue] / 1000 / SECONDS_PER_YEAR;
            
            // Get an estimated growth rate per second (note that this
            // doesn't take immigration into account)
            long long population = [(NSNumber *)info[@"population"] longLongValue];
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
    
    // Let the observers know that we were reset
    [[NSNotificationCenter defaultCenter] postNotificationName:SimulationEngineResetNotification object:self];
    
    // Since we messed with the estimated stats, this is the time
    // since the "last step"
    _lastStep = [NSDate date];
    
    // Dispatch the "timer" in a background thread, but do it only once,
    // even if reset is called multiple times
    if (!_launchedTimer) {
        [self dispatchTimerFiredInBackgroundQueue];
        _launchedTimer = YES;
    }
}

- (void)dispatchTimerFiredInBackgroundQueue {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, SIMULATION_STEP * NSEC_PER_SEC);
    dispatch_after(popTime, _backgroundQueue, ^{
        [self timerFired];
    });
}

static inline BOOL check_probability(float prob) {
    return ((float)arc4random() / UINT32_MAX) < prob;
}

- (void)simulateBirths:(NSMutableSet *)births withScale:(NSTimeInterval)scale {
    for (NSString *countryCode in _birthProbs.allKeys) {
        long long population = [(NSNumber *)_population[countryCode] longLongValue];
        float prob = [(NSNumber *)_birthProbs[countryCode] floatValue] * population * scale;
#ifdef DEBUG
        assert(prob >= 0 && prob <= 1);
#endif
        if (check_probability(prob)) {
            [births addObject:countryCode];
            _population[countryCode] = @(population + 1);
        }
    }
}

- (void)simulateDeaths:(NSMutableSet *)deaths withScale:(NSTimeInterval)scale {
    for (NSString *countryCode in _deathProbs.allKeys) {
        long long population = [(NSNumber *)_population[countryCode] longLongValue];
        float prob = [(NSNumber *)_deathProbs[countryCode] floatValue] * population * scale;
#ifdef DEBUG
        assert(prob >= 0 && prob <= 1);
#endif
        if (check_probability(prob)) {
            [deaths addObject:countryCode];
            _population[countryCode] = @(population - 1);
        }
    }
}

- (void)timerFired {
    // Check the interval between the last time we ran
    // so we can adjust the probabilities
    NSDate *now = [NSDate date];
    NSTimeInterval scale = [now timeIntervalSinceDate:_lastStep];
    _lastStep = now;
    
    // Simulate births and deaths in increments of a small value, so that
    // the probability pretty much never goes beyond 1
    NSMutableSet *births = [[NSMutableSet alloc] initWithCapacity:10];
    NSMutableSet *deaths = [[NSMutableSet alloc] initWithCapacity:10];
    while (scale > SIMULATION_INTERVAL) {
        scale -= SIMULATION_INTERVAL;
        [self simulateBirths:births withScale:SIMULATION_INTERVAL];
        [self simulateDeaths:deaths withScale:SIMULATION_INTERVAL];
    }
    if (scale > 0) {
        [self simulateBirths:births withScale:scale];
        [self simulateDeaths:deaths withScale:scale];
    }
    
    // Do the rest SYNCHRONOUSLY in the main thread
    dispatch_sync(dispatch_get_main_queue(), ^{
        // Copy the population dictionary so the main thread
        // will be able to safely access this. This is only safe
        // because we use dispatch_SYNC, so we don't end messing
        // with _population until this block is done
        _populationPerCountry = [_population copy];
        
        // Post the notification here so observers will also
        // receive it in the main thread
        [[NSNotificationCenter defaultCenter] postNotificationName:SimulationEngineStepTakenNotification object:self userInfo:@{
            SimulationEngineBirthsKey : births,
            SimulationEngineDeathsKey : deaths
         }];
    });
    
    // Schedule the next run
    [self dispatchTimerFiredInBackgroundQueue];
}

@end
