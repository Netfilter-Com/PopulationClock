//
//  InAppPurchaseManager.h
//  Population Clock
//
//  Created by Fernando Lemos on 05/09/12.
//  Copyright (c) 2012 NetFilter. All rights reserved.
//

#import <StoreKit/StoreKit.h>

// TODO: StoreKit 2 (Transaction / Product.products(for:)) is Swift-only.
// Migrating off StoreKit 1 here requires introducing Swift to this
// otherwise all-Objective-C project, which is out of scope for now.

extern NSString *InAppPurchaseManagerRetrievedProducts;
extern NSString *InAppPurchaseManagerFailedToRetrieveProducts;
extern NSString *InAppPurchasePurchasedRemoveAds;

@interface InAppPurchaseManager : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign, readonly) BOOL canMakePayments;
@property (nonatomic, assign, readonly) BOOL adsRemoved;

+ (InAppPurchaseManager *)sharedInstance;

- (BOOL)retrieveProducts;
- (void)purchaseRemoveAdsWithCallback:(void (^)(BOOL))callback;

@end
