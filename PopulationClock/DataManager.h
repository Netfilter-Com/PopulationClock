//
//  DataManager.h
//  PopulationClock
//
//  Created by Fernando Lemos on 21/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

@interface DataManager : NSObject

+ (instancetype)sharedDataManager;

@property (nonatomic, strong) NSDictionary *countryData;
@property (nonatomic, strong) NSArray *orderedCountryData;

@end
