//
//  AdManager.h
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@protocol AdManagerDelegate;

@interface AdManager : NSObject

@property (nonatomic, weak) id <AdManagerDelegate> delegate;

+ (instancetype)sharedInstance;

- (GADBannerView *)adBannerViewWithSize:(GADAdSize)adSize origin:(CGPoint)origin;
- (GADBannerView *)adBannerViewWithSize:(GADAdSize)adSize;

- (void)doneConfiguringAdBannerView:(GADBannerView *)bannerView;

@end

@protocol AdManagerDelegate <NSObject>

- (void)adManagerShouldHideAdView:(AdManager *)manager;

@end
