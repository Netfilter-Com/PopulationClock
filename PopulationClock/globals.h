//
//  globals.h
//  PopulationClock
//
//  Created by Fernando Lemos on 21/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

extern NSString * const CountrySelectionNotification;
extern NSString * const SelectedCountryKey;
extern NSString * const StateRestorationKey;
extern NSString * const SelectedCountryNoWorldKey;
#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

