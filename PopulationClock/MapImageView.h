//
//  MapImageView.h
//  PopulationClock
//
//  Created by Fernando Lemos on 12/12/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

@interface MapImageView : UIImageView

@property (nonatomic, assign) BOOL paused;

@property (nonatomic, strong) UIColor *maskColor;

- (void)blinkCountries:(NSArray *)countryCodes color:(UIColor *)color;

- (void)selectCountry:(NSString *)country;

- (void)deselectCurrentCountry;

- (void)flashIcon:(UIImage *)icon atCountry:(NSString *)countryCode;

@end
