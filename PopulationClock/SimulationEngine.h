//
//  SimulationEngine.h
//  PopulationClock
//
//  Created by Fernando Lemos on 04/01/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

extern NSString *SimulationEngineResetNotification;
extern NSString *SimulationEngineStepTakenNotification;
extern NSString *SimulationEngineBirthsKey;
extern NSString *SimulationEngineDeathsKey;

@interface SimulationEngine : NSObject

@property (nonatomic, readonly) NSDictionary *populationPerCountry;

+ (instancetype)sharedInstance;

- (void)reset;

@end
