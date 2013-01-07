//
//  CountryCoordinates.m
//  PopulationClock
//
//  Created by Fernando Lemos on 14/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import "CountryCoordinates.h"

CGPoint CountryCoordinatesNotFound = { .x = -1, .y = -1 };

@implementation CountryCoordinates {
    NSDictionary *_coordinates;
}

- (id)init {
    self = [super init];
    if (self) {
        // Load the coordinates
        NSString *path = [[NSBundle mainBundle] pathForResource:@"coords" ofType:@"plist"];
        _coordinates = [NSDictionary dictionaryWithContentsOfFile:path];
    }
    return self;
}

- (CGPoint)relativeCoordinatesForCountry:(NSString *)countryCode {
    // Fetch the coordinates
    NSDictionary *coords = _coordinates[countryCode];
    if (!coords)
        return CountryCoordinatesNotFound;
    
    // Get the latitude and longitude
    CGPoint res;
    res.x = [coords[@"longitude"] floatValue];
    res.y = [coords[@"latitude"] floatValue];
    
    // In our map, the longitude is a bit offset, so adjust
    // for it and possibly wrap
    res.x -= 10;
    if (res.x < -180)
        res.x = 360 + res.x;
    
    // Normalize and return the coordinates
    res.x = res.x / 360 + 0.5;
    res.y = res.y / -180 + 0.5;
    assert(res.x >= 0 && res.x <= 1 && res.y >= 0 && res.y <= 1);
    return res;
}

@end
