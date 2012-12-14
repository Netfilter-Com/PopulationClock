//
//  MapImageView.h
//  PopulationClock
//
//  Created by Fernando Lemos on 12/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

@interface MapImageView : UIImageView

- (void)blinkCountries:(NSArray *)countryCodes color:(UIColor *)color;

- (void)selectCountry:(NSString *)country maskColor:(UIColor *)color;
- (void)deselectCurrentCountry;

- (void)flashIcon:(UIImage *)icon atCountry:(NSString *)countryCode;

@end
