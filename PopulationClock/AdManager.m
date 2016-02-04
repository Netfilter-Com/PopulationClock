//
//  AdManager.m
//  PopulationClock
//
//  Created by Fernando Lemos on 07/02/13.
//  Copyright (c) 2013 NetFilter. All rights reserved.
//

//#import "AdManager.h"
//#import "InAppPurchaseManager.h"
//
//@implementation AdManager
//
//+ (instancetype)sharedInstance
//{
//    static AdManager *instance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [AdManager new];
//    });
//    return instance;
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//- (GADBannerView *)adBannerViewWithSize:(GADAdSize)adSize
//{
//    return [self adBannerViewWithSize:adSize origin:CGPointZero];
//}
//
//- (GADBannerView *)adBannerViewWithSize:(GADAdSize)adSize origin:(CGPoint)origin
//{
//    if ([InAppPurchaseManager sharedInstance].adsRemoved) {
//        return nil;
//    }
//    
//    GADBannerView *bannerView = [[GADBannerView alloc] initWithAdSize:adSize origin:origin];
//    bannerView.adUnitID = @"a150db06a46d404";
//    return bannerView;
//}
//
//- (void)doneConfiguringAdBannerView:(GADBannerView *)bannerView
//{
//    GADRequest *request = [GADRequest request];
//#ifdef DEBUG
//    request.testing = YES;
//#endif
//    [bannerView loadRequest:request];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(purchaseDone:)
//                                                 name:InAppPurchasePurchasedRemoveAds object:nil];
//}
//
//- (void)purchaseDone:(NSNotification *)notification
//{
//    [self.delegate adManagerShouldHideAdView:self];
//}
//
//@end
