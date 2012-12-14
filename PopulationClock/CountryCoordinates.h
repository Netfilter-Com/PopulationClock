//
//  CountryCoordinates.h
//  PopulationClock
//
//  Created by Fernando Lemos on 14/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

extern CGPoint CountryCoordinatesNotFound;

@interface CountryCoordinates : NSObject

- (CGPoint)relativeCoordinatesForCountry:(NSString *)countryCode;

@end
